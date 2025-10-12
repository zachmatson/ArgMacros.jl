println("Times for 11 argument example using all macros")
println("Load Time (using ArgMacros)")
@time using ArgMacros
using Test

# Commands Set 1
let
    empty!(ARGS)
    append!(ARGS, ["TEST STRING F", "-deeee", "30", "3.14", "-b=6.28", "--cc", "ArgMacros", "-a", "2", "4", "5", "6"])

    println("Inline Arguments Time with Precompile")
    let
        @time @inlinearguments begin
            @argumentrequired Int a "-a" "--aa"
            @argtest a (<(10))
            @argumentdefault Float64 10 b "-b"
            @argumentoptional Symbol c "--cc"
            @argumentflag d "-d"
            @argumentcount e "-e"

            @positionalrequired String f
            @positionaldefault Int 20 g
            @argtest g (x -> x % 10 == 0)
            @positionaloptional Float64 h
            @positionalleftover Int64 i
        end
    end

    println("Inline Arguments Time")
    @time @inlinearguments begin
        @argumentrequired Int a "-a" "--aa"
        @argtest a (<(10))
        @argumentdefault Float64 10 b "-b"
        @argumentoptional Symbol c "--cc"
        @argumentflag d "-d"
        @argumentcount e "-e"

        @positionalrequired String f
        @positionaldefault Int 20 g
        @argtest g (x -> x % 10 == 0)
        @positionaloptional Float64 h
        @positionalleftover Int64 i
    end

    println("Struct Arguments Time")
    @time begin
        @structarguments false ArgsStruct begin
            @argumentrequired Int a "-a" "--aa"
            @argtest a (<(10))
            @argumentdefault Float64 10 b "-b"
            @argumentoptional Symbol c "--cc"
            @argumentflag d "-d"
            @argumentcount e "-e"
        
            @positionalrequired String f
            @positionaldefault Int 20 g
            @argtest g (x -> x % 10 == 0)
            @positionaloptional Float64 h
            @positionalleftover Int64 i
        end

        argsstruct = ArgsStruct()
    end

    println("Tuple Arguments Time")
    @time argstuple = @tuplearguments begin
        @argumentrequired Int a "-a" "--aa"
        @argtest a (<(10))
        @argumentdefault Float64 10 b "-b"
        @argumentoptional Symbol c "--cc"
        @argumentflag d "-d"
        @argumentcount e "-e"

        @positionalrequired String f
        @positionaldefault Int 20 g
        @argtest g (x -> x % 10 == 0)
        @positionaloptional Float64 h
        @positionalleftover Int64 i
    end

    println("Dict Arguments Time")
    @time argsdict = @dictarguments begin
        @argumentrequired Int a "-a" "--aa"
        @argtest a (<(10))
        @argumentdefault Float64 10 b "-b"
        @argumentoptional Symbol c "--cc"
        @argumentflag d "-d"
        @argumentcount e "-e"

        @positionalrequired String f
        @positionaldefault Int 20 g
        @argtest g (x -> x % 10 == 0)
        @positionaloptional Float64 h
        @positionalleftover Int64 i
    end

    @testset "Correct, All Arguments" begin
        @testset "Inline" begin
            @test a == 2
            @test b == 6.28
            @test c == :ArgMacros
            @test d
            @test e == 4
            @test f == "TEST STRING F"
            @test g == 30
            @test h == 3.14
            @test i == [4, 5, 6]
        end

        @testset "Struct" begin
            @test argsstruct.a == 2
            @test argsstruct.b == 6.28
            @test argsstruct.c == :ArgMacros
            @test argsstruct.d
            @test argsstruct.e == 4
            @test argsstruct.f == "TEST STRING F"
            @test argsstruct.g == 30
            @test argsstruct.h == 3.14
            @test argsstruct.i == [4, 5, 6]
        end

        @testset "Tuple" begin
            @test argstuple.a == 2
            @test argstuple.b == 6.28
            @test argstuple.c == :ArgMacros
            @test argstuple.d
            @test argstuple.e == 4
            @test argstuple.f == "TEST STRING F"
            @test argstuple.g == 30
            @test argstuple.h == 3.14
            @test argstuple.i == [4, 5, 6]
        end

        @testset "Dict" begin
            @test argsdict[:a] == 2
            @test argsdict[:b] == 6.28
            @test argsdict[:c] == :ArgMacros
            @test argsdict[:d]
            @test argsdict[:e] == 4
            @test argsdict[:f] == "TEST STRING F"
            @test argsdict[:g] == 30
            @test argsdict[:h] == 3.14
            @test argsdict[:i] == [4, 5, 6]
        end
    end
