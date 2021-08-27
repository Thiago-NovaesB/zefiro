using Base: Float64
include("include.jl")
include("types.jl")
include("loadcase.jl")
include("generation.jl")

PATHCASE = "example"

options = zefiroOptions(PATHCASE=PATHCASE)
sizes = zefiroSizes()
data = zefiroData()

load!(options,sizes,data)

evaluateEnergy!(options,sizes,data)
