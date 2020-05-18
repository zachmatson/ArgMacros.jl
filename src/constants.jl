# ArgMacros
# constants.jl

const usage_symbol = Symbol("@helpusage")
const description_symbol = Symbol("@helpdescription")
const epilog_symbol = Symbol("@helpepilog")
const arghelp_symbol = Symbol("@arghelp")

const argument_required_symbol = Symbol("@argumentrequired")
const argument_default_symbol = Symbol("@argumentdefault")
const argument_optional_symbol = Symbol("@argumentoptional")
const argument_flag_symbol = Symbol("@argumentflag")
const argument_count_symbol = Symbol("@argumentcount")
const flagged_symbols = [argument_required_symbol, argument_default_symbol, argument_optional_symbol,
                         argument_flag_symbol, argument_count_symbol]

const positional_required_symbol = Symbol("@positionalrequired")
const positional_default_symbol = Symbol("@positionaldefault")
const positional_optional_symbol = Symbol("@positionaloptional")
const positional_optional_symbols = [positional_default_symbol, positional_optional_symbol]
