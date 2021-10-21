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
    projectManagement::Int = 0
    legalAuthorization::Int = 0
    surveys::Int = 0
    engineering::Int = 0
    contingencies::Int = 0
    windTurbine::Int = 0
    supportStructures::Int = 0
    powerTransmissionSystem::Int = 0
    monitoringSystem::Int = 0
    port::Int = 0
    installationOfTheComponents::Int = 0
    commissioning::Int = 0
    insurance::Int = 0
    operation::Int = 0
    maintenance::Int = 0
    decommissioning::Int = 0
    wasteManagement::Int = 0
    siteClearance::Int = 0
    postMonitoring::Int = 0

    postprocess::Bool = false


end

@kwdef mutable struct zefiroSizes
    winds::Int = 0
    turbines::Int = 0
end

@kwdef mutable struct zefiroData
    turbinenames::Array{String,1} = []
    turbineQuantity::Array{Int,1} = []
    turbinePR::Array{Float64,1} = []
    height::Array{Float64,1} = []
    diameter::Array{Float64,1} = []
    powercurve::Array{Float64} = []
    N1d::Array{Float64,1} = []
    Ccomp::Array{Float64,1} = []
    Ncom::Array{Float64,1} = []
    Lcom::Array{Float64,1} = []
    N1dOM::Array{Float64,1} = []
    LrOM::Array{Float64,1} = []
    Pd::Array{Float64,1} = []
    lambda::Array{Float64,1} = []
    Csm::Array{Float64,1} = []

    Wjproc::Array{Float64,1} = []
    Cjproc::Array{Float64,1} = []
    Wjtrans::Array{Float64,1} = []
    Wttrans::Array{Float64,1} = []
    Cjtrnas::Array{Float64,1} = []
    Wnr::Array{Float64,1} = []
    Cnr::Array{Float64,1} = []
    Wr::Array{Float64,1} = []
    SV::Array{Float64,1} = []



    windnames::Array{String,1} = []
    windspeed::Array{Float64} = []
    RFwindspeed::Array{Float64} = []
    onshoreDistance::Array{Float64,1} = []
    offshoreDistance::Array{Float64,1} = []
    surveysCost::Array{Float64,1} = []
    vesselTimeWT::Array{Float64,1} = []
    vesselTimeSS::Array{Float64,1} = []
    WD::Array{Float64,1} = []
    Ntln::Array{Int,1} = []
    Ctln::Array{Float64,1} = []
    Ntlf::Array{Int,1} = []
    Ctlf::Array{Float64,1} = []
    Cprot::Array{Float64,1} = []
    Cport::Array{Float64,1} = []
    Lr::Array{Float64,1} = []
    Cins::Array{Float64,1} = []
    l::Array{Float64,1} = []
    Pe::Array{Float64,1} = []
    ComIns::Array{Float64,1} = []
    Ctransunit::Array{Float64,1} = []
    d::Array{Float64,1} = []
    tc::Array{Float64,1} = []
    Cindport::Array{Float64,1} = []
    Cindves::Array{Float64,1} = []
    Cindlab::Array{Float64,1} = []
    Cddport::Array{Float64,1} = []
    Nddport::Array{Float64,1} = []
    Lddport::Array{Float64,1} = []
    Nremove::Array{Float64,1} = []
    Vremove::Array{Float64,1} = []
    Asc::Array{Float64,1} = []
    Cscunit::Array{Float64,1} = []

    IC::Array{Float64} = []

    vesselCost::Float64 = 10000.0
    engVerifCost::Float64 = 8000.0
    baseCost::Float64 = 8000.0
    engUnitCost::Float64 = 20000.0
    scadaCost::Float64 = 250000
    cmsCost::Float64 = 250000
    consumCost::Float64 = 20000
    duration::Int32 = 20
    postCost::Float64 = 3600000
    r::Float64 = 0.1
end


@kwdef mutable struct zefiroOutput
    projectManagement::Array{Float64,2}
    legalAuthorization::Array{Float64,2}
    surveys::Array{Float64,2}
    engineering::Array{Float64,2}
    contingencies::Array{Float64,2}
    windTurbine::Array{Float64,2}
    supportStructures::Array{Float64,2}
    powerTransmissionSystem::Array{Float64,2}
    monitoringSystem::Array{Float64,2}
    port::Array{Float64,2}
    installationOfTheComponents::Array{Float64,2}
    commissioning::Array{Float64,2}
    insurance::Array{Float64,2}
    operation::Array{Float64,2}
    maintenance::Array{Float64,2}
    decommissioning::Array{Float64,2}
    wasteManagement::Array{Float64,2}
    siteClearance::Array{Float64,2}
    postMonitoring::Array{Float64,2}

    P_C::Array{Float64,2}
    P_A::Array{Float64,2}
    O_M::Array{Float64,2}
    I_C::Array{Float64,2}
    D_D::Array{Float64,2}

    LCOE::Array{Float64,2}

    AEP::Array{Float64,2}
    CP::Array{Float64,2}
    CAPEX::Array{Float64,2}
    CAPEXrate::Array{Float64,2}
    OPEX::Array{Float64,2}
    DECOM::Array{Float64,2}
end