end

# Commands Set 2
let
    empty!(ARGS)
    append!(ARGS, ["OTHER TEST STRING F", "--aa=5"])

    @inlinearguments begin
        @argumentrequired Int a "-a" "--aa"
        @argtest a (<(10))
        @argumentdefault Float64 10 b "-b"
        @argumentoptional Symbol c "--cc"
        @argumentflag d "-d"
        @argumentcount e "-e"

        @positionalrequired String f
        @positionaldefault Int 20 g
        @argtest g (x -> x % 10 == 0)
        @positionaloptional Float64 h
        @positionalleftover Int64 i
    end

    @structarguments false ArgsStruct begin
        @argumentrequired Int a "-a" "--aa"
        @argtest a (<(10))
        @argumentdefault Float64 10 b "-b"
        @argumentoptional Symbol c "--cc"
        @argumentflag d "-d"
        @argumentcount e "-e"
    
        @positionalrequired String f
        @positionaldefault Int 20 g
        @argtest g (x -> x % 10 == 0)
        @positionaloptional Float64 h
        @positionalleftover Int64 i
    end

    argsstruct = ArgsStruct()

    argstuple = @tuplearguments begin
        @argumentrequired Int a "-a" "--aa"
        @argtest a (<(10))
        @argumentdefault Float64 10 b "-b"
        @argumentoptional Symbol c "--cc"
        @argumentflag d "-d"
        @argumentcount e "-e"

        @positionalrequired String f
        @positionaldefault Int 20 g
        @argtest g (x -> x % 10 == 0)
        @positionaloptional Float64 h
        @positionalleftover Int64 i
    end

    argsdict = @dictarguments begin
        @argumentrequired Int a "-a" "--aa"
        @argtest a (<(10))
        @argumentdefault Float64 10 b "-b"
        @argumentoptional Symbol c "--cc"
        @argumentflag d "-d"
        @argumentcount e "-e"

        @positionalrequired String f
        @positionaldefault Int 20 g
        @argtest g (x -> x % 10 == 0)
        @positionaloptional Float64 h
        @positionalleftover Int64 i
    end

    @testset "Correct, Minimal Arguments" begin
        @testset "Inline" begin
            @test a == 5
            @test b == 10.0
            @test isnothing(c)
            @test !d
            @test e == 0
            @test f == "OTHER TEST STRING F"
            @test g == 20
            @test isnothing(h)
            @test isempty(i)
        end

        @testset "Struct" begin
            @test argsstruct.a == 5
            @test argsstruct.b == 10.0
            @test isnothing(argsstruct.c)
            @test !argsstruct.d
            @test argsstruct.e == 0
            @test argsstruct.f == "OTHER TEST STRING F"
            @test argsstruct.g == 20
            @test isnothing(argsstruct.h)
            @test isempty(argsstruct.i)
        end

        @testset "Tuple" begin
            @test argstuple.a == 5
            @test argstuple.b == 10.0
            @test isnothing(argstuple.c)
            @test !argstuple.d
            @test argstuple.e == 0
            @test argstuple.f == "OTHER TEST STRING F"
            @test argstuple.g == 20
            @test isnothing(argstuple.h)
            @test isempty(argstuple.i)
        end

        @testset "Dict" begin
            @test argsdict[:a] == 5
            @test argsdict[:b] == 10.0
            @test isnothing(argsdict[:c])
            @test !argsdict[:d]
            @test argsdict[:e] == 0
            @test argsdict[:f] == "OTHER TEST STRING F"
            @test argsdict[:g] == 20
            @test isnothing(argsdict[:h])
            @test isempty(argsdict[:i])
        end
    end
