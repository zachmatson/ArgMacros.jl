# ArgMacros
# argsparsing.jl

#=
The first two functions are used in "setting up" the environment for parsing
=#

"""Split up multiple flag arguments, e.g. "-zx-v2f" → ["-z", "-x", "-v", "2", "-f"]"""
function _split_multiflag(s::AbstractString)::Vector{String}
    splitflags = Vector{String}()

    max_i::Int = length(s) + 1
    i::Int = 2 # First character should always be '-'
    while i < max_i
        if s[i] == '-' # Ignore
            i += 1
        elseif isdigit(s[i]) # Allow numbers inside group of flags with no space or =
            nextletter::Int = something(findnext((c -> isletter(c) || c == '-'), s, i + 1), max_i)
            push!(splitflags, s[i:nextletter - 1])
            i = nextletter
        elseif isletter(s[i]) # Split each flag off
            push!(splitflags, "-$(s[i])")
            i += 1
        else
            _quit_try_help("Error parsing argument(s) \"$s\", unrecognized character in flag sequence")
        end
    end
    return splitflags
end

"Split the arguments into a usable form with separated tokens"
function _split_arguments(args::Vector{String})::Vector{String}
    splitargs = Vector{String}()

    for arg in args
        # Expand arg/value pairs with = to separate entries
        for splitarg in split(arg, '=')
            # Handle chained flags or flags with Int values like "-xzfv" or "-O3"
            if splitarg[1] == '-' && splitarg[2] != '-' && length(splitarg) > 2
                append!(splitargs, _split_multiflag(splitarg))
            else
                push!(splitargs, splitarg)
            end
        end
    end

    return splitargs
end

#=
The remaining functions are used in parsing individual arguments
=#

"Find the index of the (first) occurrence of one of the specified flags in args"
function _get_option_idx(args::Vector{String}, flags::Vector{String})::Union{Int, Nothing}
    return findfirst(in(flags), args)
end

"Remove the option and value for any flag in flags and return the given value"
function _pop_argval!(args::Vector{String}, flags::Vector{String})::Union{String, Nothing}
    option_idx = _get_option_idx(args, flags)
    if isnothing(option_idx)
        return nothing
    elseif option_idx == length(args) || args[option_idx + 1][1] == '-' # Found flag but no value to go with it
        _quit_try_help("Argument $(args[option_idx]) requires a value")
    else
        val::String = args[option_idx + 1]
        deleteat!(args, (option_idx, option_idx + 1))
        return val
    end
end

"Remove a flag if present and return whether the flag was found"
function _pop_flag!(args::Vector{String}, flags::Vector{String})::Bool
    flag_idx = _get_option_idx(args, flags)

    if isnothing(flag_idx)
        return false
    else
        deleteat!(args, flag_idx)
        return true
    end
end

"Remove multiple occurrences of flag from args and return the count removed"
function _pop_count!(args::Vector{String}, flag::String)::Int
    initial_arg_length::Int = length(args)
    i::Int = 1
    while i <= length(args)
        if args[i] == flag
            deleteat!(args, i)
        else
            i += 1
        end
    end
    return initial_arg_length - length(args)
end

"""
Convert string to Number type with parse or other type with direct conversion.
Quit program if s is nothing or conversion fails.
"""
function _converttype!(::Type{T}, s::Union{AbstractString, Nothing}, name::String)::T where T
    if isnothing(s)
        _quit_try_help("Argument $name missing")
    end

    try
        if T <: Number
            # Allow floating value to be passed to Int argument
            return T(parse(Float64, s))
        else
            return T(s)
        end
    catch
        _quit_try_help("Invalid type for argument $name")
    end
end

"If x is not a string (i.e. literal passed as default) assume direct conversion is possible. Does NOT validate."
function _converttype!(::Type{T}, x::Any, ::String)::T where T
    return T(x)
end
