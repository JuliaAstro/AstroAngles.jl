
const dms_re = r"([+-]?\s?\d+\.?\d*)[°d:\s](\d+\.?\d*)['m:\s](\d+\.?\d*)[\"s]?"
const hms_re = r"([+-]?\s?\d+\.?\d*)[h:\s](\d+\.?\d*)['m:\s](\d+\.?\d*)[\"s]?"

"""
    parse_dms(input)

Parses a string input in "deg:arcmin:arcsec" format to the tuple `(degrees, arcminutes, arcseconds)`. The following delimiters will all work and can be mixed together (the last delimiter is optional):
```
"[+-]xx[°d: ]xx['m: ]xx[\\\"s]"
```
"""
function parse_dms(input)
    m = match(dms_re, strip(input))
    m === nothing && error("Could not parse \"$input\" to sexagesimal")
    deg = parse(Float64, filter(!isspace, m.captures[1]))
    min = parse(Float64, m.captures[2])
    sec = parse(Float64, m.captures[3])
    return deg, min, sec
end

"""
    parse_hms(input)

Parses a string input in "ha:min:sec" format to the tuple `(hours, minutes, seconds)`. The following delimiters will all work and can be mixed together (the last delimiter is optional):
```
"[+-]xx[h ]xx['m: ]xx[\\\"s]"
```
"""
function parse_hms(input)
    m = match(hms_re, strip(input))
    m === nothing && error("Could not parse \"$input\" to hour angles")
    ha = parse(Float64, filter(!isspace, m.captures[1]))
    min = parse(Float64, m.captures[2])
    sec = parse(Float64, m.captures[3])
    return ha, min, sec
end

"""
    @dms_str

Parse a string in "deg:arcmin:arcsec" format directly to an angle. By default, it will be parsed as radians, but the angle can be chosen by adding a flag to the end of the string

* dms"..."rad -> radians (default)
* dms"..."deg -> degrees
* dms"..."ha -> hour angles

# Examples
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

# See also
[`parse_dms`](@ref)
"""
macro dms_str(input, flag="rad")
    if flag === "rad"
        return dms2rad(input)
    elseif flag === "deg"
        return dms2deg(input)
    elseif flag === "ha"
        return dms2ha(input)
    else
        err = ArgumentError("angle type $flag not recognized. Choose between `deg`, `rad`, or `ha`")
        return :(throw($err))
    end
end

"""
    @hms_str

Parse a string in "ha:min:sec" format directly to an angle. By default, it will be parsed as radians, but the angle can be chosen by adding a flag to the end of the string

* hms"..."rad -> radians (default)
* hms"..."deg -> degrees
* hms"..."ha -> hour angles

# Examples
```jldoctest
julia> hms"12:17:25.3"
3.2176090147193626

julia> hms"12:17:25.3"rad # default
3.2176090147193626

julia> hms"12:17:25.3"deg
184.35541666666666

julia> hms"12:17:25.3"ha
12.29036111111111
```

# See also
[`parse_hms`](@ref)
"""
macro hms_str(input, flag="rad")
    if flag === "rad"
        return hms2rad(input)
    elseif flag === "deg"
        return hms2deg(input)
    elseif flag === "ha"
        return hms2ha(input)
    else
        err = ArgumentError("angle type $flag not recognized. Choose between `deg`, `rad`, or `ha`")
        return :(throw($err))
    end
end
