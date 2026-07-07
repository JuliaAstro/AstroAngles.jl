using ParallelTestRunner: runtests, find_tests, parse_args
using AstroAngles

const init_code = quote
    using AstroAngles
    using Format
    using StableRNGs
    using Test
    using Documenter

    rng = StableRNG(206265)

    randdegree(rng, Ns...) = (rand(rng, Ns...) .- 0.5) .* 720
    randrad(rng, Ns...) = (rand(rng, Ns...) .- 0.5) .* 4π
    randha(rng, Ns...) = (rand(rng, Ns...) .- 0.5) .* 48
    randdms(rng, Ns...) = randdegree(rng, Ns...) .|> deg2dms
    randhms(rng, Ns...) = randdegree(rng, Ns...) .|> deg2hms
end

args = parse_args(Base.ARGS)
testsuite = find_tests(@__DIR__)

runtests(AstroAngles, args; testsuite, init_code)
