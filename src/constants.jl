# ArgMacros
# constants.jl

const USAGE_SYMBOL = Symbol("@helpusage")
const DESCRIPTION_SYMBOL = Symbol("@helpdescription")
const EPILOG_SYMBOL = Symbol("@helpepilog")
const ARGHELP_SYMBOL = Symbol("@arghelp")

const ARGUMENT_REQUIRED_SYMBOL = Symbol("@argumentrequired")
const ARGUMENT_DEFAULT_SYMBOL = Symbol("@argumentdefault")
const ARGUMENT_OPTIONAL_SYMBOL = Symbol("@argumentoptional")
const ARGUMENT_FLAG_SYMBOL = Symbol("@argumentflag")
const ARGUMENT_COUNT_SYMBOL = Symbol("@argumentcount")
const FLAGGED_SYMBOLS = [ARGUMENT_REQUIRED_SYMBOL, ARGUMENT_DEFAULT_SYMBOL, ARGUMENT_OPTIONAL_SYMBOL,
                         ARGUMENT_FLAG_SYMBOL, ARGUMENT_COUNT_SYMBOL]

const POSITIONAL_REQUIRED_SYMBOL = Symbol("@positionalrequired")
const POSITIONAL_DEFAULT_SYMBOL = Symbol("@positionaldefault")
const POSITIONAL_OPTIONAL_SYMBOL = Symbol("@positionaloptional")
const POSITIONAL_OPTIONAL_SYMBOLS = [POSITIONAL_DEFAULT_SYMBOL, POSITIONAL_OPTIONAL_SYMBOL]
