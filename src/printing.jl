"""
    format_angle(parts; delim = ':', digits = 2, pad = true, alwayssign = false)
    format_angle(parts...; kwargs...)

Format the parts of an angle into a delimited string. The parts are typically
the `(whole, minutes, seconds)` produced by the [`deg2dms`](@ref),
[`deg2hms`](@ref), [`rad2dms`](@ref), [`rad2hms`](@ref), [`ha2dms`](@ref), and
[`ha2hms`](@ref) methods, and may be passed either as a single tuple (or
vector) or as separate positional arguments.

Any number of parts is supported: every part except the last is formatted as a
whole number, and the last part keeps its fractional digits. This allows
extended sub-arcsecond splits like `(degrees, arcminutes, arcseconds, mas,
μas)` as well as partial splits like `(minutes, seconds)`. The sign of the
angle is taken from the first part, matching the convention of the conversion
methods above, which carry the sign only on their first part. For more control
over formatting, consider using
[Printf](https://docs.julialang.org/en/v1/stdlib/Printf/) or a package like
[Format.jl](https://github.com/JuliaString/Format.jl).

If any part is `missing`, returns `missing`.

# Keyword arguments
- `delim`: The delimiter(s) placed between the parts. A single `Char`/`String`
  (default `':'`) is inserted between each part, e.g. `"45:00:00.00"`. A vector
  or tuple with one delimiter per part is instead appended after each
  respective part, e.g., `delim = ["h", "m", "s"]` gives `"05h43m46.48s"`.
- `digits`: The number of digits to round the last part to (default `2`). Pass
  `0` to display it as a whole number, or `"all"` to keep full precision
  without rounding.
- `pad`: If `true` (default), zero-pad the whole-number portion of each part to
  at least two characters and the fractional digits of the last part to
  `digits`, e.g. `"03:00:00.00"`.
- `alwayssign`: If `true`, prefix non-negative angles with `'+'` (default
  `false`). Negative angles are always prefixed with `'-'`.

# Examples

```jldoctest
julia> ang = 45.0; # degrees

julia> format_angle(deg2dms(ang))
"45:00:00.00"

julia> format_angle(deg2hms(ang))
"03:00:00.00"

julia> format_angle(rad2hms(1.5), delim=["h", "m", "s"])
"05h43m46.48s"

julia> format_angle(rad2hms(1.5), delim=["h", "m", "s"]; digits=5)
"05h43m46.48062s"

julia> format_angle(rad2hms(1.5), delim=["h", "m", "s"]; digits="all")
"05h43m46.48062470963538s"

julia> format_angle(deg2dms(45.0); pad=false)
"45:0:0.0"

julia> format_angle(deg2dms(45.0); alwayssign=true)
"+45:00:00.00"

julia> format_angle(deg2dms(-45.0); alwayssign=true)
"-45:00:00.00"

julia> format_angle((23, 33.6), delim=["ᵐ", "ˢ"]) # partial split
"23ᵐ33.60ˢ"

julia> format_angle((58, 48, 12.0), delim=["°", "′", "″"]; digits=0)
"58°48′12″"
```

# See also
[`deg2dms`](@ref), [`deg2hms`](@ref), [`rad2dms`](@ref), [`rad2hms`](@ref), [`ha2dms`](@ref), [`ha2hms`](@ref)
"""
format_angle(angle; delim = ':', kwargs...) = format_angle(angle, delim; kwargs...)
format_angle(part1::Real, rest::Vararg{Union{Real, Missing}}; kwargs...) = format_angle((part1, rest...); kwargs...)
format_angle(::Missing; kwargs...) = missing
format_angle(::Missing, args...; kwargs...) = missing
# Disambiguate a `missing` angle against the typed `delim` methods above so
# `format_angle(missing, delim)` is not an ambiguous call (see Aqua tests).
format_angle(::Missing, ::Union{<:AbstractString, Char}; kwargs...) = missing
format_angle(::Missing, ::Union{<:AbstractVector, <:Tuple}; kwargs...) = missing

# A scalar delimiter is inserted between the parts.
function format_angle(angle, delim::Union{<:AbstractString, Char}; kwargs...)
    formatted = _format_angle_parts(angle; kwargs...)
    formatted === missing && return missing
    sgn, strs = formatted
    return string(sgn, join(strs, delim))
end

# A collection of delimiters is appended after each respective part, and must
# therefore contain exactly one delimiter per part.
function format_angle(angle, delim::Union{<:AbstractVector, <:Tuple}; kwargs...)
    formatted = _format_angle_parts(angle; kwargs...)
    formatted === missing && return missing
    sgn, strs = formatted
    length(delim) == length(strs) || throw(
        ArgumentError(
            "delimiter collection must have one delimiter per angle part ($(length(strs))), got $(length(delim))"
        )
    )
    return string(sgn, join(string.(strs, delim)))
end

function _format_angle_parts(angle; digits::Union{Int, String} = 2, pad::Bool = true, alwayssign::Bool = false)
    parts = Tuple(angle)
    n = length(parts)
    n >= 1 || throw(ArgumentError("angle must have at least one part"))
    any(ismissing, parts) && return missing

    sgn = signbit(first(parts)) ? '-' : (alwayssign ? '+' : "")

    strs = Vector{String}(undef, n)
    # Every part except the last is a whole number. The sign is handled
    # separately via `sgn`.
    for i in 1:(n - 1)
        v = trunc(Int, i == 1 ? abs(parts[i]) : parts[i])
        strs[i] = pad ? lpad(v, 2, "0") : string(v)
    end
    val = n == 1 ? abs(parts[n]) : parts[n]
    val = digits == "all" ? val : digits == 0 ? round(Int, val) : round(val; digits)
    str = string(val)
    if pad
        intfrac = split(str, '.')
        str = lpad(intfrac[1], 2, "0")
        if length(intfrac) == 2
            # Fractional digits are padded on the right, e.g. 30.5 -> "30.50"
            frac = digits isa Int ? rpad(intfrac[2], digits, "0") : intfrac[2]
            str *= "." * frac
        end
    end
    strs[n] = str

    return sgn, strs
end
