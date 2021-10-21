function initialize!(options::zefiroOptions,sizes::zefiroSizes,data::zefiroData,output::zefiroOutput)

    output.CAPEX = zeros(sizes.winds,sizes.turbines)
    output.CAPEXrate = zeros(sizes.winds,sizes.turbines)
    output.OPEX = zeros(sizes.winds,sizes.turbines)
    output.DECOM = zeros(sizes.winds,sizes.turbines)

    data.IC = data.turbinePR.*data.turbineQuantity


    output.projectManagement = zeros(sizes.winds,sizes.turbines)
    output.legalAuthorization = zeros(sizes.winds,sizes.turbines)
    output.surveys = zeros(sizes.winds,sizes.turbines)
    output.engineering = zeros(sizes.winds,sizes.turbines)
    output.contingencies = zeros(sizes.winds,sizes.turbines)
    output.windTurbine = zeros(sizes.winds,sizes.turbines)
    output.supportStructures = zeros(sizes.winds,sizes.turbines)
    output.powerTransmissionSystem = zeros(sizes.winds,sizes.turbines)
    output.monitoringSystem = zeros(sizes.winds,sizes.turbines)
    output.port = zeros(sizes.winds,sizes.turbines)
    output.installationOfTheComponents = zeros(sizes.winds,sizes.turbines)
    output.commissioning = zeros(sizes.winds,sizes.turbines)
    output.insurance = zeros(sizes.winds,sizes.turbines)
    output.operation = zeros(sizes.winds,sizes.turbines)
    output.maintenance = zeros(sizes.winds,sizes.turbines)
    output.decommissioning = zeros(sizes.winds,sizes.turbines)
    output.wasteManagement = zeros(sizes.winds,sizes.turbines)
    output.siteClearance = zeros(sizes.winds,sizes.turbines)
    output.postMonitoring = zeros(sizes.winds,sizes.turbines)

    output.P_C = zeros(sizes.winds,sizes.turbines)
    output.P_A = zeros(sizes.winds,sizes.turbines)
    output.O_M = zeros(sizes.winds,sizes.turbines)
    output.I_C = zeros(sizes.winds,sizes.turbines)
    output.D_D = zeros(sizes.winds,sizes.turbines)
    nothing
end

function CAPEX!(options::zefiroOptions,sizes::zefiroSizes,data::zefiroData,output::zefiroOutput)

    output.CAPEX = output.CAPEX./(1 .-output.CAPEXrate )
    nothing
end

function postprocess!(options::zefiroOptions,sizes::zefiroSizes,data::zefiroData,output::zefiroOutput)

    options.postprocess = true

    PCCost!(options,sizes,data,output)
    PACost!(options,sizes,data,output)
    ICCost!(options,sizes,data,output)
    OMCost!(options,sizes,data,output)
    DDCost!(options,sizes,data,output)

    LCOE!(options,sizes,data,output)

    nothing
end

function LCOE!(options::zefiroOptions,sizes::zefiroSizes,data::zefiroData,output::zefiroOutput)

    output.P_C = output.projectManagement + output.legalAuthorization + output.surveys + output.engineering + output.contingencies
    output.P_A = output.windTurbine + output.supportStructures + output.powerTransmissionSystem + output.monitoringSystem
    output.I_C = output.port + output.installationOfTheComponents + output.commissioning + output.insurance
    output.O_M = output.operation + output.maintenance
    output.D_D = output.decommissioning + output.wasteManagement + output.siteClearance + output.postMonitoring

    numerador = 0.34*output.P_C +
                (0.02*output.P_C + 0.001*output.P_A+ 0.0165*output.I_C)./(1+data.r) + 
                (0.02*output.P_C + 0.163*output.P_A+ 0.0165*output.I_C)./(1+data.r)^2 + 
                (0.215*output.P_C + 0.373*output.P_A+ 0.325*output.I_C)./(1+data.r)^3 + 
                (0.40*output.P_C + 0.434*output.P_A+ 0.614*output.I_C)./(1+data.r)^4 + 
                (0.005*output.P_C + 0.029*output.P_A+ 0.028*output.I_C)./(1+data.r)^5 +
                sum(output.O_M./(1+data.r)^i for i in 12:25) +
                output.D_D./(1+data.r)^26
    denominator = sum(output.AEP./(1+data.r)^i for i in 6:25)

    output.LCOE = numerador./ denominator
    nothing
end

function output!(options::zefiroOptions,sizes::zefiroSizes,data::zefiroData,output::zefiroOutput)

    file = open(options.PATHCASE*"/output.txt", "w")

    for w in 1:sizes.winds, t in 1:sizes.turbines
        line = "O LCOE de "*data.windnames[w]*"/"*data.turbinenames[t]*" foi "*string(output.LCOE[w,t])

        println(line)
        write(file,line*"\n")
    end

    nothing
end

