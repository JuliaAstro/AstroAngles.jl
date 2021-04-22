
num = raw"\d+\.?\d*" # x.xx decimal number
first = "([+-]?\\s?$num)" # leading digit is required, can have +- with 1 space
deg_delims = join(("°", "d", ":", raw"\s"), "|") # only for dms
ha_delims = join(("h", ":", raw"\s"), "|") # only for hms
min_delims = join(("'", "m", ":", "′", raw"\s"), "|") # shared
sec_delims = join(("\"", "″", "s", raw"\s"), "") # shared
dms_dirs = join(("N", "S"), "|") # positive first
hms_dirs = join(("E", "W"), "|")
# the (?:) groups are non capturing, so we don't have to do special substring indexing
# the trailing ()? groups are optional, so only leading digit is required
const dms_re = Regex("$first(?:$deg_delims)?($num)?(?:$min_delims)?($num)?[$sec_delims]?($dms_dirs)?")
const hms_re = Regex("$first(?:$ha_delims)?($num)?(?:$min_delims)?($num)?[$sec_delims]?($hms_dirs)?")


# const dms_re = r"([+-]?\s?\d+\.?\d*)(?:°|d|:|\s)?(\d+\.?\d*)?(?:'|m|:|′|\s)?(\d+\.?\d*)?[\"″s]?(N|S)?"
# const hms_re = r"([+-]?\s?\d+\.?\d*)(?:h|:|\s|)?(\d+\.?\d*)?(?:'|m|:|′|\s)?(\d+\.?\d*)?[\"″s]?(E|W)?"

"""
    parse_dms(input)

Parses a string input in "deg:arcmin:arcsec" format to the tuple `(degrees, arcminutes, arcseconds)`. The following delimiters will all work and can be mixed together (the last delimiter is optional):
```
"[+-]xx[°d: ]xx['′m: ]xx[\\\"″s][NS]"
```
if the direction ("N" or "S") is provided, "S" is considered negative (and "-1:0:0S" is 1 degree North)
"""
function parse_dms(input)
    m = match(dms_re, strip(input))
    m === nothing && error("Could not parse \"$input\" to sexagesimal")
    deg = parse(Float64, filter(!isspace, m.captures[1]))
    if m.captures[2] !== nothing
        min = parse(Float64, m.captures[2])
    else
        min = 0.0
    end
    if m.captures[3] !== nothing
        sec = parse(Float64, m.captures[3])
    else
        sec = 0.0
    end
    if m.captures[4] !== nothing
        if m.captures[4] == "S"
            deg = -deg
        end
    end
    return deg, min, sec
end

"""
    parse_hms(input)

Parses a string input in "ha:min:sec" format to the tuple `(hours, minutes, seconds)`. The following delimiters will all work and can be mixed together (the last delimiter is optional):
```
"[+-]xx[h ]xx['′m: ]xx[\\\"″s][EW]"
```
if the direction ("E" or "W") is provided, "W" is considered negative (and "-1:0:0W" is 1 degree East)
"""
function parse_hms(input)
    m = match(hms_re, strip(input))
    m === nothing && error("Could not parse \"$input\" to hour angles")
    ha = parse(Float64, filter(!isspace, m.captures[1]))
    if m.captures[2] !== nothing
        min = parse(Float64, m.captures[2])
    else
        min = 0.0
    end
    if m.captures[3] !== nothing
        sec = parse(Float64, m.captures[3])
    else
        sec = 0.0
    end
    if m.captures[4] !== nothing
        if m.captures[4] == "W"
            ha = -ha
        end
    end
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
