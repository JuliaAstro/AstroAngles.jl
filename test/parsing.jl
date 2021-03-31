
@testset "parsing" begin
    @test all(randdms(rng, 1000)) do dms
        d, m, s = dms
        str = "$(Int(d)):$(Int(m)):$s"
        res = parse_dms(str)
        all(dms .≈ res)
    end

    @test all(randhms(rng, 1000)) do hms
        h, m, s = hms
        str = "$(Int(h)):$(Int(m)):$s"
        res = parse_hms(str)
        all(hms .≈ res)
    end
end

@testset "macros" begin
    str = "12:37:34.2344"
    dms = parse_dms(str)
    @test dms"12:37:34.2344" == dms"12:37:34.2344"rad ≈ dms2rad(dms)
    @test dms"12:37:34.2344"deg ≈ dms2deg(dms)
    @test dms"12:37:34.2344"ha ≈ dms2ha(dms)

    hms = parse_hms(str)
    @test hms"12:37:34.2344" == hms"12:37:34.2344"rad ≈ hms2rad(dms)
    @test hms"12:37:34.2344"deg ≈ hms2deg(dms)
    @test hms"12:37:34.2344"ha ≈ hms2ha(dms)
end