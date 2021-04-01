
DMS_FSTRINGS = FormatExpr.([
    "{1:d} {2:d} {3}",
    "{1:d}:{2:d}:{3}",
    "{1:d}d{2:d}m{3}s",
    "{1:d}°{2:d}'{3}\"",
    "{1:d} {2:d}:{3}"
])

HMS_FSTRINGS = FormatExpr.([
    "{1:d} {2:d} {3}",
    "{1:d}:{2:d}:{3}",
    "{1:d}h{2:d}m{3}s",
    "{1:d}h{2:d}'{3}\"",
    "{1:d} {2:d}:{3}"
])

@testset "parsing" for fstring in DMS_FSTRINGS
    @test all(randdms(rng, 1000)) do dms
        d, m, s = dms
        str = format(fstring, d, m, s)
        res = parse_dms(str)
        return all(dms .≈ res)
    end
end
 
@testset "parsing" for fstring in HMS_FSTRINGS
    @test all(randhms(rng, 10)) do hms
        h, m, s = hms
        str = format(fstring, h, abs(m), abs(s))
        res = parse_hms(str)
        return all(hms .≈ res)
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
