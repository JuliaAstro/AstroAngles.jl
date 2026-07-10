# A sexagesimal string is matched as up to three `value(delimiter)` pairs,
# preceded by an optional sign and followed by an optional direction.
# Capturing the delimiter that trails *each* value lets us route unit-tagged values
# (e.g. the arcminutes in `"2m3s"`) to the correct component instead of reading them positionally.
# The trailing delimiter/value groups are optional, so only the first value is required.
# The whole string is anchored so trailing junk (or more than three values) is rejected rather than silently ignored.
const _num = raw"\d+\.?\d*" # x.xx decimal number (no sign)
const _val = "($_num)"
const _dms_delim = "([°d'm′\"″s:\\s])" # deg/arcmin/arcsec unit or separator
const _hms_delim = "([h'm′\"″s:\\s])" # hour/min/sec unit or separator
const dms_re = Regex("^([+-]?)\\s?$_val$_dms_delim?(?:$_val$_dms_delim?)?(?:$_val$_dms_delim?)?(N|E|S|W)?\$")
const hms_re = Regex("^([+-]?)\\s?$_val$_hms_delim?(?:$_val$_hms_delim?)?(?:$_val$_hms_delim?)?(N|E|S|W)?\$")

# Delimiter characters that force a value into a particular component.
# The "whole" units differ between dms (`°`, `d`) and hms (`h`); the rest are shared.
const _MIN_UNITS = ('\'', 'm', '′')
const _SEC_UNITS = ('"', '″', 's')

# Classify a trailing delimiter into the component (1=whole, 2=min, 3=sec)
# it pins its value to. `:` and whitespace (and an empty/absent delimiter)
# are ambiguous, so they return `nothing` and the value is placed positionally.
function _slot(delim, whole_units)
    (delim === nothing || isempty(delim)) && return nothing
    c = first(delim)
    c in whole_units && return 1
    c in _MIN_UNITS && return 2
    c in _SEC_UNITS && return 3
    return nothing
end

# Assemble the captured (value, delimiter) pairs into `(whole, min, sec)`.
# Unit-tagged values go to their component; ambiguous ones fill the next open component in order.
# A value that would land in an earlier component than a previous one (e.g. `"3s2m"`)
# is out of order and raises an informative error.
function _assemble(captures, whole_units, input, kind, order)
    parts = [0.0, 0.0, 0.0]
    next = 1 # Lowest component index the next value may occupy
    for (value, delim) in (
            (captures[2], captures[3]),
            (captures[4], captures[5]),
            (captures[6], captures[7]),
        )
        value === nothing && continue
        idx = something(_slot(delim, whole_units), next)
        idx < next && throw(
            ArgumentError(
                "could not parse \"$input\" as $kind: components are out of order " *
                    "(expected $order)"
            )
        )
        parts[idx] = parse(Float64, value)
        next = idx + 1
    end
    # Sign lives on the whole component (matching `dms2deg`/`hms2deg`, which read
    # it via `signbit`); `-parts[1]` yields `-0.0` when the whole part is absent.
    # A "S"/"W" direction negates, so it cancels an explicit leading "-".
    negative = (captures[1] == "-") ⊻ (captures[8] == "S" || captures[8] == "W")
    negative && (parts[1] = -parts[1])
    return parts[1], parts[2], parts[3]
end

"""
    parse_dms(input)

Parse a string in "deg:arcmin:arcsec" format to the tuple `(degrees, arcminutes, arcseconds)`.
The following delimiters all work and may be mixed together (the final delimiter is optional):

```
"[+-]xx[°d: ]xx['′m: ]xx[\\\"″s][NESW]"
```

A value carrying an arcminute (`'`, `′`, `m`) or arcsecond (`"`, `″`, `s`)
unit is placed in that component rather than being read positionally, so `"2m3s"`
parses as two arcminutes plus three arcseconds.
Values separated by ambiguous delimiters (`:` or whitespace) fill the components positionally.
Components given out of order (e.g. `"3s2m"`) raise an `ArgumentError`.

If the direction is provided, "S" and "W" are considered negative (so `"-1:0:0S"` is 1 degree North).

If `input` is `Missing`, returns `missing`.

# Examples

```jldoctest
julia> parse_dms("12:17:25.3")
(12.0, 17.0, 25.3)

julia> parse_dms("1'")
(0.0, 1.0, 0.0)

julia> parse_dms("2m3s")
(0.0, 2.0, 3.0)
```
"""
function parse_dms(input)
    m = match(dms_re, strip(input))
    m === nothing && throw(
        ArgumentError(
            "could not parse \"$input\" as a sexagesimal (deg, arcmin, arcsec) angle"
        )
    )
    return _assemble(
        m.captures, ('°', 'd'), input,
        "a sexagesimal (deg, arcmin, arcsec) angle", "degrees, then arcminutes, then arcseconds"
    )
end

parse_dms(::Missing) = missing

"""
    parse_hms(input)

Parse a string in "hour:min:sec" format to the tuple `(hours, minutes, seconds)`.
The following delimiters all work and may be mixed together (the final delimiter is optional):

```
"[+-]xx[h ]xx['′m: ]xx[\\\"″s][EW]"
```

As with [`parse_dms`](@ref), a value carrying a minute (`'`, `′`, `m`) or second
(`"`, `″`, `s`) unit is placed in that component rather than positionally, values
separated by ambiguous delimiters fill positionally, and components given out of
order raise an `ArgumentError`.

If the direction is provided, "S" and "W" are considered negative (so `"-1:0:0W"`
is 1 hour East).

If `input` is `Missing`, returns `missing`.
"""
function parse_hms(input)
    m = match(hms_re, strip(input))
    m === nothing && throw(
        ArgumentError(
            "could not parse \"$input\" as an hour-angle (hour, min, sec) value"
        )
    )
    return _assemble(
        m.captures, ('h',), input,
        "an hour-angle (hour, min, sec) value", "hours, then minutes, then seconds"
    )
end

parse_hms(::Missing) = missing

"""
    @dms_str

Parse a string in `"deg:arcmin:arcsec"` format directly to an angle.
By default, it will be parsed as radians, but the angle can be chosen by adding a flag to the end of the string.

- `dms"..."rad` --> radians (default)
- `dms"..."deg` --> degrees
- `dms"..."ha` --> hour angles

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
macro dms_str(input, flag = "rad")
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

Parse a string in `"ha:min:sec"` format directly to an angle. By default, it will
be parsed as radians, but the angle can be chosen by adding a flag to the end of the string.

* `hms"..."rad` --> radians (default)
* `hms"..."deg` --> degrees
* `hms"..."ha` --> hour angles

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
macro hms_str(input, flag = "rad")
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
