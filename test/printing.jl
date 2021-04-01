
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
