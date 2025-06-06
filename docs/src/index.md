```@meta
DocTestSetup = :(using AstroAngles)
```
# AstroAngles.jl

[![Documentation - Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://juliaastro.org/AstroAngles/)
[![Documentation - Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://juliaastro.org/AstroAngles.jl/dev)

[![Coverage](https://codecov.io/gh/JuliaAstro/AstroAngles.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/JuliaAstro/AstroAngles.jl)
[![Build Status](https://github.com/JuliaAstro/AstroAngles.jl/workflows/CI/badge.svg)](https://github.com/JuliaAstro/AstroAngles.jl/actions)
[![PkgEval](https://juliaci.github.io/NanosoldierReports/pkgeval_badges/A/AstroAngles.svg)](https://juliaci.github.io/NanosoldierReports/pkgeval_badges/report.html)
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
"[+-]xx:xx:xx.x[NESW]"
"[+-]xx xx xx.x[NESW]"
"[+-]xxdxxmxx.xs[NESW]"
"[+-]xx°xx'xx.x\"[NESW]"
"[+-]xx°xx′xx.x″[NESW]" # \prime, \pprime
```

#### hms formats

```julia
"[+-]xx:xx:xx.x[NESW]"
"[+-]xx xx xx.x[NESW]"
"[+-]xxhxxmxx.xs[NESW]"
"[+-]xxhxx'xx.x\"[NESW]"
"[+-]xx°xx′xx.x″[NESW]"
```

the simplest way to convert is to use the `@dms_str` and `@hms_str` macros, which allows you to choose the output angle type

```jldoctest
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

```jldoctest
julia> dms"10.2345d"deg
10.2345

julia> dms"1:2:30.43"deg
1.041786111111111

julia> hms"1 2 0"ha
1.0333333333333334

julia> dms"1°2′3″"deg
1.0341666666666667

julia> dms"1°2′3″N"deg
1.0341666666666667

julia> dms"1d2m3.4s"deg
1.0342777777777779

julia> dms"1d2m3.4sS"deg
-1.0342777777777779

julia> hms"-1h2m3s"ha
-1.0341666666666667

julia> hms"-1h2m3sW"ha
1.0341666666666667
```

for more control on the output, you can use the `parse_dms` and `parse_hms` methods, which returns a tuple of the parsed `dms` or `hms` values

```julia
parse_dms # string -> (deg, arcmin, arcsec)
parse_hms # string -> (hours, mins, secs)
```

```jldoctest
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

Lastly, we have some simple methods for formatting angles into strings, although for more fine-tuned control we recommend using [Printf](https://docs.julialang.org/en/v1/stdlib/Printf/) or a package like [Format.jl](https://github.com/JuliaString/Format.jl). `format_angle` takes parts (like from `deg2dms` or `rad2hms`) and a delimiter (or collection of 3 delimiters for each value).

```jldoctest
julia> format_angle(deg2dms(45.0))
"45:0:0.0"

julia> format_angle(deg2hms(-65.0); delim=["h", "m", "s"])
"-4h19m59.999999999998934s"
```

### Example: reading coordinates from a table

Here's an example of reading sky coordinates from a CSV formatted target list and converting them to degrees:

```julia-repl
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

### Handling Missing Values

All angle parsing, conversion, and formatting functions support `Missing` input values and propagate them correctly, returning `missing` as output. This behavior allows these functions to be used smoothly in operations with potentially missing data, such as when working with DataFrames that contain missing values.

```jldoctest
julia> using AstroAngles

julia> # Parsing functions

julia> parse_dms(missing)
missing

julia> parse_hms(missing)
missing

julia> # Conversion functions

julia> rad2ha(missing)
missing

julia> deg2dms(missing)
missing

julia> dms2rad(missing, missing, missing)
missing

julia> hms2deg("12:30:45"), hms2deg(missing)
(187.6875, missing)

julia> # Formatting function

julia> format_angle(missing)
missing

julia> format_angle(deg2dms(45.0)), format_angle(missing)
("45:0:0.0", missing)
```

This feature ensures type stability when working with data that may contain missing values, which is particularly useful in data analysis workflows involving astronomical data where some measurements might be unavailable.

## Contributing/Support

To contribute, feel free to open a [pull request](https://github.com/JuliaAstro/AstroAngles.jl/pulls). If you run into problems, please open an [issue](https://github.com/JuliaAstro/AstroAngles.jl/issues). To discuss ideas, usage, or to plan contributions, open a new [discussion](https://github.com/JuliaAstro/AstroAngles.jl/discussions).

## License

This code is MIT licensed. For more information, see the LICENSE file in the
AstroAngles.jl repository.
