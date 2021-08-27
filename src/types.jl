"""
    @kwdef typedef
This is a helper macro that automatically defines a keyword-based constructor for the type
declared in the expression `typedef`, which must be a `struct` or `mutable struct`
expression. The default argument is supplied by declaring fields of the form `field::T =
default`. If no default is provided then the default is provided by the `kwdef_val(T)`
function.
```julia
@kwdef struct Foo
    a::Cint            # implied default Cint(0)
    b::Cint = 1        # specified default
    z::Cstring         # implied default Cstring(C_NULL)
    y::Bar             # implied default Bar()
end
```
"""
macro kwdef(expr)
    expr = macroexpand(__module__, expr) # to expand @static
    expr isa Expr && expr.head === :struct || error("Invalid usage of @kwdef")
    expr = expr::Expr
    T = expr.args[2]
    if T isa Expr && T.head === :<:
        T = T.args[1]
    end

    params_ex = Expr(:parameters)
    call_args = Any[]

    _kwdef!(expr.args[3], params_ex.args, call_args)
    # Only define a constructor if the type has fields, otherwise we'll get a stack
    # overflow on construction
    if !isempty(params_ex.args)
        if T isa Symbol
            kwdefs = :(($(esc(T)))($params_ex) = ($(esc(T)))($(call_args...)))
        elseif T isa Expr && T.head === :curly
            T = T::Expr
            # if T == S{A<:AA,B<:BB}, define two methods
            #   S(...) = ...
            #   S{A,B}(...) where {A<:AA,B<:BB} = ...
            S = T.args[1]
            P = T.args[2:end]
            Q = Any[U isa Expr && U.head === :<: ? U.args[1] : U for U in P]
            SQ = :($S{$(Q...)})
            kwdefs = quote
                ($(esc(S)))($params_ex) =($(esc(S)))($(call_args...))
                ($(esc(SQ)))($params_ex) where {$(esc.(P)...)} =
                    ($(esc(SQ)))($(call_args...))
            end
        else
            error("Invalid usage of @kwdef")
        end
    else
        kwdefs = nothing
    end
    quote
        Base.@__doc__($(esc(expr)))
        $kwdefs
    end
end

# @kwdef helper function
# mutates arguments inplace
function _kwdef!(blk, params_args, call_args)
    for i in eachindex(blk.args)
        ei = blk.args[i]
        if ei isa Symbol
            #  var
            push!(params_args, ei)
            push!(call_args, ei)
        elseif ei isa Expr
            if ei.head === :(=)
                lhs = ei.args[1]
                if lhs isa Symbol
                    #  var = defexpr
                    var = lhs
                elseif lhs isa Expr && lhs.head === :(::) && lhs.args[1] isa Symbol
                    #  var::T = defexpr
                    var = lhs.args[1]
                else
                    # something else, e.g. inline inner constructor
                    #   F(...) = ...
                    continue
                end
                defexpr = ei.args[2]  # defexpr
                push!(params_args, Expr(:kw, var, esc(defexpr)))
                push!(call_args, var)
                blk.args[i] = lhs
            elseif ei.head === :(::) && ei.args[1] isa Symbol
                # var::Typ
                dec = ei # var::Typ
                var = dec.args[1] # var
                def = :(kwdef_val($(ei.args[2])))
                push!(params_args, Expr(:kw, var, def))
                push!(call_args, dec.args[1])
            elseif ei.head === :block
                # can arise with use of @static inside type decl
                _kwdef!(ei, params_args, call_args)
            end
        end
    end
    blk
end


"""
    kwdef_val(T)
The default value for a type for use with the `@kwdef` macro. Returns:
 - null pointer for pointer types (`Ptr{T}`, `Cstring`, `Cwstring`)
 - zero for integer types
 - no-argument constructor calls (e.g. `T()`) for all other types
"""
function kwdef_val end

kwdef_val(::Type{Ptr{T}}) where T = Ptr{T}(C_NULL)
kwdef_val(::Type{Cstring}) = Cstring(C_NULL)
kwdef_val(::Type{Cwstring}) = Cwstring(C_NULL)
kwdef_val(::Type{T}) where T<: Real = zero(T)
kwdef_val(::Type{T}) where T = T()
kwdef_val(::Type{T}) where T<: String = ""
kwdef_val(::Type{T}) where T<: Symbol = :NULL
kwdef_val(::Type{Array{T,N}}) where {T,N} = Array{T}(undef, zeros(Int,N)...)

# @kwdef type Foo
#     a::Cint            # implied default Cint(0)
#     b::Cint = 1        # specified default
#     z::Cstring         # implied default Cstring(C_NULL)
#     y::Float64             # implied default Bar()
#     w::Bool             # implied default Bar()
#     ss::String
# end

#############################

@kwdef mutable struct zefiroOptions
    PATHCASE::String
end

@kwdef mutable struct zefiroSizes
    winds::Int = 0
    turbines::Int = 0
end

@kwdef mutable struct zefiroData
    turbinenames::Array{String,1} = []
    turbinequantity::Array{Int,1} = []
    windnames::Array{String,1} = []
    windspeed::Array{Float64} = []
    RFwindspeed::Array{Float64} = []
    powercurve::Array{Float64} = []
    AEP::Array{Float64} = []
    CP::Array{Float64} = []
end