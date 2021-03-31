
const dms_re = r"([+-]?\d+\.?\d*)[°d:\s](\d+\.?\d*)['′m:\s](\d+\.?\d*)[\"″s]?"
const hms_re = r"([+-]?\d+\.?\d*)[h:\s](\d+\.?\d*)['′m:\s](\d+\.?\d*)[\"″s]?"

"""
    parse_dms(input)
"""
function parse_dms(input)
    m = match(dms_re, input)
    m === nothing && error("Could not parse $input to sexagesimal")
    return map(c -> parse(Float64, c), m.captures)
end

"""
    parse_hms(input)
"""
function parse_hms(input)
    m = match(hms_re, input)
    m === nothing && error("Could not parse $input to hour angles")
    return map(c -> parse(Float64, c), m.captures)
end

"""
    dms_str(input)
"""
macro dms_str(input)
    dms = parse_dms(input)
    return dms2rad(dms)
end

"""
    hms_str(input)
"""
macro hms_str(input)
    hms = parse_hms(input)
    return hms2rad(hms)
end
