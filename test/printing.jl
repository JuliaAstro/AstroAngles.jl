@testset "printing" begin
    angle = 45.0

    str = format_angle(deg2dms(angle))
    @test str == "45:0:0.0"
    strd = format_angle(deg2hms(angle), delim=["d", "m", "s"]; pad=true)
    @test strd == "03d00m00.00s"
    @test_throws ArgumentError format_angle(deg2dms(angle), delim=(':', ' '))
    @test_throws ArgumentError format_angle(deg2dms(angle), delim=(':', ' ', 'x', 'y'))
    err = try format_angle(deg2dms(angle), delim=(':', ' ')) catch e; e end
    @test occursin("1 or 3", err.msg)
end

function test_print_integration(angles, f1, f2)
    @test all(angles) do angle
        parts = f1(angle)
        str = format_angle(parts, digits="all")
        res = f2(str)
        return all(res .≈ parts)
    end

    @test all(angles) do angle
        parts = f1(angle)
        str = format_angle(parts, delim=" ", digits="all")
        res = f2(str)
        return all(res .≈ parts)
    end

    @test all(angles) do angle
        parts = f1(angle)
        str = format_angle(parts, delim=(":", "m", ""), digits="all")
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
    @test format_angle(parse_dms("-0:0:1.0")) == "-0:0:1.0"
    @test format_angle(parse_hms("-0:0:1.0")) == "-0:0:1.0"
    # real negatives with single delim — must NOT produce double minus
    @test format_angle(deg2dms(-45.0)) == "-45:0:0.0"
    @test format_angle(deg2hms(-65.0)) == "-4:19:60.0"
    # real negatives with multi-delim
    @test format_angle(deg2hms(-65.0), delim=["h", "m", "s"]) == "-4h19m60.0s"
    # negative with pad — no double minus
    @test format_angle(deg2dms(-45.0); pad=true) == "-45:00:00.00"
    # negative near zero with pad -- sign on zero-padded degrees
    @test format_angle(deg2dms(-0.5); pad=true) == "-00:30:00.00"
    # alwayssign
    @test format_angle(deg2dms(45.0); alwayssign=true) == "+45:0:0.0"
    @test format_angle(deg2dms(-45.0); alwayssign=true) == "-45:0:0.0"
    @test format_angle(deg2dms(0.5); alwayssign=true, pad=true) == "+00:30:00.00"
end

@testset "missing value handling in printing" begin
    # Test with missing value
    @test ismissing(format_angle(missing))

    # Test with missing value and delimiter
    @test ismissing(format_angle(missing, delim=":"))
    @test ismissing(format_angle(missing, delim=[" ", ":", ""]))

    # Test with tuple form
    @test ismissing(format_angle(missing, missing, missing))

    # Test with partially missing values
    @test ismissing(format_angle(missing, 2.39, "15"))
end
