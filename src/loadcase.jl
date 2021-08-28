function load!(options::zefiroOptions,sizes::zefiroSizes,data::zefiroData)
    println("loading wind data")
    loadwind!(options,sizes,data)
    println("wind data loaded")

    println("loading turbine data")
    loadturbine!(options,sizes,data)
    println("turbine data loaded")

    println("initialize! data")
    initialize!(options,sizes,data)
    println("initialize! loaded")

    nothing
end


function loadwind!(options::zefiroOptions,sizes::zefiroSizes,data::zefiroData)
    windPath = joinpath(options.PATHCASE,"wind.csv")
    windFile = CSV.File(windPath,header=0) |> Tables.matrix

    data.windnames = windFile[1,2:end]
    data.onshoreDistance = parse.(Float64,windFile[2,2:end])
    data.offshoreDistance = parse.(Float64,windFile[3,2:end])
    data.surveysCost = parse.(Float64,windFile[4,2:end])
    data.vesselTimeWT = parse.(Float64,windFile[5,2:end])
    data.vesselTimeSS = parse.(Float64,windFile[6,2:end])
    data.WD = parse.(Float64,windFile[7,2:end])
    data.Ntln = parse.(Int,windFile[8,2:end])
    data.Ctln = parse.(Float64,windFile[9,2:end])
    data.Ntlf = parse.(Float64,windFile[10,2:end])
    data.Ctlf = parse.(Float64,windFile[11,2:end])
    data.Cprot = parse.(Float64,windFile[12,2:end])

    data.windspeed = parse.(Float64,windFile[13:end,1])
    data.RFwindspeed = parse.(Float64,windFile[13:end,2:end])
    sizes.winds = length(data.windnames)


    nothing
end

function loadturbine!(options::zefiroOptions,sizes::zefiroSizes,data::zefiroData)
    turbinePath = joinpath(options.PATHCASE,"turbines.csv")
    turbineFile = CSV.File(turbinePath,header=0) |> Tables.matrix

    data.turbinenames = turbineFile[1,2:end]
    data.turbineQuantity = parse.(Int,turbineFile[2,2:end])
    data.turbinePR = parse.(Float64,turbineFile[3,2:end])
    data.height = parse.(Float64,turbineFile[4,2:end])
    data.diameter = parse.(Float64,turbineFile[5,2:end])

    windspeed = turbineFile[6:end,1]
    if parse.(Float64,windspeed) != data.windspeed
        error("wind speed is inconsistenty")
    end

    powercurve = turbineFile[6:end,2:end]
    data.powercurve = parse.(Float64,powercurve)
    sizes.turbines = length(data.turbinenames)

    nothing
end

function initialize!(options::zefiroOptions,sizes::zefiroSizes,data::zefiroData)

    data.CAPEX = zeros(sizes.winds,sizes.turbines)
    data.CAPEXrate = zeros(sizes.winds,sizes.turbines)
    data.OPEX = zeros(sizes.winds,sizes.turbines)
    data.OPEXrate = zeros(sizes.winds,sizes.turbines)
    data.DECOM = zeros(sizes.winds,sizes.turbines)
    data.DECOMrate = zeros(sizes.winds,sizes.turbines)

    data.IC = data.turbinePR.*data.turbineQuantity
    nothing
end