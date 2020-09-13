using ArgMacros

let
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

# Intentionally throw non-zero exit
# So we can tell if a zero exit occurred before this
exit(1)