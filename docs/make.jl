using Documenter
using ArgMacros

makedocs(
    sitename = "ArgMacros",
    format = Documenter.HTML(),
    modules = [ArgMacros],
    warnonly = [:missing_docs],
)

deploydocs(
    repo = "github.com/zachmatson/ArgMacros.jl.git",
)
