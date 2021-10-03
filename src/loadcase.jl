function load!(options::zefiroOptions,sizes::zefiroSizes,data::zefiroData,output::zefiroOutput)
    println("loading wind data")
    loadwind!(options,sizes,data,output)
    println("wind data loaded")

    println("loading turbine data")
    loadturbine!(options,sizes,data,output)
    println("turbine data loaded")

    println("initialize! data")
    initialize!(options,sizes,data,output)
    println("initialize! loaded")

    nothing
end


function loadwind!(options::zefiroOptions,sizes::zefiroSizes,data::zefiroData,output::zefiroOutput)
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

    data.Cddport = parse.(Float64,windFile[25,2:end])
    data.Nddport = parse.(Float64,windFile[26,2:end])
    data.Lddport = parse.(Float64,windFile[27,2:end])
    data.Nremove = parse.(Float64,windFile[28,2:end])
    data.Vremove = parse.(Float64,windFile[29,2:end])
    data.Asc = parse.(Float64,windFile[30,2:end])
    data.Cscunit = parse.(Float64,windFile[31,2:end])


    data.windspeed = parse.(Float64,windFile[32:end,1])
    data.RFwindspeed = parse.(Float64,windFile[32:end,2:end])
    sizes.winds = length(data.windnames)


    nothing
end

function loadturbine!(options::zefiroOptions,sizes::zefiroSizes,data::zefiroData,output::zefiroOutput)
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

    data.Wjproc = parse.(Float64,turbineFile[15,2:end])
    data.Cjproc = parse.(Float64,turbineFile[16,2:end])
    data.Wjtrans = parse.(Float64,turbineFile[17,2:end])
    data.Wttrans = parse.(Float64,turbineFile[18,2:end])
    data.Cjtrnas = parse.(Float64,turbineFile[19,2:end])
    data.Wnr = parse.(Float64,turbineFile[20,2:end])
    data.Cnr = parse.(Float64,turbineFile[21,2:end])
    data.Wr = parse.(Float64,turbineFile[22,2:end])
    data.SV = parse.(Float64,turbineFile[23,2:end])

    windspeed = turbineFile[24:end,1]
    if parse.(Float64,windspeed) != data.windspeed
        error("wind speed is inconsistenty")
    end

    powercurve = turbineFile[24:end,2:end]
    data.powercurve = parse.(Float64,powercurve)
    sizes.turbines = length(data.turbinenames)

    nothing
end

