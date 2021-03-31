
const dms_re = r"([+-]?\d+\.?\d*)[°d:\s](\d+\.?\d*)['′m:\s](\d+\.?\d*)[\"″s]?"
const hms_re = r"([+-]?\d+\.?\d*)[h:\s](\d+\.?\d*)['′m:\s](\d+\.?\d*)[\"″s]?"

"""
    parse_dms(input)

Parses a string input in "deg:arcmin:arcsec" format to the tuple `(degrees, arcminutes, arcseconds)`. The following delimiters will all work and can be mixed together (the last delimiter is optional):
```
"xx[°d: ]xx['′m: ]xx[\\\"″s]"
```
"""
function parse_dms(input)
    m = match(dms_re, strip(input))
    m === nothing && error("Could not parse $input to sexagesimal")
    return map(c -> parse(Float64, c), Tuple(m.captures))
end

"""
    parse_hms(input)

Parses a string input in "ha:min:sec" format to the tuple `(hours, minutes, seconds)`. The following delimiters will all work and can be mixed together (the last delimiter is optional):
```
"xx[h ]xx['′m: ]xx[\\\"″s]"
```
"""
function parse_hms(input)
    m = match(hms_re, strip(input))
    m === nothing && error("Could not parse $input to hour angles")
    return map(c -> parse(Float64, c), Tuple(m.captures))
end

"""
    @dms_str

Parse a string in "deg:arcmin:arcsec" format directly to an angle. By default, it will be parsed as radians, but the angle can be chosen by adding a flag to the end of the string

* dms"..."rad -> radians (default)
* dms"..."deg -> degrees
* dms"..."ha -> hour angles

See also: [`parse_dms`](@ref)
"""
macro dms_str(input, flag="rad")
    dms = parse_dms(input)
    if flag === "rad"
        return dms2rad(dms)
    elseif flag === "deg"
        return dms2deg(dms)
    elseif flag === "ha"
        return dms2ha(dms)
    else
        error("angle type $flag not recognized. Choose between `deg`, `rad`, or `ha`")
    end
end

"""
    @hms_str

Parse a string in "ha:min:sec" format directly to an angle. By default, it will be parsed as radians, but the angle can be chosen by adding a flag to the end of the string

* hms"..."rad -> radians (default)
* hms"..."deg -> degrees
* hms"..."ha -> hour angles

See also: [`parse_hms`](@ref)
"""
macro hms_str(input, flag="rad")
    hms = parse_hms(input)
    if flag === "rad"
        return hms2rad(hms)
    elseif flag === "deg"
        return hms2deg(hms)
    elseif flag === "ha"
        return hms2ha(hms)
    else
        error("angle type $flag not recognized. Choose between `deg`, `rad`, or `ha`")
    end
end
