using Base: product
function evaluateEnergy!(options::zefiroOptions,sizes::zefiroSizes,data::zefiroData,output::zefiroOutput)
    AEP = zeros(sizes.winds,sizes.turbines)
    CP = zeros(sizes.winds,sizes.turbines)

    for i in 1:sizes.winds,j in 1:sizes.turbines
        AEP[i,j] = sum(data.RFwindspeed[:,i].*data.powercurve[:,j])*year2hour
        CP[i,j] = AEP[i,j]*percent/data.turbinePR[j]/year2hour
    end
    output.AEP = AEP
    output.CP = CP
    nothing
end