# Available Macros

## `@...arguments`

The `@...arguments begin ... end` block will hold all of your `ArgMacros` code.
The [Using Argument Values](@ref) section provides a good comparison of the different available macros.
```@docs
@inlinearguments
@structarguments
@tuplearguments
@dictarguments
```

## Option Arguments

These arguments are specified by long and/or short flags (e.g. `-v`, `--verbose`), and all follow a similar format.    
It is important to put these before positional arguments.    
Additionally, it is recommended to specify the short flag first when using multiple flags.

```@docs
@argumentrequired
@argumentdefault
@argumentoptional
@argumentflag
@argumentcount
```

## Positional Arguments

These arguments are specified by their position in the command.
You must specify these in your code in the same order that users are expected to enter them.
It is important to put these after all option arguments, and specify the required positional arguments first.

```@docs
@positionalrequired
@positionaldefault
@positionaloptional
```

## Help Options

These macros are used to generate the help screen for your program.
Note that usage will NOT be automatically generated if it is unspecified.

`@helpusage`, `@helpdescription`, and `@helpepilog` can be placed anywhere in the `@beginarguments` block with identical effect.
However, placing them in that order at the beginning of the block is recommended.

`@arghelp`, however, will always apply to the last argument declared before it appears.

```@docs
@helpusage
@helpdescription
@helpepilog
@arghelp
```

## Additional Options

These options can be used to validate argument values or change parsing behavior.

It is recommended to place `@argtest` immediately after the argument it applies to,
and `@allowextraarguments` before or after all of the arguments are declared.

```@docs
@argtest
@allowextraarguments
```

## Index
```@index
```