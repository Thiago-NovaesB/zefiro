using DataFrames
using CSV
using Tables

const year2hour = 8760
const percent = 100

include("types.jl")
include("loadcase.jl")
include("generation.jl")
include("P&C.jl")
include("P&A.jl")