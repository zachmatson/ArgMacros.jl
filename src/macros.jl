# ArgMacros
# macros.jl

"Ensure flags is not empty and that no flag overlaps with those used by help"
function _validateflags(local_name, flags)
    @assert !isempty(flags) "Argument $local_name must have at least one flag."
    @assert !("-h" in flags) && !("--help" in flags) "Flags -h and --help are reserved"
end

"""
    @inlinearguments begin ... end

Denote and setup a block with other macros from `ArgMacros`

# Example
```julia
function julia_main()
    @inlinearguments begin
        ...
        @argumentrequired Int foo "-f" "--foo"
        @argumentdefault Int 5 bar "-b" "--bar"
        ...
    end
    ...
end
```
"""
macro inlinearguments(block::Expr)
    _validateorder(block) # Validate ordering of macros

    return quote
        splitargs = _split_arguments($(esc(:ARGS))) # Consumed by the macros in the block
        allowextraargs = false

        _help_check(splitargs, $(Expr(:quote, block))) # End and print help if needed

        $block

        if !allowextraargs && !isempty(splitargs)
            _quit_try_help("Too many or unrecognized arguments provided")
        end
    end
end

"""
    @beginarguments begin ... end

This macro is deprecated beginning in ArgMacros v0.2.0    
Please use @inlinearguments, which has the same interface    
Or consider @structarguments, @tuplearguments, and @dictarguments depending on your use case
"""
macro beginarguments(block::Expr) 
    @warn """
        Macro `@beginarguments` is deprecated in ArgMacros v0.2.0
        Please use @inlinearguments, which has the same interface
        Or consider @structarguments, @tuplearguments, and @dictarguments depending on your use case
    """
    esc(:(@inlinearguments $block))
end

"""
    @structarguments mutable typename begin ... end

Denote and setup a block with other macros from `ArgMacros`    
Defines an optionally mutable struct type based on the arguments and a zero-argument constructor    
which will generate an instance of the struct based on the parsed arguments.

# Example
```julia
@structarguments false Args begin
    ...
    @argumentrequired Int foo "-f" "--foo"
    @argumentdefault Int 5 bar "-b" "--bar"
    ...
end

function julia_main()
    args = Args()
    ...
end
```
"""
macro structarguments(mutable::Bool, name::Symbol, block::Expr)
    Expr(:block,
        Expr(:struct, mutable, name, Expr(:block, _getargumentpairs(block)...)),
        esc(Expr(:function,
            :($name()::$name),
            Expr(:block,
                :(@inlinearguments $block),
                Expr(:call,
                    name,
                    (:($(pair.args[1])) for pair in _getargumentpairs(block))...
                )
            )
        ))
    )
end

"""
    @tuplearguments begin ... end

Denote and setup a block with other macros from `ArgMacros`    
Return a NamedTuple with the arguments instead of dumping them in the enclosing namespace    


# Example
```julia
function julia_main()
    args = @tuplearguments begin
        ...
        @argumentrequired Int foo "-f" "--foo"
        @argumentdefault Int 5 bar "-b" "--bar"
        ...
    end
    ...
end
```
"""
macro tuplearguments(block::Expr)
    Expr(:let, Expr(:block), esc(Expr(:block,
        :(@inlinearguments $block),
        Expr(:tuple,
            (:($(pair.args[1]) = $(pair.args[1])) for pair in _getargumentpairs(block))...
        )
    )))
end

"""
    @dictarguments begin ... end

Denote and setup a block with other macros from `ArgMacros`    
Return a Dict with the arguments instead of dumping them in the enclosing namespace    


# Example
```julia
function julia_main()
    args = @dictarguments begin
        ...
        @argumentrequired Int foo "-f" "--foo"
        @argumentdefault Int 5 bar "-b" "--bar"
        ...
    end
    ...
end
```
"""
macro dictarguments(block::Expr)
    Expr(:let, Expr(:block), esc(Expr(:block,
        :(@inlinearguments $block),
        Expr(:call,
            :(Dict{Symbol, Any}),
            (:($(Meta.quot(pair.args[1])) => $(pair.args[1])) for pair in _getargumentpairs(block))...
        )
    )))
end

#=
Remaining macros require two escapes to get to the level of the calling scope
Because they will be nested in the @beginarguments macro
=#

