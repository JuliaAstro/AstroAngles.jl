
num = raw"\d+\.?\d*" # x.xx decimal number
first = "([+-]?\\s?$num)" # leading digit is required, can have +- with 1 space
deg_delims = "[°d:\\s]" # only for dms
ha_delims = "[h:\\s]" # only for hms
min_delims = "['m:′\\s]" # shared
sec_delims = "[\"″s\\s]" # shared
dirs = "(N|E|S|W)" # positive first
# the trailing ()? groups are optional, so only leading digit is required
const ha_re =  Regex("($num)$ha_delims")
const deg_re = Regex("($num)$deg_delims")
const min_re = Regex("($num)$min_delims")
const sec_re = Regex("($num)$sec_delims?")
const dir_re = Regex("$dirs")
const sgn_re = Regex("([+-])")
const hms_re = Regex("$first$ha_delims?($num)?$min_delims?($num)?$sec_delims?$dirs?")

"""
    parse_dms(input)

Parses a string input in "deg:arcmin:arcsec" format to the tuple `(degrees, arcminutes, arcseconds)`. The following delimiters will all work and can be mixed together (the last delimiter is optional):
```
"[+-]xx[°d: ]xx['′m: ]xx[\\\"″s][NESW]"
```
if the direction is provided, "S" and "E" are considered negative (and "-1:0:0S" is 1 degree North)
"""
function parse_dms(input)
    input = strip(input)
    idx = 1
    m_sgn = match(sgn_re, input, idx)
    !isnothing(m_sgn) && (idx += length(m_sgn.match))
    m_deg = match(deg_re, input, idx)
    !isnothing(m_deg) && (idx += length(m_deg.match))
    m_min = match(min_re, input, idx)
    !isnothing(m_min) && (idx += length(m_min.match))
    m_sec = match(sec_re, input, idx)
    !isnothing(m_sec) && (idx += length(m_sec.match))
    m_dir = match(dir_re, input, idx)
    all(isnothing.((m_deg, m_min, m_sec))) && error("Could not parse \"$input\" to sexagesimal")
    deg = _num_parse(m_deg)
    min = _num_parse(m_min)
    sec = _num_parse(m_sec)
    sgn = _dir_parse(m_dir) * _sgn_parse(m_sgn)
    return sgn*deg, sgn*min, sgn*sec
end

# helper functions for parsing
_num_parse(m) = isnothing(m) ? 0.0 : parse(Float64, m.captures[1])
_sgn_parse(m) = (!isnothing(m) && (m.captures[1] == "-")) ? -1 : 1
_dir_parse(m) = (!isnothing(m) && (m.captures[1] ∈ ("S", "W"))) ? -1 : 1

"""
    parse_hms(input)

Parses a string input in "ha:min:sec" format to the tuple `(hours, minutes, seconds)`. The following delimiters will all work and can be mixed together (the last delimiter is optional):
```
"[+-]xx[h ]xx['′m: ]xx[\\\"″s][EW]"
```
if the direction is provided, "S" and "E" are considered negative (and "-1:0:0W" is 1 degree East)
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
    if m.captures[4] == "S" || m.captures[4] == "W"
        ha = -ha
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
