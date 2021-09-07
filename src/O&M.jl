#predevelopment and consenting

function OMCost!(options::zefiroOptions,sizes::zefiroSizes,data::zefiroData)
    println("evaluating operation cost")
    operation!(options,sizes,data)
    println("evaluating maintenance cost")
    maintenance!(options,sizes,data)
    nothing

end

function operation!(options::zefiroOptions,sizes::zefiroSizes,data::zefiroData)

    if options.operation == 0 
        Crent = (data.l .* data.Pe) .* data.AEP * data.duration
        CinsO = zeros(sizes.winds,sizes.turbines)
        CtransO = zeros(sizes.winds,sizes.turbines)
        for i in 1:sizes.winds,j in 1:sizes.turbines
            CinsO[i,j] += data.ComIns[i] + data.IC[j]
            CtransO[i,j] += data.Ctransunit[i] + data.IC[j]
        end
        data.OPEX += Crent + CinsO + CtransO
    else
        error("operation mode not found.")
    end
    nothing

end

function maintenance!(options::zefiroOptions,sizes::zefiroSizes,data::zefiroData)

    if options.maintenance == 0 
        Ccm = zeros(sizes.winds,sizes.turbines)
        Cmdir = zeros(sizes.winds,sizes.turbines)
        Cmind = zeros(sizes.winds,sizes.turbines)

        Ctrans = 2*(data.d .* data.tc) 
        Clab = data.N1dOM .* data.LrOM 
        Ccm .+= Ctrans .+ transpose(Clab) .+ data.consumCost

        for i in 1:sizes.winds,j in 1:sizes.turbines
            Cmdir[i,j] = (1-data.Pd[j])*data.lambda[j]*Ccm[i,j] + data.Pd[j]*data.Csm[j]
        end

        Cmind .+= data.Cindport + data.Cindves + data.Cindlab

        data.OPEX += Cmdir + Cmind

    else
        error("maintenance mode not found.")
    end
    nothing

end