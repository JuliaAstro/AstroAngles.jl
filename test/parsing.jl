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

@testset "macros" begin
    str = "12:37:34.2344"
    dms = parse_dms(str)
    @test all(dms .== [12, 37, 34.2344])
    @test dms"12:37:34.2344" == dms"12:37:34.2344"rad ≈ dms2rad(dms)
    @test dms"12:37:34.2344"deg ≈ dms2deg(dms)
    @test dms"12:37:34.2344"ha ≈ dms2ha(dms)
    @test_throws ArgumentError @dms_str("12:37:34.2344", "invalid")

    hms = parse_hms(str)
    @test all(hms .== [12, 37, 34.2344])
    @test hms"12:37:34.2344" == hms"12:37:34.2344"rad ≈ hms2rad(hms)
    @test hms"12:37:34.2344"deg ≈ hms2deg(hms)
    @test hms"12:37:34.2344"ha ≈ hms2ha(hms)
    @test_throws ArgumentError @hms_str("12:37:34.2344", "invalid")
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

@testset "unit-tagged components" begin
    # A value's unit routes it to the right component instead of positionally
    @test parse_dms("1'") == (0.0, 1.0, 0.0)
    @test parse_dms("1\"") == (0.0, 0.0, 1.0)
    @test parse_dms("2m3s") == (0.0, 2.0, 3.0)
    @test parse_dms("1'2\"") == (0.0, 1.0, 2.0)
    @test parse_dms("30'30\"") == (0.0, 30.0, 30.0)
    @test parse_dms("1d3s") == (1.0, 0.0, 3.0) # Skip the (absent) arcminutes
    @test parse_dms("10.2345d") == (10.2345, 0.0, 0.0)
    @test parse_hms("2m3s") == (0.0, 2.0, 3.0)
    @test parse_hms("1h3s") == (1.0, 0.0, 3.0)
    # Sign lives on the whole component even when it is absent
    @test parse_dms("2m3sW") == (-0.0, 2.0, 3.0)
    @test parse_hms("-2m3s") == (-0.0, 2.0, 3.0)
    # Ambiguous delimiters (`:`, whitespace) still fill positionally
    @test parse_dms("1:2") == (1.0, 2.0, 0.0)
    @test parse_dms("1 2m") == (1.0, 2.0, 0.0)
    @test parse_dms("1m2") == (0.0, 1.0, 2.0)  # Positional after arcmin --> arcsec
end

@testset "out-of-order and malformed input" begin
    # Components out of order --> informative ArgumentError
    @test_throws ArgumentError parse_dms("3s2m")
    @test_throws ArgumentError parse_dms("1s2d")
    @test_throws ArgumentError parse_dms("1'2d")
    @test_throws ArgumentError parse_hms("3s2m")
    err = try parse_dms("3s2m") catch e; e end
    @test err isa ArgumentError
    @test occursin("out of order", err.msg)
    # Unparseable / leading-delimiter / trailing-junk input is rejected
    @test_throws ArgumentError parse_dms(":5")
    @test_throws ArgumentError parse_dms("1:2:3junk")
    @test_throws ArgumentError parse_dms("abc")
    @test_throws ArgumentError parse_dms("1:2:3:4")
    @test_throws ArgumentError parse_hms(":5")
end

@testset "missing value handling in parsing" begin
    # Test parsing functions with missing values
    @test ismissing(parse_dms(missing))
    @test ismissing(parse_hms(missing))

    # Test string inputs for dms/hms with missing values
    @test ismissing(dms2deg(missing))
    @test ismissing(dms2rad(missing))
    @test ismissing(dms2ha(missing))

    @test ismissing(hms2deg(missing))
    @test ismissing(hms2rad(missing))
    @test ismissing(hms2ha(missing))
end
