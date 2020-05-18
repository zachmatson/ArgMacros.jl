# Guide

This page will offer an introduction on using ArgMacros to read command-line arguments.
Reading through this before using the package is recommended.

!!! note

    Version 0.1.x of ArgMacros might be rough around some edge cases. 
    Make sure to test the interface you build before using it.
    If you notice any issues or want to request new features, create an issue on
    [GitHub](https://github.com/zachmatson/ArgMacros.jl)

## Why ArgMacros?

ArgMacros is designed for parsing arguments in command-line Julia scripts.
Compilation time is the greatest bottleneck for startup of scripts in Julia,
and is mostly unavoidable. While attention is paid to making
code that compiles relatively quickly, the emphasis of ArgMacros is on quick
parsing and type stability after compilation. 

Variables created using ArgMacros are statically typed,
and available immediately within your main function, without manually 
retrieving them from an intermediate data structure. This can also make it
more convenient when writing scripts.

## Installation

Install ArgMacros using Julia's Pkg package manager. Enter the Pkg prompt
by typing `]` at the REPL and then install:

```julia-repl
(@v1.4) pkg> add ArgMacros
```

Then load ArgMacros into your script with `using ArgMacros`.

## Adding Arguments

All arguments must be declared using the macros provided, and all of the declarations must
exist within the [`@beginarguments`](@ref) block like so:
```julia
@beginarguments begin
    *arguments go here*
end
```

The types of arguments supported are broken down into two main categories:
* Options (`@argument...`) - Marked with flags
  - [`@argumentrequired`](@ref)
  - [`@argumentdefault`](@ref)
  - [`@argumentoptional`](@ref)
  - [`@argumentflag`](@ref)
  - [`@argumentcount`](@ref)
* Positionals (`@positional...`) - Identified by position in argument list
  - [`@positionalrequired`](@ref)
  - [`@positionaldefault`](@ref)
  - [`@positionaloptional`](@ref)

The arguments are either required, optional, or have default values, as is evident
in their names. Additionally, [`@argumentflag`](@ref) checks the presence of a flag,
and [`@argumentcount`](@ref) counts how many times a flag appears. Most of the argument
types require specifying a type and a local variable name, while options also require flag(s)
to be specified, and default arguments require their default value to be specified.

Parsing is carried out by fetching values for the options first, then the positional
arguments. Values will be fetched in the order that arguments are declared. 
For this reason, ALL options must be declared before ANY positionals, required 
positionals must be declared before default/optional ones, and positional arguments
must be declared in the order the user is expected to enter them.

Here is an example with some arguments:
```julia
@beginarguments begin
    @argumentrequired String foo "-f" "--foo"
    @argumentdefault String "lorem ipsum" bar "--bar"
    @argumentflag verbose "-v"
    @positionalrequired String input "input_file"
    @positionaloptional String output "output_file"
end
```

As you can see, options allow using long option names, short option names, or both.
[`@argumentcount`](@ref) is a special case and only allows a single long or short name to be given.
Positionals allow an optional "help name" to be specified, which is presented to the user instead
of the name of local variable they will be stored in.

!!! note

    The ordering rules for argument declarations should be enforced at compile time,
    but making sure to follow them is essential to your code running properly.
    Additionally, make sure not to declare multiple arguments using the same flags.
    Other than the reserved `-h` and `--help` flags, this will not be detected automatically
    at compile time, and could lead to undefined behavior. 

## Using Argument Values

Once an argument is decalred, it is statically typed and you can be sure it holds a value of the
correct type. [`@argumentoptional`](@ref) and [`@positionaloptional`](@ref) will use the type `Union{T, Nothing}`,
however, and may also contain `nothing`. [`@argumentflag`](@ref) uses `Bool` and [`@argumentcount`](@ref) uses `Int`.
The other macros will all store the type specified. No additional code is required to begin using the 
argument value after parsing.

You should make your argument types `Symbol`, `String`, or subtypes of `Number`.

```julia
function main()
    @beginarguments begin
        @positionalrequired Int x
        @positionaldefault Int 5 y
        @positionaloptional Int z
    end

    println(x + y) # Prints x + y, the variable names are available right away and must be Ints
    println(isnothing(z)) # z might be nothing, because it was optional
    z = nothing # It is fine to store values of type Nothing or Int in z now
    z = 8
    x = 5.5 # Raises an error, x must hold Int values
    y = nothing # Raises an error, only optional arguments can hold nothing
end
```

## Validating Arguments

Perhaps you want to impose certain conditions on the values of an argument beyond its type.
You can use the [`@argtest`](@ref) macro, which will exit the program if a specified unary predicate returns
`false` for the argument value.

If using an anonymous function for this, make sure to enclose it in parentheses so it is passed to the 
macro as a single expression.

```julia
@beginarguments begin
    ...
    @positionalrequired String input "input_file"
    @argtest input isfile "The input must be a valid file" # Confirm that the input file really exists
    ...
end
```

## Adding Help

ArgMacros also allows you to create a help screen, accessed by the `-h` or `--help` flags.
A listing of arguments and their types is created by default, but usage information, 
a description, an epilog, and individual argument descriptions can be specified too using the appropriate macros.
When using the [`@arghelp`](@ref) macro, note that it always applies to the last argument declared BEFORE the macro is used.
The [`@helpusage`](@ref) will prepend your usage text with "Usage: ", so do not include this in the string you pass.

It is recommended to place [`@helpusage`](@ref), [`@helpdescription`](@ref), and [`@helpepilog`](@ref) in that order at the
beginning of the [`@beginarguments`](@ref) block, but this is not a requirement.

```julia
@beginarguments begin
    @helpusage "example.jl input_file [output_file] [-f | --foo] [--bar] [-v]"
    @helpdescription """
        Lorem ipsum dolor sit amet, consectetur adipiscing elit.
        Praesent eu auctor risus. Morbi a nisl nisi.
        Ut at lorem non lorem accumsan auctor. Class aptent taciti
        sociosqu ad litora torquent per conubia nostra, per inceptos
        himenaeos. Aenean ornare ultrices tellus quis convallis.
        """
    @helpepilog "© 2020"
    ...
    @positionalrequired String input "input_file"
    @argtest input isfile "The input must be a valid file"
    @arghelp "The name of the file to be taken as input."
    ...
end
```

## Leftover Arguments

By default, the program will exit and print a warning if more arguments are given than the program declares.
If you don't want this to happen, include the [`@allowextraarguments`](@ref) macro.

This can occur anywhere inside the [`@beginarguments`](@ref) block, but the recommended placement is at the end,
after all other help, test, and argument declarations.

```julia
@beginarguments begin
    ...
    @allowextraarguments
end
```

## Taking Argument Code out of Main Function

It may be preferable, in some cases, not to declare all of your arguments and help information
inside of your main function. In this case, the [`@beginarguments`](@ref) block can be enclosed
in a macro:

```julia
macro handleargs()
    return esc(quote
        @beginarguments begin
            ...
        end
    end)
end

function main()
    @handleargs
    ...
    # The argument values will be available here
end
```
