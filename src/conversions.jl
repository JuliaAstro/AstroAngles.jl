##
## Angle Conversions
##

const MINUTES_TO_WHOLE = inv(60)
const SECONDS_TO_WHOLE = inv(3600)
const HOURS_PER_DEGREE = 24 / 360
const HOURS_PER_RADIAN = 12 / π
const DEGREES_PER_HOUR = 360 / 24
const RADIANS_PER_HOUR = π / 12


### rad2xxx

"""
    rad2ha(angle)

Convert radians to hour angles.

If `angle` is `Missing`, returns `missing`.
"""
rad2ha(angle) = angle * HOURS_PER_RADIAN
rad2ha(::Missing) = missing

"""
    rad2dms(angle)

Convert radians to (degrees, arcminutes, arcseconds) tuple.

If `angle` is `Missing`, returns `missing`.
"""
rad2dms(angle) = rad2deg(angle) |> deg2dms
rad2dms(::Missing) = missing

"""
    rad2hms(angle)

Convert radians to (hours, minutes, seconds) tuple.

If `angle` is `Missing`, returns `missing`.
"""
rad2hms(angle) = rad2ha(angle) |> ha2hms
rad2hms(::Missing) = missing

### deg2xxx

"""
    deg2ha(angle)

Convert degrees to hour angles.

If `angle` is `Missing`, returns `missing`.
"""
deg2ha(angle) = angle * HOURS_PER_DEGREE
deg2ha(::Missing) = missing

"""
    deg2dms(angle)

Convert degrees to (degrees, arcminutes, arcseconds) tuple.

If `angle` is `Missing`, returns `missing`.
"""
function deg2dms(angle)
    remain_degrees, degrees = modf(angle)
    fraction_arcmin = abs(remain_degrees) * 60
    remain_arcmin, arcmin = modf(fraction_arcmin)
    arcsec = remain_arcmin * 60
    return degrees, arcmin, arcsec
end
deg2dms(::Missing) = missing

"""
    deg2hms(angle)

Convert degrees to (hours, minutes, seconds) tuple.

If `angle` is `Missing`, returns `missing`.
"""
deg2hms(angle) = deg2ha(angle) |> ha2hms
deg2hms(::Missing) = missing

### ha2xxx

"""
    ha2rad(angle)

Convert hour angles to radians.

If `angle` is `Missing`, returns `missing`.
"""
ha2rad(angle) = angle * RADIANS_PER_HOUR
ha2rad(::Missing) = missing

"""
    ha2deg(angle)

Convert hour angles to degrees.

If `angle` is `Missing`, returns `missing`.
"""
ha2deg(angle) = angle * DEGREES_PER_HOUR
ha2deg(::Missing) = missing

"""
    ha2hms(angle)

Convert hour angles to (hours, minutes, seconds) tuple.

If `angle` is `Missing`, returns `missing`.
"""
function ha2hms(angle)
    remain_hours, hours = modf(angle)
    fraction_min = abs(remain_hours) * 60
    remain_min, minutes = modf(fraction_min)
    seconds = remain_min * 60
    return hours, minutes, seconds
end
ha2hms(::Missing) = missing

"""
    ha2dms(angle)

Convert hour angles to (degrees, arcminutes, arcseconds) tuple.

If `angle` is `Missing`, returns `missing`.
"""
ha2dms(angle) = ha2deg(angle) |> deg2dms
ha2dms(::Missing) = missing

### dms2xxx

"""
    dms2deg(degrees, arcmin, arcsec)
    dms2deg(parts)
    dms2deg(input::AbstractString)

Convert (degrees, arcminutes, arcseconds) tuple to degrees. If a string is
given, will parse with [`parse_dms`](@ref) first. If an angle is input will
treat as a no-op.

If any input is `Missing`, returns `missing`.
"""
function dms2deg(degrees, arcminutes, arcseconds)
    frac = arcminutes * MINUTES_TO_WHOLE + arcseconds * SECONDS_TO_WHOLE
    return signbit(degrees) ? degrees - frac : degrees + frac
end
dms2deg(::Missing, ::Missing, ::Missing) = missing

"""
    dms2rad(degrees, arcmin, arcsec)
    dms2rad(parts)
    dms2rad(input::AbstractString)

Convert (degrees, arcminutes, arcseconds) tuple to radians. If a string is
given, will parse with [`parse_dms`](@ref) first. If an angle is input will
treat as a no-op.

If any input is `Missing`, returns `missing`.
"""
dms2rad(degrees, arcminutes, arcseconds) = dms2deg(degrees, arcminutes, arcseconds) |> deg2rad
dms2rad(::Missing, ::Missing, ::Missing) = missing

"""
    dms2ha(degrees, arcmin, arcsec)
    dms2ha(parts)
    dms2ha(input::AbstractString)

Convert (degrees, arcminutes, arcseconds) tuple to hour angles. If a string is
given, will parse with [`parse_dms`](@ref) first. If an angle is input will
treat as a no-op.

If any input is `Missing`, returns `missing`.
"""
dms2ha(degrees, arcminutes, arcseconds) = dms2deg(degrees, arcminutes, arcseconds) |> deg2ha
dms2ha(::Missing, ::Missing, ::Missing) = missing

# code-gen for string inputs and no-ops
for func in (:dms2deg, :dms2rad, :dms2ha)
    @eval $func(input::AbstractString) = parse_dms(input) |> $func
    @eval $func(input::Number) = input
    @eval $func(input::Missing) = missing
end

### hms2xxx

"""
    hms2ha(hours, mins, secs)
    hms2ha(parts)
    hms2ha(input::AbstractString)

Convert (hours, minutes, seconds) tuple to hour angles. If a string is given,
will parse with [`parse_hms`](@ref) first. If an angle is input will treat as a
no-op.

If any input is `Missing`, returns `missing`.
"""
function hms2ha(hours, minutes, seconds)
    frac = minutes * MINUTES_TO_WHOLE + seconds * SECONDS_TO_WHOLE
    return signbit(hours) ? hours - frac : hours + frac
end
hms2ha(::Missing, ::Missing, ::Missing) = missing

"""
    hms2deg(hours, mins, secs)
    hms2deg(parts)
    hms2deg(input::AbstractString)

Convert (hours, minutes, seconds) tuple to degrees. If a string is given, will
parse with [`parse_hms`](@ref) first. If an angle is input will treat as a
no-op.

If any input is `Missing`, returns `missing`.
"""
hms2deg(hours, minutes, seconds) = hms2ha(hours, minutes, seconds) |> ha2deg
hms2deg(::Missing, ::Missing, ::Missing) = missing

"""
    hms2rad(hours, mins, secs)
    hms2rad(parts)
    hms2rad(input::AbstractString)

Convert (hours, minutes, seconds) tuple to radians. If a string is given, will
parse with [`parse_hms`](@ref) first. If an angle is input will treat as a
no-op.

If any input is `Missing`, returns `missing`.
"""
hms2rad(hours, minutes, seconds) = hms2ha(hours, minutes, seconds) |> ha2rad
hms2rad(::Missing, ::Missing, ::Missing) = missing

# code-gen for string inputs and no-ops
for func in (:hms2deg, :hms2rad, :hms2ha)
    @eval $func(input::AbstractString) = parse_hms(input) |> $func
    @eval $func(input::Number) = input
    @eval $func(input::Missing) = missing
end

# code-gen for accepting inputs separate or in a collection
for func in (:dms2rad, :dms2deg, :dms2ha, :hms2rad, :hms2deg, :hms2ha)
    @eval $func(parts) = $func(parts...)
    @eval $func(::Missing) = missing
end
