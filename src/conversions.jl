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

Convert radians to hour angles
"""
rad2ha(angle) = angle * HOURS_PER_RADIAN

"""
    rad2dms(angle)

Convert radians to (degrees, arcminutes, arcseconds) tuple
"""
rad2dms(angle) = rad2deg(angle) |> deg2dms

"""
    rad2hms(angle)

Convert radians to (hours, minutes, seconds) tuple
"""
rad2hms(angle) = rad2ha(angle) |> ha2hms

### deg2xxx

"""
    deg2ha(angle)

Convert degrees to hour angles
"""
deg2ha(angle) = angle * HOURS_PER_DEGREE

"""
    deg2dms(angle)

Convert degrees to (degrees, arcminutes, arcseconds) tuple
"""
function deg2dms(angle)
    remain_degrees, degrees = modf(angle)
    fraction_arcmin = abs(remain_degrees) * 60
    remain_arcmin, arcmin = modf(fraction_arcmin)
    arcsec = remain_arcmin * 60
    return degrees, arcmin, arcsec
end

"""
    deg2hms(angle)

Convert degrees to (hours, minutes, seconds) tuple
"""
deg2hms(angle) = deg2ha(angle) |> ha2hms

### ha2xxx

"""
    ha2rad(angle)

Convert hour angles to radians
"""
ha2rad(angle) = angle * RADIANS_PER_HOUR

"""
    ha2deg(angle)

Convert hour angles to degrees
"""
ha2deg(angle) = angle * DEGREES_PER_HOUR

"""
    ha2hms(angle)

Convert hour angles to (hours, minutes, seconds) tuple
"""
function ha2hms(angle)
    remain_hours, hours = modf(angle)
    fraction_min = abs(remain_hours) * 60
    remain_min, minutes = modf(fraction_min)
    seconds = remain_min * 60
    return hours, minutes, seconds
end

"""
    ha2dms(angle)

Convert hour angles to (degrees, arcminutes, arcseconds) tuple
"""
ha2dms(angle) = ha2deg(angle) |> deg2dms

### dms2xxx

"""
    dms2deg(degrees, arcmin, arcsec)
    dms2deg(parts)
    dms2deg(input::AbstractString)

Convert (degrees, arcminutes, arcseconds) tuple to degrees. If a string is given, will parse with [`parse_dms`](@ref) first. If an angle is input will treat as a no-op.
"""
function dms2deg(degrees, arcminutes, arcseconds)
    frac = arcminutes * MINUTES_TO_WHOLE + arcseconds * SECONDS_TO_WHOLE
    return signbit(degrees) ? degrees - frac : degrees + frac
end

"""
    dms2rad(degrees, arcmin, arcsec)
    dms2rad(parts)
    dms2rad(input::AbstractString)

Convert (degrees, arcminutes, arcseconds) tuple to radians. If a string is given, will parse with [`parse_dms`](@ref) first. If an angle is input will treat as a no-op.
"""
dms2rad(degrees, arcminutes, arcseconds) = dms2deg(degrees, arcminutes, arcseconds) |> deg2rad

"""
    dms2ha(degrees, arcmin, arcsec)
    dms2ha(parts)
    dms2ha(input::AbstractString)

Convert (degrees, arcminutes, arcseconds) tuple to hour angles. If a string is given, will parse with [`parse_dms`](@ref) first. If an angle is input will treat as a no-op.
"""
dms2ha(degrees, arcminutes, arcseconds) = dms2deg(degrees, arcminutes, arcseconds) |> deg2ha

# code-gen for string inputs and no-ops
for func in (:dms2deg, :dms2rad, :dms2ha)
    @eval $func(input::AbstractString) = parse_dms(input) |> $func
    @eval $func(input::Number) = input
end

### hms2xxx

"""
    hms2ha(hours, mins, secs)
    hms2ha(parts)
    hms2ha(input::AbstractString)

Convert (hours, minutes, seconds) tuple to hour angles. If a string is given, will parse with [`parse_hms`](@ref) first. If an angle is input will treat as a no-op.
"""
function hms2ha(hours, minutes, seconds)
    frac = minutes * MINUTES_TO_WHOLE + seconds * SECONDS_TO_WHOLE
    return signbit(hours) ? hours - frac : hours + frac
end

"""
    hms2deg(hours, mins, secs)
    hms2deg(parts)
    hms2deg(input::AbstractString)

Convert (hours, minutes, seconds) tuple to degrees. If a string is given, will parse with [`parse_hms`](@ref) first. If an angle is input will treat as a no-op.
"""
hms2deg(hours, minutes, seconds) = hms2ha(hours, minutes, seconds) |> ha2deg

"""
    hms2rad(hours, mins, secs)
    hms2rad(parts)
    hms2rad(input::AbstractString)

Convert (hours, minutes, seconds) tuple to radians. If a string is given, will parse with [`parse_hms`](@ref) first. If an angle is input will treat as a no-op.
"""
hms2rad(hours, minutes, seconds) = hms2ha(hours, minutes, seconds) |> ha2rad

# code-gen for string inputs and no-ops
for func in (:hms2deg, :hms2rad, :hms2ha)
    @eval $func(input::AbstractString) = parse_hms(input) |> $func
    @eval $func(input::Number) = input
end

# code-gen for accepting inputs separate or in a collection
for func in (:dms2rad, :dms2deg, :dms2ha, :hms2rad, :hms2deg, :hms2ha)
    @eval $func(parts) = $func(parts...)
end
