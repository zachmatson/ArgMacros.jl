module ArgMacros

# Lower the optimization level for faster startup times, if supported
if isdefined(Base, :Experimental)
    if isdefined(Base.Experimental, Symbol("@compiler_options"))
        @eval Base.Experimental.@compiler_options compile=min optimize=1 infer=false
    elseif isdefined(Base.Experimental, Symbol("@optlevel"))
        @eval Base.Experimental.@optlevel 1
    end
end

using TextWrap
using Base: @kwdef

export @beginarguments, @inlinearguments, @structarguments,
       @tuplearguments, @dictarguments
export @helpusage, @helpdescription, @helpepilog
export @argumentrequired, @argumentdefault, @argumentoptional,
       @argumentflag, @argumentcount
export @positionalrequired, @positionaldefault, @positionaloptional,
       @positionalleftover
export @arghelp, @argtest, @allowextraarguments

include("constants.jl")
include("handleast.jl")
include("help.jl")
include("argsparsing.jl")
include("macros.jl")

include("precompile.jl")
_precompile_()

"""
Performant, macro-only, pure Julia package for parsing command line arguments.    
Uses macros to generate the parsing code within your main function, directly storing
results in typed local variables.

Basic usage:
```julia
julia_main()
    @inlinearguments begin
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