end

# Error to capture code from a mocked exit
struct TestExitError <: Exception
    code::Int
end

# Run ArgMacros code with `exit()` mocked
macro test_exit_code(block::Expr)
    quote
        code = -1 # Return -1 if we never exit
        original_exit_function = ArgMacros._exit_function

        try
            ArgMacros._exit_function = (code::Int) -> throw(TestExitError(code))
            $(esc(block))
        catch e
            if e isa TestExitError
                code = e.code
            else
                throw(e)
            end
        finally
            ArgMacros._exit_function = original_exit_function
        end

        code
    end
end

function exits_with_error(args)
    empty!(ARGS)
    append!(ARGS, args)

    code = @test_exit_code begin
        @inlinearguments begin
            @argumentrequired Int a "-a" "--aa"
            @argtest a (<(10))
            @argumentdefault Float64 10 b "-b"
            @argumentoptional Symbol c "--cc"
            @argumentflag d "-d"
            @argumentcount e "-e"

            @positionalrequired String f
            @positionaldefault Int 20 g
            @argtest g (x -> x % 10 == 0)
            @positionaloptional Float64 h
        end
    end

    code > 0
end

@testset "Incorrect Arguments Rejected" begin
    # Double-check that everything works when using the correct args
    @test !exits_with_error(["TEST STRING F", "-deeee", "30", "3.14", "-b=6.28", "--cc", "ArgMacros", "-a", "2"])
    # These should fail
    @test exits_with_error(["30", "3.14", "-d", "-eeee", "-b", "6.28", "--cc", "ArgMacros", "-a", "2"])
    @test exits_with_error(["TEST", "STRING", "F", "30", "3.14", "-d", "-eeee", "-b", "6.28", "--cc", "ArgMacros", "-a", "2"])
    @test exits_with_error(["TEST STRING F", "23.3", "3.14", "-d", "-eeee", "-b", "6.28", "--cc", "ArgMacros", "-a", "2"])
    @test exits_with_error(["TEST STRING F", "-eeee", "25", "3.14", "-d", "-b", "6.28", "--cc", "ArgMacros", "-a", "2"])
    @test exits_with_error(["TEST STRING F", "30", "cat", "-deeee", "-b=6.28", "--cc", "ArgMacros", "-a", "2"])
    @test exits_with_error(["TEST STRING F", "30", "3.14", "-deeee", "-b=dog", "--cc", "ArgMacros", "-a", "2"])
    @test exits_with_error(["TEST STRING F", "30", "3.14", "-deeee", "-b=6.28", "--cc", "ArgMacros", "-a", "bird"])
    @test exits_with_error(["TEST STRING F", "30", "3.14", "-deeee", "-b=6.28", "--cc", "ArgMacros"])

end

@testset "Help Triggered Properly" begin
    # Checking that something that would otherwise fail does not fail when help is requested
    @test exits_with_error(["30", "3.14", "-d", "-eeee", "-b", "6.28", "--cc", "ArgMacros", "-a", "2"])
    @test !exits_with_error(["30", "3.14", "--help", "-d", "-eeee", "-b", "6.28", "--cc", "ArgMacros", "-a", "2"])
    @test !exits_with_error(["30", "3.14", "-h", "-d", "-eeee", "-b", "6.28", "--cc", "ArgMacros", "-a", "2"])
    @test exits_with_error([])
    @test !exits_with_error(["--help"])
    @test !exits_with_error(["-h"])
end

println("Time for 8 argument script cold launch and parsing including Julia start")
@time run(`julia --project=.. parse_example_args.jl "TEST STRING F" -deeee 30 3.14 -b=6.28 --cc ArgMacros -a 2`)
println("Time for Julia start only")
@time run(`julia --project=.. blank_script.jl`)
