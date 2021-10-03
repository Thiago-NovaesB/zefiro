#production and acquisition

function DDCost!(options::zefiroOptions,sizes::zefiroSizes,data::zefiroData,output::zefiroOutput)
    key = (options.postprocess ? "postprocessing" : "evaluating")
    println(key*" decommissioning cost")
    decommissioning!(options,sizes,data,output)
    println(key*" wasteManagement cost")
    wasteManagement!(options,sizes,data,output)
    println(key*" siteClearance cost")
    siteClearance!(options,sizes,data,output)
    println(key*" postMonitoring cost")
    postMonitoring!(options,sizes,data,output)

    nothing
end

function decommissioning!(options::zefiroOptions,sizes::zefiroSizes,data::zefiroData,output::zefiroOutput)

    if options.decommissioning == 0 
        if options.postprocess
            nothing
        else
            CDDport = data.Cddport + data.Nddport .* data.Lddport
            Cremov = data.Nremove .* data.Vremove
            output.DECOM .+= CDDport + Cremov
            output.decommissioning .+= CDDport + Cremov
        end
    else
        error("decommissioning mode not found.")
    end
    nothing

end

function wasteManagement!(options::zefiroOptions,sizes::zefiroSizes,data::zefiroData,output::zefiroOutput)

    if options.wasteManagement == 0 
        if options.postprocess
            nothing
        else
            Cwproc = data.Wjproc .* data.Cjproc 
            Cwtrans = data.Wjtrans .* data.Cjproc ./ data.Wttrans 
            Cland = data.Wnr .* data.Cnr 
            Csv = data.Wr .* data.SV 
            output.DECOM .+= transpose(Cwproc + Cwtrans + Cland - Csv)
            output.wasteManagement .+= transpose(Cwproc + Cwtrans + Cland - Csv)
        end
    else
        error("wasteManagement mode not found.")
    end
    nothing

end

function siteClearance!(options::zefiroOptions,sizes::zefiroSizes,data::zefiroData,output::zefiroOutput)

    if options.siteClearance == 0 
        if options.postprocess
            nothing
        else
            output.DECOM .+= data.Asc.*data.Cscunit
            output.siteClearance .+= data.Asc.*data.Cscunit
        end
    else
        error("siteClearance mode not found.")
    end
    nothing

end

function postMonitoring!(options::zefiroOptions,sizes::zefiroSizes,data::zefiroData,output::zefiroOutput)

    if options.postMonitoring == 0 
        if options.postprocess
            nothing
        else
            output.DECOM .+= data.postCost
            output.postMonitoring .+= data.postCost
        end
    else
        error("postMonitoring mode not found.")
    end
    nothing

end