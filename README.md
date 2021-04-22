# AstroAngles.jl

[![Build Status](https://github.com/JuliaAstro/AstroAngles.jl/workflows/CI/badge.svg)](https://github.com/JuliaAstro/AstroAngles.jl/actions)
[![PkgEval](https://juliaci.github.io/NanosoldierReports/pkgeval_badges/A/AstroAngles.svg)](https://juliaci.github.io/NanosoldierReports/pkgeval_badges/report.html)
[![Coverage](https://codecov.io/gh/JuliaAstro/AstroAngles.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/JuliaAstro/AstroAngles.jl)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Lightweight string parsing and representation of angles.

## Installation

To install use [Pkg](https://julialang.github.io/Pkg.jl/v1/managing-packages/). From the REPL, press `]` to enter Pkg-mode

```julia
pkg> add AstroAngles
```

If you want to use the most up-to-date version of the code, check it out from `main`

```julia
pkg> add AstroAngles#main
```

## Usage

### Angle Parsing Utilities

String representations of angles in both "degree:arcmin:arcsec" and  "hour:min:sec" format can be parsed using a variety of delimiters, which can be mixed together (e.g. can use `°` after degrees but `:` after the arcminutes). The directions "S" and "W" are considered negative and "-1:0:0S" is 1 degree North, for example.

#### dms formats

```julia
"[+-]xx:xx:xx.x[NS]"
"[+-]xx xx xx.x[NS]"
"[+-]xxdxxmxx.xs[NS]"
"[+-]xx°xx'xx.x\"[NS]"
"[+-]xx°xx′xx.x″[NS]" # \prime, \pprime
```

#### hms formats

```julia
"[+-]xx:xx:xx.x[EW]"
"[+-]xx xx xx.x[EW]"
"[+-]xxhxxmxx.xs[EW]"
"[+-]xxhxx'xx.x\"[EW]"
"[+-]xx°xx′xx.x″[EW]"
```

the simplest way to convert is to use the `@dms_str` and `@hms_str` macros, which allows you to choose the output angle type

```julia
julia> dms"12:17:25.3"
0.21450726764795752

julia> dms"12:17:25.3"rad # default
0.21450726764795752

julia> dms"12:17:25.3"deg
12.29036111111111

julia> dms"12:17:25.3"ha
0.8193574074074074
```

here is a showcase of the variety of ways to parse inputs

```julia
julia> dms"10.2345d"deg
10.2345

julia> dms"1:2:30.43"deg
1.04178611

julia> hms"1 2 0"ha
1.03333333

julia> dms"1°2′3″"deg
1.03416667

julia> dms"1°2′3″N"deg
1.03416667

julia> dms"1d2m3.4s"deg
1.03427778

julia> dms"1d2m3.4sS"deg
-1.03427778

julia> hms"-1h2m3s"ha
-1.03416667

julia> hms"-1h2m3sW"ha
1.03416667
```

for more control on the output, you can use the `parse_dms` and `parse_hms` methods, which returns a tuple of the parsed `dms` or `hms` values

```julia
parse_dms # string -> (deg, arcmin, arcsec)
parse_hms # string -> (hours, mins, secs)
```

```julia
julia> parse_dms("12:17:25.3")
(12.0, 17.0, 25.3)

julia> parse_hms("-4:4:6")
(-4.0, 4.0, 6.0)
```

### Angle Conversion Utilities

The following methods are added for converting to and from hour angles

```julia
deg2ha # degrees -> hour angles
rad2ha # radians -> hour angles
ha2deg # hour angles -> degrees
ha2rad # hour angles -> radians
```

The following methods convert from angles as a single number to tuples consistent with sexagesimal

```julia
deg2dms # degrees -> (deg, arcmin, arcsec)
rad2dms # radians -> (deg, arcmin, arcsec)
ha2dms  # hour angles -> (deg, arcmin, arcsec)

deg2hms # degrees -> (hours, mins, secs)
rad2hms # radians -> (hours, mins, secs)
ha2hms  # hour angles -> (hours, mins, secs)
```

and the inverse

```julia
dms2deg # (deg, arcmin, arcsec) -> degrees
dms2rad # (deg, arcmin, arcsec) -> radians
dms2ha  # (deg, arcmin, arcsec) -> hour angles

hms2deg # (hours, mins, secs) -> degrees
hms2rad # (hours, mins, secs) -> radians
hms2ha  # (hours, mins, secs) -> hour angles
```

the above functions can take a string as input and will automatically parse it (using `parse_dms` or `parse_hms`, respectively) before converting.

### Formatting angles

Lastly, we have some simple methods for formatting angles into strings, although for more fine-tuned control we recommend using [Printf](https://docs.julialang.org/en/v1/stdlib/Printf/) or a package like [Formatting.jl](https://github.com/JuliaIO/Formatting.jl). `format_angle` takes parts (like from `deg2dms` or `rad2hms`) and a delimiter (or collection of 3 delimiters for each value).

```julia
julia> format_angle(deg2dms(45.0))
"45:0:0.0"

julia> format_angle(deg2hms(-65.0); delim=["h", "m", "s"])
"-4h19m59.999999999998934s"
```

### Example: reading coordinates from a table

Here's an example of reading sky coordinates from a CSV formatted target list and converting them to degrees-

```julia
julia> using AstroAngles, CSV, DataFrames

julia> table = CSV.File("target_list.csv") |> DataFrame;

julia> [table.ra table.dec]
203×2 Matrix{String}:
 "00 05 01.42"  "40 03 35.82"
 "00 05 07.52"  "73 13 11.34"
 "00 36 01.40"  "-11 12 13.00"
[...]

julia> ra_d = @. hms2deg(table.ra)
203-element Vector{Float64}:
   1.2559166666666666
   1.2813333333333332
   9.005833333333333
[...]

julia> dec_d = @. dms2deg(table.dec)
203-element Vector{Float64}:
  40.05995
  73.21981666666667
 -11.203611111111112
[...]
```

## Contributing/Support

To contribute, feel free to open a [pull request](https://github.com/JuliaAstro/AstroAngles.jl/pulls). If you run into problems, please open an [issue](https://github.com/JuliaAstro/AstroAngles.jl/issues). To discuss ideas, usage, or to plan contributions, open a new [discussion](https://github.com/JuliaAstro/AstroAngles.jl/discussions).

## License

This code is MIT licensed. For more information, see [LICENSE](LICENSE).
