#predevelopment and consenting

function OMCost!(options::zefiroOptions,sizes::zefiroSizes,data::zefiroData,output::zefiroOutput)
    key = (options.postprocess ? "postprocessing" : "evaluating")
    println(key*" operation cost")
    operation!(options,sizes,data,output)
    println(key*" maintenance cost")
    maintenance!(options,sizes,data,output)
    nothing

end

function operation!(options::zefiroOptions,sizes::zefiroSizes,data::zefiroData,output::zefiroOutput)

    if options.operation == 0 
        if options.postprocess
            nothing
        else
            Crent = (data.l .* data.Pe) .* output.AEP * data.duration .* transpose(data.turbineQuantity)
            CinsO = zeros(sizes.winds,sizes.turbines)
            CtransO = zeros(sizes.winds,sizes.turbines)
            for i in 1:sizes.winds,j in 1:sizes.turbines
                CinsO[i,j] += data.ComIns[i] * data.IC[j]
                CtransO[i,j] += data.Ctransunit[i] * data.IC[j]
            end
            output.OPEX += Crent + CinsO + CtransO
            output.operation += Crent + CinsO + CtransO
        end
    else
        error("operation mode not found.")
    end
    nothing

end

function maintenance!(options::zefiroOptions,sizes::zefiroSizes,data::zefiroData,output::zefiroOutput)

    if options.maintenance == 0 
        if options.postprocess
            nothing
        else
            Ccm = zeros(sizes.winds,sizes.turbines)
            Cmdir = zeros(sizes.winds,sizes.turbines)
            Cmind = zeros(sizes.winds,sizes.turbines)

            Ctrans = 2*(data.d .* data.tc) 
            Clab = data.N1dOM .* data.LrOM 
            Ccm .+= Ctrans .+ transpose(Clab) .+ data.consumCost

            for i in 1:sizes.winds,j in 1:sizes.turbines
                Cmdir[i,j] = (1-data.Pd[j])*data.lambda[j]*Ccm[i,j] + data.Pd[j]*data.Csm[j]
            end

            Cmind .+= (data.Cindport + data.Cindves + data.Cindlab).*transpose(data.turbineQuantity)

            output.OPEX += Cmdir + Cmind
            output.maintenance += Cmdir + Cmind
        end
    else
        error("maintenance mode not found.")
    end
    nothing

end