"""
    @argumentrequired type local_name flags::String...

Get a required argument specified by the given flags and store
in the variable `local_name` with the specified type.

Print a message and exit the program if the value is not found or
cannot be converted to the specified type.

Must be used in `@beginarguments begin ... end` block

# Example
```julia
@beginarguments begin
    ...
    @argumentrequired String output_file "-o" "--output"
    ...
end
```
"""
macro argumentrequired(type::Symbol, local_name::Symbol, flags::String...)
    _validateflags(local_name, flags)
    return quote
        #  _converttype! is completely type safe
        local $(esc(esc(local_name)))::$(esc(esc(type))) = _converttype!($type, _pop_argval!(splitargs, [$flags...]), $(flags[end]))
    end
end

"""
    @argumentdefault type default_value local_name flags::String...

Attempt to get an argument specified by the given flags and store
in the variable `local_name` with the specified type.
Store the default value instead if the flags cannot be found.
Default value automatically converted to specified type.

Must be used in `@beginarguments begin ... end` block

# Example
```julia
@beginarguments begin
    ...
    @argumentdefault String "output.txt" output_file "-o" "--output"
    ...
end
```
"""
macro argumentdefault(type::Symbol, default_value, local_name::Symbol, flags::String...)
    _validateflags(local_name, flags)
    return quote
        potential_val::Union{String, Nothing} = _pop_argval!(splitargs, [$flags...])
        # Convert either potential or the default value, allows default to be specified with wrong literal type
        local $(esc(esc(local_name)))::$(esc(esc(type))) = _converttype!($type, something(potential_val, $default_value), $(flags[end]))
    end
end

"""
    @argumentoptional type local_name flags::String...

Attempt to get an argument specified by the given flags and store
in the variable `local_name` with the type `Union{type, Nothing}`.
Store `nothing` if the flags cannot be found.

Must be used in `@beginarguments begin ... end` block

# Example
```julia
@beginarguments begin
    ...
    @argumentoptional String output_file "-o" "--output"
    ...
end
```
"""
macro argumentoptional(type::Symbol, local_name::Symbol, flags::String...)
    _validateflags(local_name, flags)
    return quote
        potential_val::Union{String, Nothing} = _pop_argval!(splitargs, [$flags...])
        # Return nothing directly without calling _converttype! if arg not found
        local $(esc(esc(local_name)))::$(esc(esc(Union))){$(esc(esc(type))), $(esc(esc(Nothing)))} =
            isnothing(potential_val) ? nothing : _converttype!($type, potential_val, $(flags[end]))
    end
end

"""
    @argumentflag local_name flags::String...

Store `true` in the variable `local_name` with type `Bool` if one or more of the flags is found.
Otherwise, store `false`.

Must be used in `@beginarguments begin ... end` block

# Example
```julia
@beginarguments begin
    ...
    @argumentflag verbose "-v" "--verbose"
    ...
end
```
"""
macro argumentflag(local_name::Symbol, flags::String...)
    _validateflags(local_name, flags)
    return quote
        local $(esc(esc(local_name)))::$(esc(esc(Bool))) = _pop_flag!(splitargs, [$flags...])
    end
end

"""
    @argumentcount local_name flag::String

Store the number of occurrences of `flag` in `local_name` with type `Int`.

Must be used in `@beginarguments begin ... end` block

# Example
```julia
@beginarguments begin
    ...
    @argumentcount verbose "-v"
    ...
end
```
"""
macro argumentcount(local_name::Symbol, flag::String)
    return quote
        local $(esc(esc(local_name)))::$(esc(esc(Int))) = _pop_count!(splitargs, $flag)
    end
end

"""
    @positionalrequired type local_name [help_name::String]

Attempt to get a positional argument and store in variable `local_name` with the specified type.

Positional arguments are read in order after all flag/option arguments have been read.  
`help_name` used instead of `local_name` in messages to user if specified.

Print a message and exit the program if a value is not found or cannot be converted to the specified type.

Must be used in `@beginarguments begin ... end` block

# Example
```julia
@beginarguments begin
    ...
    @positionalrequired String output_file "output"
    ...
end
```
"""
macro positionalrequired(type::Symbol, local_name::Symbol, help_name::Union{String, Nothing}=nothing)
    help_name_str::String = something(help_name, String(local_name))
    return quote
        local $(esc(esc(local_name)))::$(esc(esc(type))) = _converttype!(
            $type,
            !isempty(splitargs) ? popfirst!(splitargs) : nothing,
            $help_name_str
        )
    end
