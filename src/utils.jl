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

    nothing
end

function output!(options::zefiroOptions,sizes::zefiroSizes,data::zefiroData,output::zefiroOutput)

    file = open(options.PATHCASE*"/output.txt", "w")

    for w in 1:sizes.winds, t in 1:sizes.turbines
        line = "O CAPEX de "*data.windnames[w]*"/"*data.turbinenames[t]*" foi "*string(output.CAPEX[w,t])

        println(line)
        write(file,line*"\n")
    end

    nothing
end

