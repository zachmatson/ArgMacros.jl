prepend!(LOAD_PATH, ["../src/"])

using Documenter
using ArgMacros

makedocs(
    sitename = "ArgMacros",
    format = Documenter.HTML(),
    modules = [ArgMacros]
)

deploydocs(
    repo = "github.com/zachmatson/ArgMacros.jl.git",
)
