# ArgMacros
# help.jl

# Extend only for the Argument and Help types used here
# Extended methods will not be exported
import Base.show

#=
Macros have no function themselves
Only used as markers in the AST for generating Help
=#

"""
    @helpusage usage_text::String

Add usage text for the help screen  
Automatically prepended with "Usage: "

Must be used in `@beginarguments begin ... end` block

# Example
```julia
@beginarguments begin
    @helpusage "example.jl foo [bar] [-v]"
    ...
end
```
"""
macro helpusage(usage::String) end

"""
    @helpdescription description::String

Add description for the help screen  

Must be used in `@beginarguments begin ... end` block

# Example
```julia
@beginarguments begin
    ...
    @helpdescription "Lorem ipsum dolor sit amet"
    ...
end
```
"""
macro helpdescription(description::String) end

"""
    @helpepilog epilog::String

Add epilog for the help screen, displayed after rest of help 

Must be used in `@beginarguments begin ... end` block

# Example
```julia
@beginarguments begin
    ...
    @helpepilog "Lorem ipsum dolor sit amet"
    ...
end
```
"""
macro helpepilog(epilog::String) end

"""
    @arghelp help_text::String

Add help string for an argument.  
Applied to the preceding declared argument

Must be used in `@beginarguments begin ... end` block

# Example
```julia
@beginarguments begin
    ...
    @argumentflag v "-v" "--verbose"
    @arghelp "Display additional output"
    ...
end
```
"""
macro arghelp(helptext::String) end

"Print a message, ask user to try --help, and exit the program"
function _quit_try_help(message::String)
    println(message)
    println("Try the --help option")
    exit(1)
end

#=
Help is generated on-demand, may want to change this for precompiled scripts
=#

"Check for -h/--help flag, end program and print help if needed"
function _help_check(args::Vector{String}, block::Expr)
    if !isnothing(_get_option_idx(args, ["-h", "--help"]))
        _make_help(block) |> print
        exit(0)
    end
end

"Hold information to print an argument"
@kwdef mutable struct Argument
    names::Vector{Union{String, Symbol}} = []
    type::Symbol = :Any
    required::Bool = false
    positional::Bool = false
    default::String = ""
    description::String = ""
end

"Hold information to print entire help screen"
@kwdef mutable struct Help
    usage_text::String = ""
    description_text::String = ""
    epilog_text::String = ""
    positionals::Vector{Argument} = []
    options::Vector{Argument} = []
end

"Assemble the Help struct from the macro contents"
function _make_help(block::Expr)::Help
    help = Help()

    lastpushed::Symbol = :none

    # Loop through all macros in the block
    for arg in block.args
        if arg isa Expr && arg.head == :macrocall
            macroname::Symbol = _get_macroname(arg)

            # Modify the help struct as needed by the encountered macro
            if macroname == USAGE_SYMBOL
                help.usage_text = arg.args[3] # 3rd arg for these is the string passed
            elseif macroname == DESCRIPTION_SYMBOL
                help.description_text = arg.args[3]
            elseif macroname == EPILOG_SYMBOL
                help.epilog_text = arg.args[3]
            elseif macroname == ARGHELP_SYMBOL
                # Add description to last pushed element in positionals or options
                argvector::Vector{Argument} = getfield(help, lastpushed)
                argvector[end].description = arg.args[3]
            elseif macroname == ARGUMENT_REQUIRED_SYMBOL
                push!(help.options, Argument(
                    arg.args[5:end], arg.args[3], true, false, "", "")
                )
                lastpushed = :options
            elseif macroname == ARGUMENT_DEFAULT_SYMBOL
                push!(help.options, Argument(
                    arg.args[6:end], arg.args[3], false, false, string(arg.args[4]), "")
                )
                lastpushed = :options
            elseif macroname == ARGUMENT_OPTIONAL_SYMBOL
                push!(help.options, Argument(
                    arg.args[5:end], arg.args[3], false, false, "", "")
                )
                lastpushed = :options
            elseif macroname == ARGUMENT_FLAG_SYMBOL
                push!(help.options, Argument(
                    arg.args[4:end], :Flag, false, false, "", "")
                )
                lastpushed = :options
            elseif macroname == ARGUMENT_COUNT_SYMBOL
                push!(help.options, Argument(
                    arg.args[4:end], :Count, false, false, "", "")
                )
                lastpushed = :options
            elseif macroname == POSITIONAL_REQUIRED_SYMBOL
                push!(help.positionals, Argument(
                    [arg.args[end]], arg.args[3], true, true, "", "")
                )
                lastpushed = :positionals
            elseif macroname == POSITIONAL_DEFAULT_SYMBOL
                push!(help.positionals, Argument(
                    [arg.args[end]], arg.args[3], false, true, string(arg.args[4]), "")
                )
                lastpushed = :positionals
            elseif macroname == POSITIONAL_OPTIONAL_SYMBOL
                push!(help.positionals, Argument(
                    [arg.args[end]], arg.args[3], false, true, "", "")
                )
                lastpushed = :positionals
            end
        end
    end

    return help
end

function show(io::IO, arg::Argument)
    # Print as "required" or "[optional]"
    # For positional arguments
    if arg.positional && !arg.required
        print(io, "[")
        print(io, join(arg.names, " "))
        print(io, "]")
    else
        print(io, join(arg.names, " "))
    end
    println()

    if !isempty(arg.description)
        println_wrapped(io, arg.description, initial_indent=6, subsequent_indent=6)
    end

    println(io, " "^6 * (
        isempty(arg.default) ?
            arg.required ? "(Type: $(arg.type), Required)" : "(Type: $(arg.type))" :
            "(Type: $(arg.type), Default: $(arg.default))"
    ))
end

function show(io::IO, help::Help)
    if !isempty(help.usage_text)
        println(io, "Usage: $(help.usage_text)")
        println(io)
    end

    if !isempty(help.description_text)
        println_wrapped(io, help.description_text)
        println(io)
    end

    if !isempty(help.positionals)
        println(io, "Positional Arguments:")
        for arg in help.positionals
            print(io, arg)
        end
        println(io)
    end

    if !isempty(help.options)
        println(io, "Option Arguments:")
        for arg in help.options
            print(io, arg)
        end
        println(io)
    end

    if !isempty(help.epilog_text)
        println_wrapped(io, help.epilog_text)
        println(io)
    end
end
