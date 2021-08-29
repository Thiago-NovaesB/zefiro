#production and acquisition

function PACost!(options::zefiroOptions,sizes::zefiroSizes,data::zefiroData)
    println("evaluating windTurbine cost")
    windTurbine!(options,sizes,data)
    println("evaluating supportStructures cost")
    supportStructures!(options,sizes,data)
    println("evaluating powerTransmissionSystem cost")
    powerTransmissionSystem!(options,sizes,data)
    println("evaluating monitoringSystem cost")
    monitoringSystem!(options,sizes,data)

    nothing
end

function windTurbine!(options::zefiroOptions,sizes::zefiroSizes,data::zefiroData)

    if options.projectManagement == 0 
        Cwtmat = 3e6*log.(data.turbinePR).-662400
        Cwttrans = data.vesselCost.*data.vesselTimeWT
        for i in 1:sizes.winds,j in 1:sizes.turbines
            data.CAPEX[i,j] += (Cwttrans[i]+Cwtmat[j])*data.turbineQuantity[j]
        end
    else
        error("windTurbine mode not found.")
    end

    nothing

end

function supportStructures!(options::zefiroOptions,sizes::zefiroSizes,data::zefiroData)

    if options.supportStructures == 0 
        Cssmat = zeros(sizes.winds,sizes.turbines)
        Csstrans = data.vesselCost.*data.vesselTimeSS

        for i in 1:sizes.winds,j in 1:sizes.turbines
            Cssmat[i,j] = 339200*data.turbinePR[j]*(1+0.02*(data.WD[i]-8))*(1+8e-7*(data.height[j]*data.diameter[j]*data.diameter[j]/2-1e5))
            data.CAPEX[i,j] += (Csstrans[i]+Cssmat[i,j])*data.turbineQuantity[j]
        end
    else
        error("supportStructures mode not found.")
    end

    nothing

end

function powerTransmissionSystem!(options::zefiroOptions,sizes::zefiroSizes,data::zefiroData)

    if options.powerTransmissionSystem == 0 
        Cofsubs = 583300 .+ 107900*data.IC
        Consubs = Cofsubs/2
        Ccable = data.Ntln.*data.Ctln.*data.onshoreDistance + data.Ntlf.*data.Ctlf.*data.offshoreDistance + data.Cprot
            
        data.CAPEX .+= transpose(Cofsubs + Consubs)
        data.CAPEX .+= Ccable
    else
        error("powerTransmissionSystem mode not found.")
    end
    nothing

end

function monitoringSystem!(options::zefiroOptions,sizes::zefiroSizes,data::zefiroData)

    if options.monitoringSystem == 0 
        data.CAPEX .+= transpose((data.cmsCost+data.scadaCost).*data.turbineQuantity)
    else
        error("monitoringSystem mode not found.")
    end
    nothing

end