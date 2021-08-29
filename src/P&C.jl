#predevelopment and consenting

function PCCost!(options::zefiroOptions,sizes::zefiroSizes,data::zefiroData)
    println("evaluating projectManagement cost")
    projectManagement!(options,sizes,data)
    println("evaluating legalAuthorization cost")
    legalAuthorization!(options,sizes,data)
    println("evaluating surveys cost")
    surveys!(options,sizes,data)
    println("evaluating engineering cost")
    engineering!(options,sizes,data)
    println("evaluating contingencies cost")
    contingencies!(options,sizes,data)
    nothing

end

function projectManagement!(options::zefiroOptions,sizes::zefiroSizes,data::zefiroData)

    if options.projectManagement == 0 
        data.CAPEXrate .+= 0.03
    else
        error("projectManagement mode not found.")
    end
    nothing

end

function legalAuthorization!(options::zefiroOptions,sizes::zefiroSizes,data::zefiroData)

    if options.legalAuthorization == 0 
        data.CAPEXrate .+= 0.0013
    else
        error("legalAuthorization mode not found.")
    end
    nothing

end

function surveys!(options::zefiroOptions,sizes::zefiroSizes,data::zefiroData)
    #TODO adicionar leitura do surveyCost
    if options.surveys == 0 
        data.CAPEX .+= data.surveysCost
    else
        error("surveys mode not found.")
    end
    nothing

end

function engineering!(options::zefiroOptions,sizes::zefiroSizes,data::zefiroData)
    #TODO adicionar leitura do surveyCost
    if options.engineering == 0 
        data.CAPEX .+= transpose(data.engVerifCost .+ data.baseCost .+ data.engUnitCost .* data.IC)
    else
        error("engineering mode not found.")
    end
    nothing

end

function contingencies!(options::zefiroOptions,sizes::zefiroSizes,data::zefiroData)

    if options.contingencies == 0 
        data.CAPEXrate .+= 0.1
    else
        error("contingencies mode not found.")
    end
    nothing

end