# ArgMacros
# handleast.jl

"Extract name of macro and change from `ArgMacros.@...` to `@...`"
function _get_macroname(arg::Expr)::Symbol
    return arg.args[1] isa Expr && arg.args[1].head == :. && arg.args[1].args[1] == :ArgMacros ?
                arg.args[1].args[2].value :
                arg.args[1]
end

"Get the macrocall expressions from a block as a generator"
function _getmacrocalls(block::Expr)
    Iterators.filter(arg -> arg isa Expr && arg.head == :macrocall, block.args)
end

"""
Enforce argument declaration ordering:  
    Flagged → Required Positional → Optional Positional → Leftover Positional

Throw `ArgumentError` if ordering violates this rule.
"""
function _validateorder(block::Expr)
    encountered_positional = false
    encoundered_optional_positional = false
    encountered_leftover_positional = false
    
    for arg in _getmacrocalls(block)
        # Fix namespace issues
        macroname::Symbol = _get_macroname(arg)

        if macroname in FLAGGED_SYMBOLS
            if encountered_positional
                throw(ArgumentError(
                    "Positional arguments must be declared after all flagged arguments.\nFrom: $arg"
                ))
            end
        elseif macroname == POSITIONAL_REQUIRED_SYMBOL
            encountered_positional = true

            if encoundered_optional_positional
                throw(ArgumentError(
                    "Required positional arguments must be declared in order before all optional positional arguments.\nFrom: $arg"
                ))
            end
        elseif macroname in POSITIONAL_OPTIONAL_SYMBOLS
            encountered_positional = true
            encoundered_optional_positional = true

            if encountered_leftover_positional
                throw(ArgumentError(
                    "Leftover arguments must be declared after all other arguments.\nFrom: $arg"
                ))
            end
        elseif macroname == POSITIONAL_LEFTOVER_SYMBOL
            encountered_positional = true
            encoundered_optional_positional = true
            encountered_leftover_positional = true
        end
    end
end

"Extract name => type pair from argument macrocall expression"
function _getargumentpair(arg::Expr)::Union{Expr, Nothing}
    macroname::Symbol = _get_macroname(arg)

    if macroname in (ARGUMENT_DEFAULT_SYMBOL, POSITIONAL_DEFAULT_SYMBOL)
        :($(arg.args[5])::$(arg.args[3]))
    elseif macroname in (ARGUMENT_REQUIRED_SYMBOL, POSITIONAL_REQUIRED_SYMBOL)
        :($(arg.args[4])::$(arg.args[3]))
    elseif macroname in (ARGUMENT_OPTIONAL_SYMBOL, POSITIONAL_OPTIONAL_SYMBOL)
        :($(arg.args[4])::Union{$(arg.args[3]), Nothing})
    elseif macroname == POSITIONAL_LEFTOVER_SYMBOL
        :($(arg.args[4])::Vector{$(arg.args[3])})
    elseif macroname == ARGUMENT_FLAG_SYMBOL
        :($(arg.args[3])::Bool)
    elseif macroname == ARGUMENT_COUNT_SYMBOL
        :($(arg.args[3])::Int)
    end
end

"Extract name => type pairs for all argument macros in block"
function _getargumentpairs(block::Expr)
    Iterators.filter(!isnothing, _getargumentpair(arg) for arg in _getmacrocalls(block))
end
