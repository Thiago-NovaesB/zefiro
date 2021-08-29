#production and acquisition

function ICCost!(options::zefiroOptions,sizes::zefiroSizes,data::zefiroData)
    println("evaluating port cost")
    port!(options,sizes,data)
    println("evaluating installationOfTheComponents cost")
    installationOfTheComponents!(options,sizes,data)
    println("evaluating commissioning cost")
    commissioning!(options,sizes,data)
    println("evaluating insurance cost")
    insurance!(options,sizes,data)

    nothing
end

function port!(options::zefiroOptions,sizes::zefiroSizes,data::zefiroData)

    if options.port == 0 
        for i in 1:sizes.winds,j in 1:sizes.turbines
            data.CAPEX[i,j] += data.Cport[i] + data.N1d[j]*data.Lr[i]
        end
    else
        error("port mode not found.")
    end
    nothing

end

function installationOfTheComponents!(options::zefiroOptions,sizes::zefiroSizes,data::zefiroData)

    if options.installationOfTheComponents == 0 
        data.CAPEX .+= transpose(data.Ccomp)
    else
        error("installationOfTheComponents mode not found.")
    end
    nothing

end

function commissioning!(options::zefiroOptions,sizes::zefiroSizes,data::zefiroData)

    if options.commissioning == 0 
        data.CAPEX .+= transpose(data.Lcom.*data.Ncom)
    else
        error("commissioning mode not found.")
    end
    nothing

end

function insurance!(options::zefiroOptions,sizes::zefiroSizes,data::zefiroData)

    if options.insurance == 0 
        for i in 1:sizes.winds,j in 1:sizes.turbines
            data.CAPEX[i,j] += data.Cins[i] + data.IC[j]
        end
    else
        error("insurance mode not found.")
    end
    nothing

end