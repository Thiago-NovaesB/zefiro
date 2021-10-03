#production and acquisition

function ICCost!(options::zefiroOptions,sizes::zefiroSizes,data::zefiroData,output::zefiroOutput)
    key = (options.postprocess ? "postprocessing" : "evaluating")
    println(key*" port cost")
    port!(options,sizes,data,output)
    println(key*" installationOfTheComponents cost")
    installationOfTheComponents!(options,sizes,data,output)
    println(key*" commissioning cost")
    commissioning!(options,sizes,data,output)
    println(key*" insurance cost")
    insurance!(options,sizes,data,output)

    nothing
end

function port!(options::zefiroOptions,sizes::zefiroSizes,data::zefiroData,output::zefiroOutput)

    if options.port == 0 
        if options.postprocess
            nothing
        else
            for i in 1:sizes.winds,j in 1:sizes.turbines
                output.CAPEX[i,j] += data.Cport[i] + data.N1d[j]*data.Lr[i]
                output.port[i,j] += data.Cport[i] + data.N1d[j]*data.Lr[i]
            end
        end
    else
        error("port mode not found.")
    end
    nothing

end

function installationOfTheComponents!(options::zefiroOptions,sizes::zefiroSizes,data::zefiroData,output::zefiroOutput)

    if options.installationOfTheComponents == 0 
        if options.postprocess
            nothing
        else
            output.CAPEX .+= transpose(data.Ccomp)
            output.installationOfTheComponents .+= transpose(data.Ccomp)
        end
    else
        error("installationOfTheComponents mode not found.")
    end
    nothing

end

function commissioning!(options::zefiroOptions,sizes::zefiroSizes,data::zefiroData,output::zefiroOutput)

    if options.commissioning == 0 
        if options.postprocess
            nothing
        else
            output.CAPEX .+= transpose(data.Lcom.*data.Ncom)
            output.commissioning .+= transpose(data.Lcom.*data.Ncom)
        end
    else
        error("commissioning mode not found.")
    end
    nothing

end

function insurance!(options::zefiroOptions,sizes::zefiroSizes,data::zefiroData,output::zefiroOutput)

    if options.insurance == 0 
        if options.postprocess
            nothing
        else
            for i in 1:sizes.winds,j in 1:sizes.turbines
                output.CAPEX[i,j] += data.Cins[i] + data.IC[j]
                output.insurance[i,j] += data.Cins[i] + data.IC[j]
            end
        end
    else
        error("insurance mode not found.")
    end
    nothing

end