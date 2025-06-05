using AstroAngles
using Documenter
using Documenter.Remotes: GitHub

DocMeta.setdocmeta!(AstroAngles, :DocTestSetup, :(using AstroAngles))

makedocs(
    modules = [AstroAngles],
    sitename = "AstroAngles.jl",
    repo = GitHub("JuliaAstro/AstroAngles.jl"),
    pages = [
        "Home" => "index.md",
        "API Reference" => "api.md",
    ],
    format = Documenter.HTML(;
         canonical = "https://JuliaAstro.org/AstroAngles/stable/",
    ),
)

deploydocs(
    repo = "github.com/JuliaAstro/AstroAngles.jl.git",
    versions = ["stable" => "v^", "v#.#"] # Restrict to minor releases,
)
