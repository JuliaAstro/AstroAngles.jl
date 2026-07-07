"""
    format_angle(parts; delim = ':', digits = 2, pad = true, alwayssign = false)
    format_angle(whole, minutes, seconds; kwargs...)

Format the `(whole, minutes, seconds)` `parts` of an angle into a delimited
string. The parts are typically produced by the [`deg2dms`](@ref),
[`deg2hms`](@ref), [`rad2dms`](@ref), [`rad2hms`](@ref), [`ha2dms`](@ref), and
[`ha2hms`](@ref) methods, and may be passed either as a single tuple or as three
separate positional arguments. For more control over formatting, consider using
[Printf](https://docs.julialang.org/en/v1/stdlib/Printf/) or a package like
[Format.jl](https://github.com/JuliaString/Format.jl).

If any part is `missing`, returns `missing`.

# Keyword arguments
- `delim`: The delimiter(s) placed between the parts. A single `Char`/`String`
  (default `':'`) is inserted between each part, e.g. `"45:00:00.00"`. A vector
  or tuple of three delimiters is instead appended after each respective part,
  e.g., `delim = ["h", "m", "s"]` gives `"05h43m46.48s"`. Only 1 or 3 delimiters
  are accepted.
- `digits`: The number of digits to round the seconds to (default `2`). Pass
  `"all"` to keep full precision without rounding.
- `pad`: If `true` (default), zero-pad each part to at least two characters,
  e.g. `"03:00:00.00"`.
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
```

# See also
[`deg2dms`](@ref), [`deg2hms`](@ref), [`rad2dms`](@ref), [`rad2hms`](@ref), [`ha2dms`](@ref), [`ha2hms`](@ref)
"""
format_angle(angle; delim=':', kwargs...) = format_angle(angle, delim; kwargs...)
format_angle(angle, delim::Union{<:AbstractString, Char}; kwargs...) = format_angle(angle, [delim]; kwargs...)
format_angle(w, m, s; kwargs...) = format_angle((w, m, s); kwargs...)
format_angle(::Missing; kwargs...) = missing
format_angle(::Missing, args...; kwargs...) = missing

function format_angle(angle, delim::Union{<:AbstractVector, <:Tuple}; digits::Union{Int, String}=2, pad::Bool=true, alwayssign::Bool=false)
    whole, min, sec, delim = angle..., delim
    length(delim) in (1, 3) || throw(ArgumentError(
        "delimiter must have 1 or 3 elements, got $(length(delim))"))
    sgn = signbit(whole) ? '-' : (alwayssign ? '+' : "")

    whole, min = trunc.(Int, (whole, min))
    whole = abs(whole)  # sign handled separately via sgn
    sec = digits == "all" ? sec : round(sec; digits)
    if pad
      whole, min = lpad.((whole, min), 2, "0")
      sec = join(lpad.(split("$sec", "."), 2, "0"), ".")
    end

    angle = string.((whole, min, sec))
    printout = if length(delim) == 1
        join(angle, delim[begin])
    else
        string(angle[1], delim[1], angle[2], delim[2], angle[3], delim[3])
    end
    return string(sgn, printout...)
end
