using AstroAngles
using Formatting
using StableRNGs
using Test

rng = StableRNG(206265)

randdegree(rng, Ns...) = (rand(rng, Ns...) .- 0.5) .* 720
randrad(rng, Ns...) = (rand(rng, Ns...) .- 0.5) .* 4π
randha(rng, Ns...) = (rand(rng, Ns...) .- 0.5) .* 48
randdms(rng, Ns...) = randdegree(rng, Ns...) .|> deg2dms
randhms(rng, Ns...) = randdegree(rng, Ns...) .|> deg2hms

@testset "conversions" begin include("conversions.jl") end
@testset "parsing" begin include("parsing.jl") end
@testset "printing" begin include("printing.jl") end
