#predevelopment and consenting

function PCCost!(options::zefiroOptions,sizes::zefiroSizes,data::zefiroData,output::zefiroOutput)
    key = (options.postprocess ? "postprocessing" : "evaluating")
    println(key*" projectManagement cost")
    projectManagement!(options,sizes,data,output)
    println(key*" legalAuthorization cost")
    legalAuthorization!(options,sizes,data,output)
    println(key*" surveys cost")
    surveys!(options,sizes,data,output)
    println(key*" engineering cost")
    engineering!(options,sizes,data,output)
    println(key*" contingencies cost")
    contingencies!(options,sizes,data,output)
    nothing

end

function projectManagement!(options::zefiroOptions,sizes::zefiroSizes,data::zefiroData,output::zefiroOutput)

    if options.projectManagement == 0 
        if options.postprocess
            output.projectManagement = 0.03*output.CAPEX
        else
            output.CAPEXrate .+= 0.03
        end
    else
        error("projectManagement mode not found.")
    end
    nothing

end

function legalAuthorization!(options::zefiroOptions,sizes::zefiroSizes,data::zefiroData,output::zefiroOutput)

    if options.legalAuthorization == 0 
        if options.postprocess
            output.legalAuthorization = 0.0013*output.CAPEX
        else
            output.CAPEXrate .+= 0.0013
        end
    else
        error("legalAuthorization mode not found.")
    end
    nothing

end

function surveys!(options::zefiroOptions,sizes::zefiroSizes,data::zefiroData,output::zefiroOutput)
    if options.surveys == 0 
        if options.postprocess
            nothing
        else
            output.CAPEX .+= data.surveysCost
            output.surveys .+= data.surveysCost
        end
    else
        error("surveys mode not found.")
    end
    nothing

end

function engineering!(options::zefiroOptions,sizes::zefiroSizes,data::zefiroData,output::zefiroOutput)
    if options.engineering == 0 
        if options.postprocess
            nothing
        else
            output.CAPEX .+= transpose(data.engVerifCost .+ data.baseCost .+ data.engUnitCost .* data.IC)
            output.engineering .+= transpose(data.engVerifCost .+ data.baseCost .+ data.engUnitCost .* data.IC)
        end
    else
        error("engineering mode not found.")
    end
    nothing

end

function contingencies!(options::zefiroOptions,sizes::zefiroSizes,data::zefiroData,output::zefiroOutput)

    if options.contingencies == 0 
        if options.postprocess
            output.contingencies = 0.1*output.CAPEX
        else
            output.CAPEXrate .+= 0.1
        end
    else
        error("contingencies mode not found.")
    end
    nothing

end