end

"""
    @positionaldefault type default_value local_name [help_name::String]

Attempt to get a positional argument and store in variable local_name with the specified type.
Store the default value instead if an argument cannot be found.

Positional arguments are read in order after all flag/option arguments have been read.  
`help_name` used instead of `local_name` in messages to user if specified.

Default value automatically converted to specified type.

Must be used in `@beginarguments begin ... end` block

# Example
```julia
@beginarguments begin
    ...
    @positionaldefault String output_file "output"
    ...
end
```
"""
macro positionaldefault(type::Symbol, default_value, local_name::Symbol, help_name::Union{String, Nothing}=nothing)
    help_name_str::String = something(help_name, String(local_name))
    return quote
        local $(esc(esc(local_name)))::$(esc(esc(type))) =_converttype!(
            $type,
            !isempty(splitargs) ? popfirst!(splitargs) : $default_value,
            $help_name_str
        )
    end
end

"""
    @positionaloptional type local_name [help_name]

Attempt to get a positional argument and store in variable `local_name` with the type
`Union{type, Nothing}`. Store `nothing` if an argument is not found.

Positional arguments are read in order after all flag/option arguments have been read.  
`help_name` used instead of `local_name` in messages to user if specified.

Must be used in `@beginarguments begin ... end` block

# Example
```julia
@beginarguments begin
    ...
    @positionaloptional String output_file "output"
    ...
end
```
"""
macro positionaloptional(type::Symbol, local_name::Symbol, help_name::Union{String, Nothing}=nothing)
    help_name_str::String = something(help_name, String(local_name))
    return quote
        local $(esc(esc(local_name)))::$(esc(esc(Union))){$(esc(esc(type))), $(esc(esc(Nothing)))} =
            !isempty(splitargs) ? _converttype!($type, popfirst!(splitargs), $help_name_str) : nothing
    end
end

"""
    @positionalleftover type local_name [help_name]

Get any leftover positional arguments after all other arguments have been parsed, and store in
variable `local_name` with the type `Vector{type}`. This vector will be empty if there are no
leftover arguments.

This macro must be used after all other arguments have been declared, as positional arguments are
read in order after all flag/option arguments have been read.  
Using this macro means all input will be captured by this argument if not by another, so
`@allowextraarguments` is not necesesary when this macro is used.
`help_name` used instead of `local_name` in messages to user if specified.

Must be used in `@beginarguments begin ... end` block

# Example
```julia
@beginarguments begin
    ...
    @positionalleftover String file_names "files"
    ...
end
```
"""
macro positionalleftover(type::Symbol, local_name::Symbol, help_name::Union{String, Nothing}=nothing)
    help_name_str::String = something(help_name, String(local_name))
    return quote
        local $(esc(esc(local_name)))::$(esc(esc(Vector))){$(esc(esc(type)))} = 
            _converttype!($type, splitargs, $help_name_str)
        empty!(splitargs)
    end   
end

"""
    @argtest argname func [desc]

Apply `func` to the value stored in `argname`, printing an error message (optionally
specified by `desc`) and the program  if `func` returns `false`.  
Test skipped if `argname` has value `nothing` (only possible for optional arguments).  
This macro must be used AFTER declaring the arugment with another macro.

Must be used in `@beginarguments begin ... end` block

# Example
```julia
@beginarguments begin
    ...
    @positionalrequired String input_file
    @argtest input_file isfile "Couldn't find the input file."
    ...
end
```
"""
macro argtest(argname::Symbol, func::Union{Symbol, Expr}, desc::Union{String, Nothing}=nothing)
    errstr::String = something(desc, "Tests for argument $argname failed.")
    return quote
        if !(isnothing($(esc(esc(argname)))) || $(esc(esc(func)))($(esc(esc(argname)))))
            _quit_try_help($errstr)
        end
    end
end

"""
    @allowextraarguments

Disables the default behavior of printing a message and exiting
the program when not all values in `ARGS` could be assigned to
specified arguments.

This will not capture any arguments, use `@positionalleftover`
if you want to capture extra arguments that could not otherwise
be assigned.

Must be used in `@beginarguments begin ... end` block

# Example
```julia
@beginarguments begin
    ...
    @allowextraarguments
end
```
"""
macro allowextraarguments()
    return quote
        allowextraargs = true
    end
end
