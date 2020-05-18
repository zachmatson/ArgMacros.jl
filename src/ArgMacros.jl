module ArgMacros

using TextWrap
using Base: @kwdef

export @beginarguments
export @helpusage, @helpdescription, @helpepilog
export @argumentrequired, @argumentdefault, @argumentoptional,
       @argumentflag, @argumentcount
export @positionalrequired, @positionaldefault, @positionaloptional
export @arghelp, @argtest, @allowextraarguments

include("constants.jl")
include("handleast.jl")
include("help.jl")
include("argsparsing.jl")
include("macros.jl")

#=
TODO
    multi-value arguments
    backspace and escaping behavior
    Documentation
    Publish and resgister project
=#

"""
Performant, macro-only, pure Julia package for parsing command line arguments.    
Uses macros to generate the parsing code within your main function, directly storing
results in typed local variables.

Basic usage:
```julia
julia_main()
    @beginarguments begin
        @argumentrequired Int foo "-f" "--foo"
        @argumentdefault Int 5 bar "-b" "--bar"
        ...
        @positionalrequired String baz
        ...
        @positionaloptional String anotheroption
    end

    x::Int = foo + bar # required and default values are typed and completely type stable
    y::String = baz * something(anotheroption, "optional arguments may have nothing value")
    ...
end
```

See the documentation before using.
"""
ArgMacros

end # Module