push!(LOAD_PATH,"../src/")

using Documenter
using ArgMacros

makedocs(
    sitename = "ArgMacros",
    format = Documenter.HTML(),
    modules = [ArgMacros]
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
#=deploydocs(
    repo = "<repository url>"
)=#
