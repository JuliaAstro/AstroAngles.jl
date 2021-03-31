using AstroAngles
using Documenter
using StableRNGs
using Test

rng = StableRNG(206265)

randdegree(rng, Ns...) = rand(rng, Ns...) .* 360
randrad(rng, Ns...) = rand(rng, Ns...) .* 2π
randha(rng, Ns...) = rand(rng, Ns...) .* 24
randdms(rng, Ns...) = randdegree(rng, Ns...) .|> deg2dms
randhms(rng, Ns...) = randdegree(rng, Ns...) .|> deg2hms

@testset "conversions" begin include("conversions.jl") end
@testset "parsing" begin include("parsing.jl") end
