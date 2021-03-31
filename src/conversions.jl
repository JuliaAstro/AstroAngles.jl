##
## Angle Conversions
##

const HOURS_PER_DEGREE = 24 / 360
const HOURS_PER_RADIAN = 24 / 2π

"""
    rad2ha(angle)
"""
rad2ha(angle) = angle * HOURS_PER_RADIAN

"""
    deg2ha(angle)
"""
deg2ha(angle) = angle * HOURS_PER_DEGREE

"""
    rad2dms(angle)
"""
rad2dms(angle) = (deg2dms ∘ rad2deg)(angle)

"""
    rad2hms(angle)
"""
rad2hms(angle) = (ha2hms ∘ rad2ha)(angle)

"""
    deg2dms(angle)
"""
function deg2dms(angle)
    remain_degrees, degrees = modf(angle)
    fraction_arcmin = remain_degrees * 60
    remain_arcmin, arcmin = modf(fraction_arcmin)
    arcsec = remain_arcmin * 60
    return degrees, arcmin, arcsec
end

"""
    deg2hms(angle)
"""
deg2hms(angle) = (ha2hms ∘ deg2ha)(angle)

"""
    ha2hms(angle)
"""
function ha2hms(angle)
    remain_hours, hours = modf(angle)
    fraction_min = remain_hours * 60
    remain_min, minutes = modf(fraction_min)
    seconds = remain_min * 60
    return hours, minutes, seconds
end
