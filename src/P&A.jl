#production and acquisition

function PACost!(options::zefiroOptions,sizes::zefiroSizes,data::zefiroData,output::zefiroOutput)
    key = (options.postprocess ? "postprocessing" : "evaluating")
    println(key*" windTurbine cost")
    windTurbine!(options,sizes,data,output)
    println(key*" supportStructures cost")
    supportStructures!(options,sizes,data,output)
    println(key*" powerTransmissionSystem cost")
    powerTransmissionSystem!(options,sizes,data,output)
    println(key*" monitoringSystem cost")
    monitoringSystem!(options,sizes,data,output)

    nothing
end

function windTurbine!(options::zefiroOptions,sizes::zefiroSizes,data::zefiroData,output::zefiroOutput)

    if options.projectManagement == 0 
        if options.postprocess
            nothing
        else
            Cwtmat = 3e6*log.(data.turbinePR).-662400
            Cwttrans = data.vesselCost.*data.vesselTimeWT
            for i in 1:sizes.winds,j in 1:sizes.turbines
                output.CAPEX[i,j] += (Cwttrans[i]+Cwtmat[j])*data.turbineQuantity[j]
                output.windTurbine[i,j] += (Cwttrans[i]+Cwtmat[j])*data.turbineQuantity[j]
            end
        end
    else
        error("windTurbine mode not found.")
    end

    nothing

end

function supportStructures!(options::zefiroOptions,sizes::zefiroSizes,data::zefiroData,output::zefiroOutput)

    if options.supportStructures == 0 
        if options.postprocess
            nothing
        else
            Cssmat = zeros(sizes.winds,sizes.turbines)
            Csstrans = data.vesselCost.*data.vesselTimeSS

            for i in 1:sizes.winds,j in 1:sizes.turbines
                Cssmat[i,j] = 339200*data.turbinePR[j]*(1+0.02*(data.WD[i]-8))*(1+8e-7*(data.height[j]*data.diameter[j]*data.diameter[j]/2-1e5))
                output.CAPEX[i,j] += (Csstrans[i]+Cssmat[i,j])*data.turbineQuantity[j]
                output.supportStructures[i,j] += (Csstrans[i]+Cssmat[i,j])*data.turbineQuantity[j]
            end
        end
    else
        error("supportStructures mode not found.")
    end

    nothing

end

function powerTransmissionSystem!(options::zefiroOptions,sizes::zefiroSizes,data::zefiroData,output::zefiroOutput)

    if options.powerTransmissionSystem == 0 
        if options.postprocess
            nothing
        else
            Cofsubs = 583300 .+ 107900*data.IC
            Consubs = Cofsubs/2
            Ccable = data.Ntln.*data.Ctln.*data.onshoreDistance + data.Ntlf.*data.Ctlf.*data.offshoreDistance + data.Cprot
                
            output.CAPEX .+= transpose(Cofsubs + Consubs)
            output.CAPEX .+= Ccable
            output.powerTransmissionSystem .+= transpose(Cofsubs + Consubs)
            output.powerTransmissionSystem .+= Ccable
        end
    else
        error("powerTransmissionSystem mode not found.")
    end
    nothing

end

function monitoringSystem!(options::zefiroOptions,sizes::zefiroSizes,data::zefiroData,output::zefiroOutput)

    if options.monitoringSystem == 0 
        if options.postprocess
            nothing
        else
            output.CAPEX .+= transpose((data.cmsCost+data.scadaCost).*data.turbineQuantity)
            output.monitoringSystem .+= transpose((data.cmsCost+data.scadaCost).*data.turbineQuantity)
        end
    else
        error("monitoringSystem mode not found.")
    end
    nothing

end