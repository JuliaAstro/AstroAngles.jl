@testset "printing" begin
    angle = 45.0

    str = format_angle(deg2dms(angle))
    @test str == "45:00:00.00"
    # three-argument form: parts passed positionally rather than as a tuple
    @test format_angle(45, 0, 0.0) == format_angle(deg2dms(angle))
    strd = format_angle(deg2hms(angle), delim = ["d", "m", "s"]; pad = true)
    @test strd == "03d00m00.00s"
    @test_throws ArgumentError format_angle(deg2dms(angle), delim = (':', ' '))
    @test_throws ArgumentError format_angle(deg2dms(angle), delim = (':', ' ', 'x', 'y'))
    err = try
        format_angle(deg2dms(angle), delim = (':', ' '))
    catch e
        e
    end
    @test occursin("one delimiter per angle part (3), got 2", err.msg)
end

function test_print_integration(angles, f1, f2)
    @test all(angles) do angle
        parts = f1(angle)
        str = format_angle(parts, digits = "all")
        res = f2(str)
        return all(res .≈ parts)
    end

    @test all(angles) do angle
        parts = f1(angle)
        str = format_angle(parts, delim = " ", digits = "all")
        res = f2(str)
        return all(res .≈ parts)
    end

    return @test all(angles) do angle
        parts = f1(angle)
        str = format_angle(parts, delim = (":", "m", ""), digits = "all")
        res = f2(str)
        return all(res .≈ parts)
    end
end

@testset "printing integration" begin
    degrees = randdegree(rng, 100)
    test_print_integration(degrees, deg2dms, parse_dms)

    radians = randrad(rng, 100)
    test_print_integration(radians, rad2dms, parse_dms)

    has = randha(rng, 100)
    test_print_integration(has, ha2dms, parse_dms)
end

@testset "negatives" begin
    # negative zero — sign only from sgn (whole=0 has no intrinsic sign)
    @test format_angle(parse_dms("-0:0:1.0")) == "-00:00:01.00"
    @test format_angle(parse_hms("-0:0:1.0")) == "-00:00:01.00"
    # real negatives with single delim — must NOT produce double minus
    @test format_angle(deg2dms(-45.0)) == "-45:00:00.00"
    @test format_angle(deg2hms(-65.0)) == "-04:19:60.00"
    # real negatives with multi-delim
    @test format_angle(deg2hms(-65.0), delim = ["h", "m", "s"]) == "-04h19m60.00s"
    # negative without pad — no double minus
    @test format_angle(deg2dms(-45.0); pad = false) == "-45:0:0.0"
    # negative near zero with pad -- sign on zero-padded degrees
    @test format_angle(deg2dms(-0.5); pad = true) == "-00:30:00.00"
    # alwayssign
    @test format_angle(deg2dms(45.0); alwayssign = true) == "+45:00:00.00"
    @test format_angle(deg2dms(-45.0); alwayssign = true) == "-45:00:00.00"
    @test format_angle(deg2dms(0.5); alwayssign = true, pad = true) == "+00:30:00.00"
end

@testset "missing value handling in printing" begin
    # Test with missing value
    @test ismissing(format_angle(missing))

    # Test with missing value and keyword delimiter
    @test ismissing(format_angle(missing, delim = ":"))
    @test ismissing(format_angle(missing, delim = [" ", ":", ""]))

    # Test with missing value and positional delimiter (single and 3-part)
    @test ismissing(format_angle(missing, ':'))
    @test ismissing(format_angle(missing, ":"))
    @test ismissing(format_angle(missing, [" ", ":", ""]))
    @test ismissing(format_angle(missing, ("h", "m", "s")))

    # Test with tuple form
    @test ismissing(format_angle(missing, missing, missing))

    # Test with partially missing values
    @test ismissing(format_angle(missing, 2.39, "15"))

    # A missing part anywhere returns missing (not just in first position)
    @test ismissing(format_angle(2.39, missing, 15))
    @test ismissing(format_angle((1, missing, 3.0)))
    @test ismissing(format_angle((1, 2, missing), delim = ["h", "m", "s"]))
end

@testset "fractional digit padding" begin
    # Fractional digits are padded on the right: 30.5 is 30.50, not 30.05
    @test format_angle((10, 20, 30.5)) == "10:20:30.50"
    @test format_angle((10, 20, 30.05)) == "10:20:30.05"
    @test format_angle((10, 20, 30.5); digits = 4) == "10:20:30.5000"
    # Unpadded values keep their natural representation
    @test format_angle((10, 20, 30.5); pad = false) == "10:20:30.5"
end

@testset "variable-length parts" begin
    # Partial splits, e.g. (minutes, seconds)
    @test format_angle((23, 33.6), delim = ["ᵐ", "ˢ"]) == "23ᵐ33.60ˢ"
    @test format_angle(23, 33.6) == "23:33.60"

    # Extended sub-arcsecond splits, e.g. (deg, arcmin, arcsec, mas, μas)
    @test format_angle((58, 48, 12, 345, 200.0), delim = ["°", "'", "\"", "mas", "μas"]) ==
        "58°48'12\"345mas200.00μas"

    # Single part
    @test format_angle((45.671,)) == "45.67"
    @test format_angle(-45.671) == "-45.67"
    # A single-element delimiter collection is still appended (not treated as
    # a between-parts separator, which would drop it)
    @test format_angle((33.6,), delim = ["ˢ"]) == "33.60ˢ"

    # digits=0 displays the last part as a whole number
    @test format_angle((58, 48, 12.0), delim = ["°", "′", "″"], digits = 0) == "58°48′12″"

    # Sign is taken from the first part only
    @test format_angle((-45, 30, 10, 5, 2.0), delim = ["°", "'", "\"", "mas", "μas"]) ==
        "-45°30'10\"05mas02.00μas"

    # Delimiter collections must have one delimiter per part
    @test_throws ArgumentError format_angle((1, 2, 3, 4.0), delim = ["a", "b", "c"])
    err = try
        format_angle((1, 2, 3, 4.0), delim = ["a", "b", "c"])
    catch e
        e
    end
    @test occursin("one delimiter per angle part (4), got 3", err.msg)
end
