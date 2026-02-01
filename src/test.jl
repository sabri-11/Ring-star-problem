include("pMedian.jl")
include("tsp.jl")
include("anneauEtoile.jl")

function test_heuristiqueRandom100iter(p, nbTests, alpha)

    coutMoyen = 0.0
    tempsMoyen = 0.0

    for i in 1:nbTests
        res = @timed ae_ppv_random(p, "../tspFile/att48.tsp", 100, alpha)
        temps = res.time
        cout = res.value[4]
        print("(cout$i=$cout, temps$i=$temps)\t")
        coutMoyen += cout
        tempsMoyen += temps
        
    end

    coutMoyen /= nbTests
    tempsMoyen /= nbTests
    
    println()
    println("Coût moyen sur $nbTests tests pour p=$p: $(round(coutMoyen, digits=2))")
    println("Temps moyen sur $nbTests tests pour p=$p : $tempsMoyen")


end


function test_metaHeuristiqueGloutonne(p, nbTests, alpha)

    coutMoyen = 0.0
    tempsMoyen = 0.0

    for i in 1:nbTests
        res = @timed ae_ppv_metaHeuristiqueGlouton(p, "../tspFile/att48.tsp", alpha)
        temps = res.time
        cout = res.value[4]
        print("(cout$i=$cout, temps$i=$temps)\t")
        coutMoyen += cout
        tempsMoyen += temps
        
    end

    coutMoyen /= nbTests
    tempsMoyen /= nbTests
    
    println()
    println("Coût moyen sur $nbTests tests pour p=$p: $(round(coutMoyen, digits=2))")
    println("Temps moyen sur $nbTests tests pour p=$p : $tempsMoyen")


end


function test_metaHeuristiqueRandom100iter(p, nbTests, alpha)

    coutMoyen = 0.0
    tempsMoyen = 0.0

    for i in 1:nbTests
        res = @timed ae_ppv_metaHeuristiqueRandom(p, "../tspFile/att48.tsp", 100, alpha)
        temps = res.time
        cout = res.value[4]
        print("(cout$i=$cout, temps$i=$temps)\t")
        coutMoyen += cout
        tempsMoyen += temps
        
    end

    coutMoyen /= nbTests
    tempsMoyen /= nbTests
    
    println()
    println("Coût moyen sur $nbTests tests pour p=$p: $(round(coutMoyen, digits=2))")
    println("Temps moyen sur $nbTests tests pour p=$p : $tempsMoyen")


end

