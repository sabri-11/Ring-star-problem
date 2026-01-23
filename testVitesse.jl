########################### Fonctions tests de vitesse de résolution ############################

function testVitesse(choixCycle, choixMethode, nbEtats)
    
    # Cas glouton
    if choixMethode == "1"
        p = defNbStations(nbEtats)
        if choixCycle == 1
            t = @elapsed testVitesse_ppv_Glouton(p)
        elseif choixCycle == 2
            t = @elapsed testVitesse_ae_ppv2opt_glouton(p)
        elseif choixCycle == 3
            t = @elapsed testVitesse_ae_plne_glouton(p)
        end
        return t

        # Cas glouton amélioré
    elseif choixMethode == "2"
        p = defNbStations(nbEtats)
        if choixCycle == 1
            t = @elapsed testVitesse_ae_ppv_metaHeuristiqueGlouton(p)
        elseif choixCycle == 2
            t = @elapsed testVitesse_ae_ppv2opt_metaHeuristiqueGlouton(p)
        elseif choixCycle == 3
            t = @elapsed testVitesse_ae_plne_metaHeuristiqueGlouton(p)
        end
        return t

        # Cas Random
    elseif choixMethode == "3"
        p = defNbStations(nbEtats)
        print("Choisissez le nombres d'essais alétatoires que vous voulez effectuer : ")
        nbEssais = defNbEssais()
        if nbEssais == "q"
            return
        else
            if choixCycle == 1
                t = @elapsed testVitesse_ae_ppv_random(p, nbEssais)
            elseif choixCycle == 2
                t = @elapsed testVitesse_ae_ppv2opt_random(p, nbEssais)
            elseif choixCycle == 3
                t = @elapsed testVitesse_ae_plne_random(p, nbEssais)
            end
            return t
                
        end
    
        # Cas Random amélioré
    elseif choixMethode == "4"
        p = defNbStations(nbEtats)
        print("Choisissez le nombres d'itérations d'amélioration par descente stochastique sur une heuristique alétatoire que vous voulez effectuer (100 recommandées) : ")
        nbEssais = defNbEssais()
        if nbEssais == "q"
            return
        else
            if choixCycle == 1
                t = @elapsed testVitesse_ae_ppv_metaHeuristiqueRandom(p, nbEssais)
            elseif choixCycle == 2
                t = @elapsed testVitesse_ae_ppv2opt_metaHeuristiqueRandom(p, nbEssais)
            elseif choixCycle == 3
                t = @elapsed testVitesse_ae_plne_metaHeuristiqueRandom(p, nbEssais)
            end
            return t
                
        end
        # Cas PLNE Compacte
    elseif choixMethode == "5"
        p = defNbStations(nbEtats)
        if choixCycle == 1
            t = @elapsed testVitesse_ae_ppv_plne(p)
        elseif choixCycle == 2
            t = @elapsed testVitesse_ae_ppv2opt_plne(p)
        elseif choixCycle == 3
            t = @elapsed testVitesse_ae_plne_plne(p)
        end
        return t

    else
        print("Mauvaise valeure entrée, réessayez.")
        return -1
    end

end

function testVitesse_ppv_Glouton(p) # On affiche pas les resultats avec interfaceGraphhiqueTsp
    coords, minX, maxX, minY, maxY = initCoordN()

    stations = defStationsGlouton(p, coords, minX, maxX, minY, maxY)

    affect = affecterMedians(coords, stations)
    ordreDeVisite = plusProcheVoisin(coords, stations)
    cout = coutPmedian(coords, stations) + coutTsp(coords, ordreDeVisite)
end


function testVitesse_ae_ppv_random(p, nbEssais=1)
    coords, = initCoordN()

    stations = meilleureSolution(p, coords, nbEssais)

    affect = affecterMedians(coords, stations)
    ordreDeVisite = plusProcheVoisin(coords, stations)
    cout = coutPmedian(coords, stations) + coutTsp(coords, ordreDeVisite)

end

function testVitesse_ae_ppv_metaHeuristiqueGlouton(p)
    coords, minX, maxX, minY, maxY = initCoordN()

    stations = defStationsGlouton(p, coords, minX, maxX, minY, maxY)
    stations, cout_pMedian = applicationStochastique(p, coords, stations)

    affect = affecterMedians(coords, stations)
    ordreDeVisite = plusProcheVoisin(coords, stations)
    cout = cout_pMedian + coutTsp(coords, ordreDeVisite)

