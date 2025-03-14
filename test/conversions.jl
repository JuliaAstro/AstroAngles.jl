function test_integration(f1, f2, angles)
    reconstructed = @. f2(f1(angles))
    @test reconstructed ≈ angles
end

@testset "integration - $f1/$f2" for (f1, f2) in zip(
    [deg2hms, deg2dms, deg2ha], [hms2deg, dms2deg, ha2deg]
)
    angles = randdegree(rng, 1000)
    test_integration(f1, f2, angles)
end

@testset "integration - $f1/$f2" for (f1, f2) in zip(
    [rad2hms, rad2dms, rad2ha], [hms2rad, dms2rad, ha2rad]
)
    angles = randrad(rng, 1000)
    test_integration(f1, f2, angles)
end

@testset "integration - $f1/$f2" for (f1, f2) in zip(
    [ha2hms, ha2dms], [hms2ha, dms2ha]
)
    angles = randha(rng, 1000)
    test_integration(f1, f2, angles)
end

@testset "missing value handling" begin
    using Missings
    
    # Test rad2xxx functions
    @test ismissing(rad2ha(missing))
    @test ismissing(rad2dms(missing))
    @test ismissing(rad2hms(missing))
    
    # Test deg2xxx functions
    @test ismissing(deg2ha(missing))
    @test ismissing(deg2dms(missing))
    @test ismissing(deg2hms(missing))
    
    # Test ha2xxx functions
    @test ismissing(ha2rad(missing))
    @test ismissing(ha2deg(missing))
    @test ismissing(ha2hms(missing))
    @test ismissing(ha2dms(missing))
    
    # Test dms2xxx functions
    @test ismissing(dms2deg(missing, missing, missing))
    @test ismissing(dms2deg(missing, missing, missing))
    @test ismissing(dms2rad(missing, missing, missing))
    @test ismissing(dms2ha(missing, missing, missing))
    @test ismissing(dms2deg(missing))
    @test ismissing(dms2rad(missing))
    @test ismissing(dms2ha(missing))
    
    # Test hms2xxx functions
    @test ismissing(hms2ha(missing, missing, missing))
    @test ismissing(hms2deg(missing, missing, missing))
    @test ismissing(hms2rad(missing, missing, missing))
    @test ismissing(hms2ha(missing))
    @test ismissing(hms2deg(missing))
    @test ismissing(hms2rad(missing))

    # Test with partially missing values
    @test ismissing(hms2ha(18, 23.9, missing))
end
