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

## Contributing

## License
