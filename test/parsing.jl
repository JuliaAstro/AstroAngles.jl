
DMS_FSTRINGS = FormatExpr.([
    "{1:d} {2:d} {3}",
    "{1:d}:{2:d}:{3}",
    "{1:d}d{2:d}m{3}s",
    "{1:d}°{2:d}'{3}\"",
    "{1:d}°{2:d}′{3}″",
    "{1:d} {2:d}:{3}"
])

HMS_FSTRINGS = FormatExpr.([
    "{1:d} {2:d} {3}",
    "{1:d}:{2:d}:{3}",
    "{1:d}h{2:d}m{3}s",
    "{1:d}h{2:d}'{3}\"",
    "{1:d}h{2:d}′{3}″",
    "{1:d} {2:d}:{3}"
])

@testset "parsing" for fstring in DMS_FSTRINGS
    @test all(randdms(rng, 1000)) do dms
        d, m, s = dms
        str = format(fstring, d, m, s)
        res = parse_dms(str)
        return all(dms .≈ res)
    end

    @test all(randdms(rng, 1000)) do dms
        d, m, s = dms
        str = format(fstring, d, m, s)
        t1 = dms2rad(str) == parse_dms(str) |> dms2rad
        t2 = dms2deg(str) == parse_dms(str) |> dms2deg
        t3 = dms2ha(str) == parse_dms(str) |> dms2ha
        return t1 && t2 && t3
    end
end

@testset "no-ops" begin
    val = randn(rng)
    @test dms2rad(val) === val
    @test dms2deg(val) === val
    @test dms2ha(val) === val
    @test hms2rad(val) === val
    @test hms2deg(val) === val
    @test hms2ha(val) === val
end

@testset "parsing" for fstring in HMS_FSTRINGS
    @test all(randhms(rng, 1000)) do hms
        h, m, s = hms
        str = format(fstring, h, m, s)
        res = parse_hms(str)
        return all(hms .≈ res)
    end

    @test all(randhms(rng, 1000)) do hms
        h, m, s = hms
        str = format(fstring, h, m, s)
        t1 = hms2rad(str) == parse_hms(str) |> hms2rad
        t2 = hms2deg(str) == parse_hms(str) |> hms2deg
        t3 = hms2ha(str) == parse_hms(str) |> hms2ha
        return t1 && t2 && t3
    end
end
# test-macro-throws
# https://discourse.julialang.org/t/exceptions-in-macros-in-julia-0-7-1-0/14145/2
macro tmt(typ,expr)
    quote
       @test_throws $typ begin
          try
             $expr
          catch e
             rethrow(e.error)
          end
       end
    end
 end

@testset "macros" begin
    str = "12:37:34.2344"
    dms = parse_dms(str)
    @test all(dms .== [12, 37, 34.2344])
    @test dms"12:37:34.2344" == dms"12:37:34.2344"rad ≈ dms2rad(dms)
    @test dms"12:37:34.2344"deg ≈ dms2deg(dms)
    @test dms"12:37:34.2344"ha ≈ dms2ha(dms)
    @tmt ErrorException @dms_str("12:37:34.2344", "invalid")

    hms = parse_hms(str)
    @test all(hms .== [12, 37, 34.2344])
    @test hms"12:37:34.2344" == hms"12:37:34.2344"rad ≈ hms2rad(hms)
    @test hms"12:37:34.2344"deg ≈ hms2deg(hms)
    @test hms"12:37:34.2344"ha ≈ hms2ha(hms)
    @tmt ErrorException @hms_str("12:37:34.2344", "invalid")
end

@testset "negatives" begin
    @test parse_dms("-0:0:1") == (-0.0, 0.0, 1.0)
    @test parse_hms("-0:0:1") == (-0.0, 0.0, 1.0)
    @test parse_dms("- 0:0:1") == (-0.0, 0.0, 1.0)
    @test parse_hms("- 0:0:1") == (-0.0, 0.0, 1.0)
    @test parse_dms("+0:0:1") == (0.0, 0.0, 1.0)
    @test parse_hms("+0:0:1") == (0.0, 0.0, 1.0)
end

@testset "directions" begin
    @test parse_dms("1:0:0N") == (1.0, 0.0, 0.0)
    @test parse_dms("1:0:0S") == (-1.0, 0.0, 0.0)
    @test parse_dms("-1:0:0S") == (1.0, 0.0, 0.0)
    @test parse_dms("1:0:0E") == (1.0, 0.0, 0.0)
    @test parse_dms("1:0:0W") == (-1.0, 0.0, 0.0)
    @test parse_dms("-1:0:0W") == (1.0, 0.0, 0.0)

    @test parse_hms("1:0:0E") == (1.0, 0.0, 0.0)
    @test parse_hms("1:0:0W") == (-1.0, 0.0, 0.0)
    @test parse_hms("-1:0:0W") == (1.0, 0.0, 0.0)
    @test parse_dms("1:0:0N") == (1.0, 0.0, 0.0)
    @test parse_hms("1:0:0S") == (-1.0, 0.0, 0.0)
    @test parse_dms("-1:0:0S") == (1.0, 0.0, 0.0)
end

@testset "astropy examples" begin
    @test dms2deg("10.2345d") ≈ 10.2345
    @test dms2deg("1:2:30.43") ≈ 1.04178611
    @test hms2ha("1 2 0") ≈ 1.03333333
    @test dms2deg("1°2′3″") ≈ dms2deg("1°2′3″N") ≈ 1.03416667
    @test dms2deg("1d2m3.4s") ≈ -dms2deg("1d2m3.4sS") ≈ 1.03427778
    @test hms2ha("-1h2m3s") ≈ -hms2ha("-1h2m3sW") ≈ -1.03416667
    @test dms2deg((-1, 2, 3)) ≈ -1.03416667
end

@testset "partial representations" begin
    @test parse_dms("10.234") == (10.234, 0.0, 0.0)
    @test parse_dms("10.234 0.1") == (10.234, 0.1, 0.0)
    @test parse_dms("10.234 0.1 0.3") == (10.234, 0.1, 0.3)
    @test parse_hms("10.234") == (10.234, 0.0, 0.0)
    @test parse_hms("10.234 0.1") == (10.234, 0.1, 0.0)
    @test parse_hms("10.234 0.1 0.3") == (10.234, 0.1, 0.3)
end
