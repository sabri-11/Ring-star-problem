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



function test_coutTsp_mhRandom(p)
    coords, minX, maxX, minY, maxY = initCoordN("../tspFile/att48.tsp")

    stations = defStationsGlouton(p, coords, minX, maxX, minY, maxY)
    stations, cout_pMedian = applicationStochastique(p, coords, stations)

    affect = affecterMedians(coords, stations)
    ordreDeVisite = plusProcheVoisin_2opt(coords, stations)
    coutTspCalc = coutTsp(coords, ordreDeVisite, 1)
    cout = cout_pMedian + coutTspCalc

    println("cout tsp calculé par heuristique = $coutTspCalc")
    d = initMatriceDistance(coords, length(coords))

    if p == 3
        vraiCOutTsp =  d[ordreDeVisite[1], ordreDeVisite[2]] + d[ordreDeVisite[2],  ordreDeVisite[3]] + d[ordreDeVisite[3], ordreDeVisite[1]]
    elseif p ==2
        vraiCOutTsp =  d[ordreDeVisite[1], ordreDeVisite[2]]
    else
        println("\nErreur ! Vous pouvez tester que pour p=2 ou p=3")
        return
    end
    println("distance total du cycle calculé manuellement : $vraiCOutTsp")
    println()
    if coutTspCalc - vraiCOutTsp == 0
        println("Tout est bon !")
    else
        println("problème dans le coût du tsp, vous avez coutTsp = $coutTspCalc, alors qu'il devrait être égal à $vraiCOutTsp")
    end
end