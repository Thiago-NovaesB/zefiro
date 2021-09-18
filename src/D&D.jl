#production and acquisition

function DDCost!(options::zefiroOptions,sizes::zefiroSizes,data::zefiroData)
    println("evaluating decommissioning cost")
    decommissioning!(options,sizes,data)
    println("evaluating wasteManagement cost")
    wasteManagement!(options,sizes,data)
    println("evaluating siteClearance cost")
    siteClearance!(options,sizes,data)
    println("evaluating postMonitoring cost")
    postMonitoring!(options,sizes,data)

    nothing
end

function decommissioning!(options::zefiroOptions,sizes::zefiroSizes,data::zefiroData)

    if options.decommissioning == 0 
        CDDport = data.Cddport + data.Nddport .* data.Lddport
        Cremov = data.Nremove .* data.Vremove
        data.DECOM .+= CDDport + Cremov
    else
        error("decommissioning mode not found.")
    end
    nothing

end

function wasteManagement!(options::zefiroOptions,sizes::zefiroSizes,data::zefiroData)

    if options.wasteManagement == 0 
        Cwproc = data.Wjproc .* data.Cjproc 
        Cwtrans = data.Wjtrans .* data.Cjproc ./ data.Wttrans 
        Cland = data.Wnr .* data.Cnr 
        Csv = data.Wr .* data.SV 
        data.DECOM .+= transpose(Cwproc + Cwtrans + Cland - Csv)
    else
        error("wasteManagement mode not found.")
    end
    nothing

end

function siteClearance!(options::zefiroOptions,sizes::zefiroSizes,data::zefiroData)

    if options.siteClearance == 0 
        data.DECOM .+= data.Asc.*data.Cscunit
    else
        error("siteClearance mode not found.")
    end
    nothing

end

function postMonitoring!(options::zefiroOptions,sizes::zefiroSizes,data::zefiroData)

    if options.postMonitoring == 0 
        data.DECOM .+= data.postCost
    else
        error("postMonitoring mode not found.")
    end
    nothing

end