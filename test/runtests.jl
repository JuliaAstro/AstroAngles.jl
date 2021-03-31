using AstroAngles
using StableRNGs
using Test

rng = StableRNG(206265)

@testset "conversions" begin include("conversions.jl") end
