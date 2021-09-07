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
    data.Cport = parse.(Float64,windFile[13,2:end])
    data.Lr = parse.(Float64,windFile[14,2:end])
    data.Cins = parse.(Float64,windFile[15,2:end])

    data.l = parse.(Float64,windFile[16,2:end])
    data.Pe = parse.(Float64,windFile[17,2:end])
    data.ComIns = parse.(Float64,windFile[18,2:end])
    data.Ctransunit = parse.(Float64,windFile[19,2:end])
    data.d = parse.(Float64,windFile[20,2:end])
    data.tc = parse.(Float64,windFile[21,2:end])
    data.Cindport = parse.(Float64,windFile[22,2:end])
    data.Cindves = parse.(Float64,windFile[23,2:end])
    data.Cindlab = parse.(Float64,windFile[24,2:end])


    data.windspeed = parse.(Float64,windFile[25:end,1])
    data.RFwindspeed = parse.(Float64,windFile[25:end,2:end])
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

    data.N1d = parse.(Float64,turbineFile[6,2:end])
    data.Ccomp = parse.(Float64,turbineFile[7,2:end])
    data.Ncom = parse.(Float64,turbineFile[8,2:end])
    data.Lcom = parse.(Float64,turbineFile[9,2:end])

    data.N1dOM = parse.(Float64,turbineFile[10,2:end])
    data.LrOM = parse.(Float64,turbineFile[11,2:end])
    data.Pd = parse.(Float64,turbineFile[12,2:end])
    data.lambda = parse.(Float64,turbineFile[13,2:end])
    data.Csm = parse.(Float64,turbineFile[14,2:end])


    windspeed = turbineFile[15:end,1]
    if parse.(Float64,windspeed) != data.windspeed
        error("wind speed is inconsistenty")
    end

    powercurve = turbineFile[15:end,2:end]
    data.powercurve = parse.(Float64,powercurve)
    sizes.turbines = length(data.turbinenames)

    nothing
end

function initialize!(options::zefiroOptions,sizes::zefiroSizes,data::zefiroData)

    data.CAPEX = zeros(sizes.winds,sizes.turbines)
    data.CAPEXrate = zeros(sizes.winds,sizes.turbines)
    data.OPEX = zeros(sizes.winds,sizes.turbines)
    data.DECOM = zeros(sizes.winds,sizes.turbines)

    data.IC = data.turbinePR.*data.turbineQuantity
    nothing
end

function CAPEX!(options::zefiroOptions,sizes::zefiroSizes,data::zefiroData)

    data.CAPEX = data.CAPEX./(1 .-data.CAPEXrate )
    nothing
end