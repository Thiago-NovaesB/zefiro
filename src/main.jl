using Base: Float64
include("include.jl")

PATHCASE = "example"

options = zefiroOptions(PATHCASE=PATHCASE)
sizes = zefiroSizes()
data = zefiroData()

load!(options,sizes,data)

evaluateEnergy!(options,sizes,data)
PCCost!(options,sizes,data)


@show data.CAPEXrate
