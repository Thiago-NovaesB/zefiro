using Base: product
function evaluateEnergy!(options::zefiroOptions,sizes::zefiroSizes,data::zefiroData)
    AEP = zeros(sizes.winds,sizes.turbines)
    CP = zeros(sizes.winds,sizes.turbines)

    for i in 1:sizes.winds,j in 1:sizes.turbines
        AEP[i,j] = sum(data.RFwindspeed[:,i].*data.powercurve[:,j])*8760
        CP[i,j] = AEP[i,j]*100/maximum(data.powercurve[:,j])/8760
    end
    data.AEP = AEP
    data.CP = CP
    nothing
end