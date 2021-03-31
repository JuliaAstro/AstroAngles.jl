function randdegree(rng, Ns...)
    points = rand(rng, Ns...)
    return points .* 360
end

function randrad(rng, Ns...)
    points = rand(rng, Ns...)
    return points .* 2π
end

function randha(rng, Ns...)
    points = rand(rng, Ns...)
    return points .* 24
end

function test_integration(f1, f2, angles)
    reconstructed = @. f2(f1(angles))
    @test reconstructed ≈ angles
end

@testset "integration - $f1/$f2" for (f1, f2) in zip(
    [deg2hms, deg2dms], [hms2deg, dms2deg]
)
    angles = randdegree(rng, 1000)
    test_integration(f1, f2, angles)
end

@testset "integration - $f1/$f2" for (f1, f2) in zip(
    [rad2hms, rad2dms], [hms2rad, dms2rad]
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
