using Base: Float64
include("include.jl")

PATHCASE = "example"

options = zefiroOptions(PATHCASE=PATHCASE)
sizes = zefiroSizes()
data = zefiroData()
output = zefiroOutput()

load!(options,sizes,data,output)

evaluateEnergy!(options,sizes,data,output)

PCCost!(options,sizes,data,output)
PACost!(options,sizes,data,output)
ICCost!(options,sizes,data,output)

CAPEX!(options,sizes,data,output)

OMCost!(options,sizes,data,output)
DDCost!(options,sizes,data,output)

postprocess!(options,sizes,data,output)
output!(options,sizes,data,output)


