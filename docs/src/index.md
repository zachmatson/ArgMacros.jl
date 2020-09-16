# Guide

This page will offer an introduction on using ArgMacros to read command-line arguments.
Reading through this before using the package is recommended.

!!! note

    Version 0.2.x of ArgMacros might be rough around some edge cases. 
    Make sure to test the interface you build before using it.
    If you notice any issues or want to request new features, create an issue on
    [GitHub](https://github.com/zachmatson/ArgMacros.jl)

## Why ArgMacros?

ArgMacros is designed for parsing arguments in command-line Julia scripts.
Compilation time is the greatest bottleneck for startup of scripts in Julia,
and is mostly unavoidable. ArgMacros provides quick parsing after compilation while
ensuring compilation time fast too.

ArgMacros also provides convenience when writing scripts by offering various and easily
interchangeable formats for outputting parsed arguments, a simple interface, and guaranteed
type safety of parsed arguments. Some output formats also provide static typing of the
argument variables.

## Installation

Install ArgMacros using Julia's Pkg package manager. Enter the Pkg prompt
by typing `]` at the REPL and then install:

```julia-repl
(@v1.5) pkg> add ArgMacros
```

Then load ArgMacros into your script with `using ArgMacros`.

## Argument Format Types

There are four formats for your program or script to receive the parsed arguments with ArgMacros,
all of which use the same interface for argument declaration:  
* Inline, typed local variables ([`@inlinearguments`](@ref))
* An automatically generated custom `struct` type ([`@structarguments`](@ref))
* `NamedTuple` ([`@tuplearguments`](@ref))
* `Dict` ([`@dictarguments`](@ref))

## Adding Arguments

All arguments must be declared using the macros provided, and all of the declarations must
exist within the [`@inlinearguments`](@ref) block, or other argument macro block, like so:
```julia
@inlinearguments begin
    *arguments go here*
end
```

The types of arguments supported are broken down into two categories:
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

You should make your argument types `Symbol`, `String`, or subtypes of `Number`.

Here is an example with some arguments:
```julia
@inlinearguments begin
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

Once an argument is decalred, you can be sure it holds a value of the
correct type. [`@argumentoptional`](@ref) and [`@positionaloptional`](@ref) will use the type `Union{T, Nothing}`,
however, and may also contain `nothing`. [`@argumentflag`](@ref) uses `Bool` and [`@argumentcount`](@ref) uses `Int`.
The other macros will all store the type specified.  

How exactly you use the values depends on the format used, the following will demonstrate the same arguments
with each of the available formats, and some of the consequences of each of them:

### Inline ([`@inlinearguments`](@ref))

The arguments are stored directly in local variables, which are statically typed. You can use them immediately
without any other boilerplate, but must respect the variable types. These variables, because they are typed, must
always be in local scope. You cannot put this block in a global scope.

```julia
function main()
    @inlinearguments begin
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

### Custom `struct` ([`@structarguments`](@ref))

A new `struct` type is created to store the arguments, and you can decide if it will be mutable.  
The zero-argument constructor function for the new type parses the arguments when it is called.  
You must *declare* the arguments in global scope due to the rules for type declarations,
but the constructor can be used anywhere.

The fields of the struct will all be typed.

```julia
# Declare mutable type Args and the arguments it will hold
@structarguments true Args begin
        @positionalrequired Int x
        @positionaldefault Int 5 y
        @positionaloptional Int z
end

function main()
    args = Args() # The arguments are parsed here

    println(args.x + args.y) # Prints x + y, the variables must be Ints
    println(isnothing(args.z)) # z might be nothing, because it was optional
    
    # These assignemnt operations would all fail if we made Args immutable instead
    args.z = nothing # It is fine to store values of type Nothing or Int in z now
    args.z = 8
    args.x = 5.5 # Raises an error, x must hold Int values
    args.y = nothing # Raises an error, only optional arguments can hold nothing
end
```

### `NamedTuple` ([`@tuplearguments`](@ref))

A `NamedTuple` is returned containing all of the argument values, keyed by the variable names given. You can use this
version from any scope. All of the fields are typed, and as a `NamedTuple` the returned object will be immutable.

```julia
function main()
    args = @tuplearguments begin
        @positionalrequired Int x
        @positionaldefault Int 5 y
        @positionaloptional Int z
    end

    println(args.x + args.y) # Prints x + y, the variables must be Ints
    println(isnothing(args.z)) # z might be nothing, because it was optional
    
    # These assignemnt operations will fail because NamedTuples are always immutable
    args.z = nothing
    args.z = 8

    args.x == 5.5 # Can never be true, args.x is guaranteed to be an Int
    isnothing(args.y) # Must be false, y is not optional
end
```

### `Dict` ([`@dictarguments`](@ref))

A `Dict{Symbol, Any}` is returned containing all of the argument variables, keyed by the argument names as *`Symbol`s*. You can use
this version from any scope. The `Dict` type is mutable, and any type can be stored in any of its fields. Therefore, this version
does not provide as strong of a guarantee about types to the compuler when argument values are used later. However, the values
will always be of the correct types when the `Dict` is first returned.

```julia
function main()
    args = @dictarguments begin
        @positionalrequired Int x
        @positionaldefault Int 5 y
        @positionaloptional Int z
    end

    println(args[:x] + args[:y]) # Prints x + y, the variable names are available right away and must be Ints at first
    println(isnothing(args[:z])) # z might be nothing, because it was optional
    args[:z] = nothing # It is fine to store values of any type in z now
    args[:z] = 8
    args[:x] = 5.5 # Same for x
    args[:y] = nothing # And y
    args[:a] = "some string" # New entries can even be added later, of any type
end
```

## Validating Arguments

Perhaps you want to impose certain conditions on the values of an argument beyond its type.
You can use the [`@argtest`](@ref) macro, which will exit the program if a specified unary predicate returns
`false` for the argument value.

If using an operator function, make sure to enclose it in parentheses so it is passed to the 
macro as a separate expression from the first argument.

```julia
@inlinearguments begin
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
beginning of the `@...arguments` block, but this is not a requirement.

```julia
@inlinearguments begin
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

This can occur anywhere inside the `@...arguments` block, but the recommended placement is at the end,
after all other help, test, and argument declarations.

```julia
@inlinearguments begin
    ...
    @allowextraarguments
end
```

## Taking Argument Code out of Main Function

It may be preferable, in some cases, not to declare all of your arguments and help information
inside of your main function. In this case, the [`@inlinearguments`](@ref) block can be enclosed
in a macro:

```julia
macro handleargs()
    return esc(quote
        @inlinearguments begin
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

The other formats provide more flexibility. The argument code for [`@tuplearguments`](@ref) and [`@dictarguments`](@ref)
can be placed anywhere, including in a separate function which returns their result. [`@structarguments`](@ref) requires
that you declare your arguments in the global namespace (not inside a function, loop, or `let` block), but this will automatically
produce the zero-argument constructor function that you can then call wherever you like.
