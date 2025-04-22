@testset "printing" begin
    angle = 45.0

    str = format_angle(deg2dms(angle))
    @test str == "45:0:0.0"
    strd = format_angle(deg2hms(angle), delim=["d", "m", "s"])
    @test strd == "3d0m0.0s"
    @test_throws BoundsError format_angle(deg2dms(angle), delim=(':', ' '))
end

function test_print_integration(angles, f1, f2)
    @test all(angles) do angle
        parts = f1(angle)
        str = format_angle(parts)
        res = f2(str)
        return all(res .≈ parts)
    end

    @test all(angles) do angle
        parts = f1(angle)
        str = format_angle(parts, delim=" ")
        res = f2(str)
        return all(res .≈ parts)
    end

    @test all(angles) do angle
        parts = f1(angle)
        str = format_angle(parts, delim=(":", "m", ""))
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
    @test format_angle(parse_dms("-0:0:1.0")) == "-0:0:1.0"
    @test format_angle(parse_hms("-0:0:1.0")) == "-0:0:1.0"
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
