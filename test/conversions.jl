
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
