include("pMedian.jl")
include("tsp.jl")
include("anneauEtoile.jl")

function test_heuristiqueRandom100iter(p, nbTests)

    tabCout = Float32[]
    tabTemps = Float32[]

    for i in 1:nbTests
        res = @timed ae_ppv2opt_random(p, "../tspFile/att48.tsp", 100, 0)
        temps = res.time
        stations, affect, ordreDeVisite, cout = res.value
        push!(tabCout, cout)
        push!(tabTemps, temps)
    end
    coutMoyen = 0.0
    tempsMoyen = 0.0

    for c in tabCout
        coutMoyen += c
    end
    for t in tabTemps
        tempsMoyen += t
    end

    coutMoyen /= nbTests
    tempsMoyen /= nbTests
    
    println("Tous les couts : $tabCout")
    println("Tous les temps : $tabTemps")

    println("Coût moyen : $coutMoyen")
    println("Temps moyen : $tempsMoyen")

end