end

function testVitesse_ae_ppv_metaHeuristiqueRandom(p, nbEssais=50)
    coords, = initCoordN()

    stations, cout_pMedian = iterationsStochastiqueRandom(p, coords, nbEssais)

    affect = affecterMedians(coords, stations)
    ordreDeVisite = plusProcheVoisin(coords, stations)
    cout = cout_pMedian + coutTsp(coords, ordreDeVisite)

end

function testVitesse_ae_ppv_plne(p)

    coords, = initCoordN()
    nbEtats = length(coords)
    d = initMatriceDistance(coords, nbEtats)
    
    m = Model(GLPK.Optimizer)
    @variable(m, y[1:nbEtats, 1:nbEtats], Bin)

    @objective(m, Min, sum(d[i, j]*y[i, j] for i in 1:nbEtats,j in 1:nbEtats))

    @constraint(m, sum(y[i, i] for i in 1:nbEtats) == p)
    @constraint(m, [i=1:nbEtats] ,sum(y[i, j] for j in 1:nbEtats) == 1)
    @constraint(m, [i=1:nbEtats, j=1:nbEtats] , y[i, j] <= y[j, j])
    @constraint(m, y[1, 1] == 1)    # On force le point 1 à être une station

    optimize!(m)

    status = termination_status(m)

    if status == INFEASIBLE
        # println("Le problème n'est pas réalisable")       # println ralentit la fonction 
    elseif status == UNBOUNDED
        # println("Le problème est non borné")
    elseif status == OPTIMAL
        stations = Int[]
        affect = Vector{Int}(undef, nbEtats)

        for i in 1:nbEtats
            if value(y[i, i]) > 0.9
                push!(stations, i)
            end
        end
        for i in 1:nbEtats
            for j in 1:nbEtats
                if value(y[i, j]) > 0.9
                    affect[i] = j
                end
            end
        end

        # println("Liste des ièmes Etats choisis pour avoir une station de metro/bus via résolution d'un PLNE compacte : \n$stations\n")
        

        # println("Affectation des autres Etats à la station la plus proche. Affect[i] = j signifie que l'Etat i est affecté à la station de l'Etat j : \n$affect\n")
        ordreDeVisite = plusProcheVoisin(coords, stations)
        cout = objective_value(m) + coutTsp(coords, ordreDeVisite)
    end
end

#### plus proche voisin amélioré
function testVitesse_ae_ppv2opt_glouton(p)

    coords, minX, maxX, minY, maxY = initCoordN()

    stations = defStationsGlouton(p, coords, minX, maxX, minY, maxY)

    affect = affecterMedians(coords, stations)
    # ordreDeVisite = plusProcheVoisin_2opt(coords, stations)
    cout = coutPmedian(coords, stations) + coutTsp(coords, ordreDeVisite)

end

function testVitesse_ae_ppv2opt_random(p, nbEssais=1)

end

function testVitesse_ae_ppv2opt_metaHeuristiqueGlouton(p)

end

function testVitesse_ae_ppv2opt_metaHeuristiqueRandom(p, nbEssais=50)

end

function testVitesse_ae_ppv2opt_plne(p)

end

#### plne compacte
function testVitesse_ae_plne_glouton(p)

    coords, minX, maxX, minY, maxY = initCoordN()

    stations = defStationsGlouton(p, coords, minX, maxX, minY, maxY)

    affect = affecterMedians(coords, stations)
    # ordreDeVisite = plusProcheVoisin_2opt(coords, stations)
    cout = coutPmedian(coords, stations) + coutTsp(coords, ordreDeVisite)
    interfaceGraphhiqueTsp(coords, stations, affect, ordreDeVisite)

end

function testVitesse_ae_plne_random(p, nbEssais=1)

end

function testVitesse_ae_plne_metaHeuristiqueGlouton(p)

end

function testVitesse_ae_plne_metaHeuristiqueRandom(p, nbEssais=50)

end

function testVitesse_ae_plne_plne(p)

end