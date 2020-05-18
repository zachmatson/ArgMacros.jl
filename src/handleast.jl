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
    encountered_positional = false
    encoundered_optional_positional = false
    
    for arg in block.args
        # Only check the macro calls
        if arg isa Expr && arg.head == :macrocall
            # Fix namespace issues
            macroname::Symbol = _get_macroname(arg)

            if macroname in flagged_symbols
                if encountered_positional
                    throw(ArgumentError(
                        "Positional arguments must be declared after all flagged arguments.\nFrom: $arg"
                    ))
                end
            elseif macroname == positional_required_symbol
                encountered_positional = true

                if encoundered_optional_positional
                    throw(ArgumentError(
                        "Required positional arguments must be declared in order before all optional positional arguments.\nFrom: $arg"
                    ))
                end
            elseif macroname in positional_optional_symbols
                encountered_positional = true
                encoundered_optional_positional = true
            end
        end
    end
end
