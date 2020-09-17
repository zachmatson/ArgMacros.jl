# ArgMacros
# precompile.jl

# Made with help of SnoopCompile.jl
function _precompile_()
    ccall(:jl_generating_output, Cint, ()) == 1 || return nothing

    arg_types = (Float64, Float32, Int64, Int32, String, Symbol)
    for T in arg_types
        Base.precompile(Tuple{typeof(ArgMacros._converttype!),Type{T},String,String})
        Base.precompile(Tuple{typeof(ArgMacros._converttype!),Type{T},Nothing,String})
        for T2 in arg_types
            Base.precompile(Tuple{typeof(ArgMacros._converttype!),Type{T},T2,String})
        end
        Base.precompile(Tuple{typeof(convert),Type{Union{Nothing, T}},T})
        Base.precompile(Tuple{typeof(something),String,T})
    end
    Base.precompile(Tuple{typeof(ArgMacros._getmacrocalls),Expr})
    Base.precompile(Tuple{typeof(ArgMacros._get_macroname),Expr})
    Base.precompile(Tuple{typeof(ArgMacros._getargumentpairs),Expr})
    Base.precompile(Tuple{typeof(ArgMacros._getargumentpair),Expr})
    Base.precompile(Tuple{typeof(ArgMacros._validateorder),Expr})
    Base.precompile(Tuple{typeof(ArgMacros._split_arguments),Array{String,1}})
    Base.precompile(Tuple{typeof(ArgMacros._split_multiflag),String})
    Base.precompile(Tuple{typeof(ArgMacros._split_multiflag),SubString{String}})
    Base.precompile(Tuple{typeof(ArgMacros._help_check),Array{String,1},Expr})
    Base.precompile(Tuple{typeof(ArgMacros._get_option_idx),Array{String,1},Array{String,1}})
    Base.precompile(Tuple{typeof(ArgMacros._pop_argval!),Array{String,1},Array{String,1}})
    Base.precompile(Tuple{typeof(ArgMacros._pop_count!),Array{String,1},String})
    Base.precompile(Tuple{typeof(ArgMacros._pop_flag!),Array{String,1},Array{String,1}})
    Base.precompile(Tuple{typeof(ArgMacros._validateflags),Symbol,Tuple{String,String}})
    Base.precompile(Tuple{typeof(ArgMacros._validateflags),Symbol,Tuple{String}})
    
    Base.precompile(Tuple{typeof(Base.allocatedinline),Type{ArgMacros.Argument}})
    Base.precompile(Tuple{Type{Base.GC_Diff},Base.GC_Num,Base.GC_Num})
    Base.precompile(Tuple{typeof(getproperty),Base.GC_Diff,Symbol})
    Base.precompile(Tuple{typeof(Base.gc_alloc_count),Base.GC_Diff})
    Base.precompile(Tuple{typeof(Base.gc_num)})
    Base.precompile(Tuple{typeof(include),String})
    Base.precompile(Tuple{typeof(isnothing),String})
    Base.precompile(Tuple{Type{Base.Generator},Type{QuoteNode},Array{Any,1}})
    Base.precompile(Tuple{typeof(collect),Base.Generator{Array{Any,1},Type{QuoteNode}}})
    Base.precompile(Tuple{typeof(collect),Base.Generator{Array{Any,1},typeof(esc)}})
    Base.precompile(Tuple{typeof(Base._compute_eltype),Type{Tuple{String,Expr}}})
    Base.precompile(Tuple{typeof(deleteat!),Array{String,1},Tuple{Int64,Int64}})
    Base.precompile(Tuple{typeof(deleteat!),Array{String,1},Int64})
end
