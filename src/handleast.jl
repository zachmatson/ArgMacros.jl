# ArgMacros
# handleast.jl

"Extract name of macro and change from `ArgMacros.@...` to `@...`"
function _get_macroname(arg::Expr)::Symbol
    return arg.args[1] isa Expr && arg.args[1].head == :. && arg.args[1].args[1] == :ArgMacros ?
                arg.args[1].args[2].value :
                arg.args[1]
end

"""
Enforce argument declaration ordering:  
    Flagged → Required Positional → Optional Positional

Throw `ArgumentError` if ordering violates this rule.
"""
function _validateorder(block::Expr)
    encountered_description = false
    encountered_argument = false
    encountered_positional = false
    encoundered_optional_positional = false
    
    for arg in block.args
        # Only check the macro calls
        if arg isa Expr && arg.head == :macrocall
            # Fix namespace issues
            macroname::Symbol = _get_macroname(arg)

            if macroname == usage_symbol
                if encountered_description || encountered_argument
                    throw(ArgumentError(
                        "Usage must be stated before description or arguments.\nFrom: $arg"
                    ))
                end
            elseif macroname == description_symbol
                encountered_description = true

                if encountered_argument
                    throw(ArgumentError(
                        "Description must be stated before any arguments.\nFrom: $arg"
                    ))
                end
            elseif macroname in flagged_symbols
                encountered_argument = true

                if encountered_positional
                    throw(ArgumentError(
                        "Positional arguments must be declared after all flagged arguments.\nFrom: $arg"
                    ))
                end
            elseif macroname == positional_required_symbol
                encountered_argument = true
                encountered_positional = true

                if encoundered_optional_positional
                    throw(ArgumentError(
                        "Required positional arguments must be declared in order before all optional positional arguments.\nFrom: $arg"
                    ))
                end
            elseif macroname in positional_optional_symbols
                encountered_argument = true
                encountered_positional = true
                encoundered_optional_positional = true
            end
        end
    end
end
