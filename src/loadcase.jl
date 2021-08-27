function load!(options::zefiroOptions,sizes::zefiroSizes,data::zefiroData)
    println("loading wind data")
    loadwind!(options,sizes,data)
    println("wind data loaded")

    println("loading turbine data")
    loadturbine!(options,sizes,data)
    println("turbine data loaded")

    nothing
end


function loadwind!(options::zefiroOptions,sizes::zefiroSizes,data::zefiroData)
    windPath = joinpath(options.PATHCASE,"wind.csv")
    windFile = CSV.File(windPath,header=0) |> Tables.matrix

    windspeed = windFile[2:end,1]
    RFwindspeed = windFile[2:end,2:end]


    data.windnames = windFile[1,2:end]
    data.windspeed = parse.(Float64,windspeed)
    data.RFwindspeed = parse.(Float64,RFwindspeed)
    sizes.winds = length(data.windnames)

    nothing
end

function loadturbine!(options::zefiroOptions,sizes::zefiroSizes,data::zefiroData)
    turbinePath = joinpath(options.PATHCASE,"turbines.csv")
    turbineFile = CSV.File(turbinePath,header=0) |> Tables.matrix

    data.turbinenames = turbineFile[1,2:end]
    data.turbinequantity = parse.(Int,turbineFile[2,2:end])

    windspeed = turbineFile[3:end,1]
    if parse.(Float64,windspeed) != data.windspeed
        error("wind speed is inconsistenty")
    end

    powercurve = turbineFile[3:end,2:end]
    data.powercurve = parse.(Float64,powercurve)
    sizes.turbines = length(data.turbinenames)

    nothing
end