include("pMedian.jl")
include("tsp.jl")

function main()
    coords, = initCoordN()
    nbEtats = length(coords)
    temps = -1
    open("historique.txt", "w") do f
        write(f, "historique des tests réalisés : \n\n")
    end

    texte(nbEtats)
    while true
        choixExec = choixVitesse()
        choixCycle = choixTsp()
        choixMethode = choixPMedian()
        p = defNbStations(nbEtats)
        if choixExec == 1
            cout = executionProgramme(p, choixCycle, choixMethode)
        elseif choixExec == 2
            while temps < 0
                temps = testVitesse(choixCycle, choixMethode)
            end
        end
        remplirHistorique(choixExec, choixCycle, choixMethode, p, cout, temps)
    end
end



######################################## Fonctions principales de résolutions ##############################

# Anneau etoile plus proche voisin glouton
function ae_ppv_glouton(p)

    coords, minX, maxX, minY, maxY = initCoordN()

    stations = defStationsGlouton(p, coords, minX, maxX, minY, maxY)

    affect = affecterMedians(coords, stations)
    ordreDeVisite = plusProcheVoisin(coords, stations)
    cout = coutPmedian(coords, stations) + coutTsp(coords, ordreDeVisite)
    interfaceGraphhiqueTsp(coords, stations, affect, ordreDeVisite, cout)
    return cout
end

function ae_ppv_random(p, nbEssais=1)
    coords, = initCoordN()

    stations = meilleureSolution(p, coords, nbEssais)

    affect = affecterMedians(coords, stations)
    ordreDeVisite = plusProcheVoisin(coords, stations)
    cout = coutPmedian(coords, stations) + coutTsp(coords, ordreDeVisite)
    interfaceGraphhiqueTsp(coords, stations, affect, ordreDeVisite, cout)
    return cout
end

function ae_ppv_metaHeuristiqueGlouton(p)
    coords, minX, maxX, minY, maxY = initCoordN()

    stations = defStationsGlouton(p, coords, minX, maxX, minY, maxY)
    stations, cout_pMedian = applicationStochastique(p, coords, stations)

    affect = affecterMedians(coords, stations)
    ordreDeVisite = plusProcheVoisin(coords, stations)
    cout = cout_pMedian + coutTsp(coords, ordreDeVisite)
    interfaceGraphhiqueTsp(coords, stations, affect, ordreDeVisite, cout)
    return cout
end

function ae_ppv_metaHeuristiqueRandom(p, nbEssais=50)
    coords, = initCoordN()

    stations, cout_pMedian = iterationsStochastiqueRandom(p, coords, nbEssais)

    affect = affecterMedians(coords, stations)
    ordreDeVisite = plusProcheVoisin(coords, stations)
    cout = cout_pMedian + coutTsp(coords, ordreDeVisite)
    interfaceGraphhiqueTsp(coords, stations, affect, ordreDeVisite, cout)
    return cout
end

function ae_ppv_plne(p)
    cout = tspSurPlne(p)
    return cout
end

#### plus proche voisin amélioré
function ae_2opt_glouton(p)

    coords, minX, maxX, minY, maxY = initCoordN()

    stations = defStationsGlouton(p, coords, minX, maxX, minY, maxY)

    affect = affecterMedians(coords, stations)
    # ordreDeVisite = plusProcheVoisin_2opt(coords, stations)
    cout = coutPmedian(coords, stations) + coutTsp(coords, ordreDeVisite)
    interfaceGraphhiqueTsp(coords, stations, affect, ordreDeVisite)
    return cout

end

function ae_2opt_random(p, nbEssais=1)

end

function ae_2opt_metaHeuristiqueGlouton(p)

end

function ae_2opt_metaHeuristiqueRandom(p, nbEssais=50)

end

function ae_2opt_plne(p)

end

#### plne compacte
function ae_plne_glouton(p)

    coords, minX, maxX, minY, maxY = initCoordN()

    stations = defStationsGlouton(p, coords, minX, maxX, minY, maxY)

    affect = affecterMedians(coords, stations)
    # ordreDeVisite = plusProcheVoisin_2opt(coords, stations)
    cout = coutPmedian(coords, stations) + coutTsp(coords, ordreDeVisite)
    interfaceGraphhiqueTsp(coords, stations, affect, ordreDeVisite)

end

function ae_plne_random(p, nbEssais=1)

end

function ae_plne_metaHeuristiqueGlouton(p)

end

function ae_plne_metaHeuristiqueRandom(p, nbEssais=50)

end

function ae_plne_plne(p)

end
##############################################

################################## Fonctions pour le main ###################################

function texte(nbEtats)
    
    print("\n")
    println("Nous nous intéressons à la résolution du problème de l'anneau étoile avec une instance de $nbEtats Etats des Etats Unis. Nous voulons construire des arrêts de métro/bus dans p Etats de manière à minimiser les distances à parcourir à pieds pour les citoyens puis tracer un cycle reliant toute les stations et de distance minimale. Ce sera à vous de choisir le nombre p de stations à construire sachant qu'il ne peut y avoir qu'un maximum de 1 station par Etat\n")
    println("Nous avons donc implémenté plusieurs manières, plus ou moins bonnes pour résoudre ce problème. Pour ce qui est de la définition des stations, nous avons une méthode Gloutonne, une méthode aléatoire ainsi qu'une résolution avec un programme linéaire donnant nécessairement la meilleure solution. Nous avons également deux méta-heuristiques améliorant les solutions aléatoires et gloutonnes en les répétant un certains nombres de fois et ne gardant que la meilleure solution.")
    println("\nPour ce qui est du tracé du cycle reliant toutes les stations entre elles, nous avons 2 méthodes : \n-La méthode du plus proche voisin, qui part de la première station et construit un cycle de station proche en proche.\n-Une amélioration de ce même algorithme par une méthode itérative, empêchant les croisements d'arrêtes.\n\n")
end

function choixTsp()
    print("Choisissez quelle méthode de tracé de cycle vous voulez utiliser.\nEntrez 1 pour la méthode du plus proche voisin et 2 pour celle améliorée : ")
    entree = parse(Int, readline())
    print("\n")
    while entree != 1 && entree != 2
        print("Mauvaise entrée. Entrez 1 pour la méthode du plus proche voisin et 2 pour celle améliorée : ")
        entree = parse(Int, readline())
        print("\n")
    end
    return entree
end

function choixVitesse()
    print("Voulez vous tester les vitesses d'exécution des différentes méthodes ou résoudre le problème ?\nEntrez 1 pour faire la résolution et 2 pour tester les vitesses : ")
    entree = parse(Int, readline())
    print("\n")
    while entree != 1 && entree != 2
        
        print("Mauvaise entrée. Entrez 1 pour faire la résolution et 2 pour tester les vitesses : ")
        entree = parse(Int, readline())
        print("\n")
    end
    return entree
end

function choixPMedian()

    println("\nChoisissez la méthode que vous souhaitez utiliser, entrez : \n
    1 pour utiliser l'heuristique gloutonne
    2 pour utiliser l'heuristique gloutonne améliorée
    3 pour utiliser l'heuristique aléatoire
    4 pour utiliser l'heuristique aléatoire amélioréé
    5 pour utiliser la résolution par programme linéaire.")
    print("\nVotre saisie : ")
    entree = readline()
    print("\n")
    entree = tryparse(Int, entree)

    while !isnothing(entree) && entree != 1 && entree != 2 && entree != 3 && entree != 4 && entree != 5
        println("Mauvaise valeure entrée, réessayez.")
        print("\nVotre saisie : ")
        entree = readline()
        print("\n")
        tryparse(Int, entree)
    end

    return entree
    
end

function executionProgramme(p, choixCycle, choixMethode)
    if choixMethode == 1
        cout = choix1(p, choixCycle)
        return cout

        # Cas glouton amélioré
    elseif choixMethode == 2
        cout = choix2(p, choixCycle)
        return cout

        # Cas Random
    elseif choixMethode == 3
        cout = choix3(p, choixCycle)
        return cout
    
        # Cas Random amélioré
    elseif choixMethode == 4
        cout = choix4(p, choixCycle)
        return cout

        # Cas PLNE Compacte
    elseif choixMethode == 5
        cout = choix5(p, choixCycle)
        return cout
    end
end

function choix1(p, choixCycle)
    
    if p == "q"
        return
    else
        if choixCycle == 1
            cout = ae_ppv_glouton(p)
        elseif choixCycle == 2
            cout = ae_2opt_glouton(p)
        elseif choixCycle == 3
            cout = ae_plne_glouton(p)
        end
        return cout
    end

end

function choix2(p, choixCycle)
    if p == "q"
        return
    else
        if choixCycle == 1
            cout = ae_ppv_metaHeuristiqueGlouton(p)
        elseif choixCycle == 2
            cout = ae_2opt_metaHeuristiqueGlouton(p)
        elseif choixCycle == 3
            cout = ae_plne_metaHeuristiqueGlouton(p)
        end

        return cout
    end

end

function choix3(p, choixCycle)
    print("Choisissez le nombres d'essais alétatoires que vous voulez effectuer : ")
    nbEssais = defNbEssaisMain()
    if nbEssais == "q"
        return
    else
        if choixCycle == 1
            cout = ae_ppv_random(p)
        elseif choixCycle == 2
            cout = ae_2opt_random(p)
        elseif choixCycle == 3
            cout = ae_plne_random(p)
        end
        return cout
    end
end

function choix4(p, choixCycle)
    print("Choisissez le nombres d'itérations d'amélioration par descente stochastique sur une heuristique alétatoire que vous voulez effectuer (100 recommandées) : ")
    nbEssais = defNbEssaisMain()
    if nbEssais == "q"
        return
    else
        if choixCycle == 1
            cout = ae_ppv_metaHeuristiqueRandom(p, nbEssais)
        elseif choixCycle == 2
            cout = ae_2opt_metaHeuristiqueRandom(p, nbEssais)
        elseif choixCycle == 3
            cout = ae_plne_metaHeuristiqueRandom(p, nbEssais)
        end   
        return cout
    end

end

function choix5(p, choixCycle)
    if choixCycle == 1
        cout = ae_ppv_plne(p)
    elseif choixCycle == 2
        cout = ae_2opt_plne(p)
    elseif choixCycle == 3
        cout = ae_plne_plne(p)
    end
    return cout
end



function defNbStations(nbEtats)
    while true
        println("Choisissez le nombres de stations que vous voulez placer parmis les $nbEtats Etats (un entier entre 1 et $nbEtats compris) : ")
        print("Nb stations à placer : ")
        p = readline()
        if p == "q"
            print("\n")
            return "q"
        end
        p = tryparse(Int, p)    # tryparse au lieu de parse permet de renvoyer nothing si p n'est pas un nombre
        if !isnothing(p) && p <= nbEtats && p > 0
            print("\n")
            return p
        else
            println("\nMauvaise valeure entrée, réessayez ou entrez q pour quitter.")
        end
    end
end

function defNbEssaisMain()
    while true
        print("\nNb Essais : ")
        nbEssais = readline()
        if nbEssais == "q"
            print("\n")
            return "q"
        end
        nbEssais = tryparse(Int, nbEssais)
        if !isnothing(nbEssais) && nbEssais > 0 
            print("\n")
            return nbEssais
        else
            println("\nMauvaise valeure entrée, réessayez ou entrez q pour quitter.")
        end
    end

end

function remplirHistorique(choixExec, choixCycle, choixMethode, p, cout, temps)
    if choixMethode == 1
        methodePmedian = "heuristique gloutonne"

        # Cas glouton amélioré
    elseif choixMethode == 2
        methodePmedian = "méta heuristique gloutonne"

        # Cas Random
    elseif choixMethode == 3
        methodePmedian = "heuristique random répétée un certain nombre de fois"
    
        # Cas Random amélioré
    elseif choixMethode == 4
        methodePmedian = "méta heuristique random améliorée par descente stochastique"
                
        # Cas PLNE Compacte
    elseif choixMethode == 5
        methodePmedian = "programme linéaire"
    end

    if choixCycle == 1
        methodeCycle = "plus proche voisin"
    elseif choixCycle == 2
        methodeCycle = "plus proche voisin améliorée"
    elseif choixCycle == 3
        methodeCycle = "programme linéaire"
    end

    if choixExec == 1
        temps = -1
        intro = "Test de solution : "
    elseif choixExec == 2
        intro = "Test de vitesse d'exécution : "
    end


    open("historique.txt", "a") do f
        println(intro)
        println(f, intro)

        println("Nombre de stations à placer : $p")
        println(f, "Nombre de stations à placer : $p")

        println("Méthode p-Médian choisie : $methodePmedian")
        println(f, "Méthode p-Médian choisie : $methodePmedian")

        println("Méthode TSP choisie : $methodeCycle")
        println(f, "Méthode TSP choisie : $methodeCycle")

        if temps > 0
            println("Temps d'exécution : $temps")
            println(f, "Temps d'exécution : $temps")
        else
            println("Coût de la solution : $(round(cout, digits=2))")
            println(f, "Coût de la solution : $(round(cout, digits=2))")
        end

        println()
        println(f)
    end
end
###########################################################


########################### Fonctions tests de vitesse de résolution ############################

function testVitesse(choixCycle, choixMethode, nbEtats)
    
    # Cas glouton
    if choixMethode == "1"
        p = defNbStations(nbEtats)
        if choixCycle == 1
            t = @elapsed testVitesse_ppv_Glouton(p)
        elseif choixCycle == 2
            t = @elapsed testVitesse_ae_2opt_glouton(p)
        elseif choixCycle == 3
            t = @elapsed testVitesse_ae_plne_glouton(p)
        end
        println("L'exécution a pris $t secondes\n") 
        return t

        # Cas glouton amélioré
    elseif choixMethode == "2"
        p = defNbStations(nbEtats)
        if choixCycle == 1
            t = @elapsed testVitesse_ae_ppv_metaHeuristiqueGlouton(p)
        elseif choixCycle == 2
            t = @elapsed testVitesse_ae_2opt_metaHeuristiqueGlouton(p)
        elseif choixCycle == 3
            t = @elapsed testVitesse_ae_plne_metaHeuristiqueGlouton(p)
        end
        println("L'exécution a pris $t secondes\n") 
        return t

        # Cas Random
    elseif choixMethode == "3"
        p = defNbStations(nbEtats)
        print("Choisissez le nombres d'essais alétatoires que vous voulez effectuer : ")
        nbEssais = defNbEssaisMain()
        if nbEssais == "q"
            return
        else
            if choixCycle == 1
                t = @elapsed testVitesse_ae_ppv_random(p, nbEssais)
            elseif choixCycle == 2
                t = @elapsed testVitesse_ae_2opt_random(p, nbEssais)
            elseif choixCycle == 3
                t = @elapsed testVitesse_ae_plne_random(p, nbEssais)
            end
            println("L'exécution a pris $t secondes\n")
            return t
                
        end
    
        # Cas Random amélioré
    elseif choixMethode == "4"
        p = defNbStations(nbEtats)
        print("Choisissez le nombres d'itérations d'amélioration par descente stochastique sur une heuristique alétatoire que vous voulez effectuer (100 recommandées) : ")
        nbEssais = defNbEssaisMain()
        if nbEssais == "q"
            return
        else
            if choixCycle == 1
                t = @elapsed testVitesse_ae_ppv_metaHeuristiqueRandom(p, nbEssais)
            elseif choixCycle == 2
                t = @elapsed testVitesse_ae_2opt_metaHeuristiqueRandom(p, nbEssais)
            elseif choixCycle == 3
                t = @elapsed testVitesse_ae_plne_metaHeuristiqueRandom(p, nbEssais)
            end
            println("L'exécution a pris $t secondes\n")
            return t
                
        end
        # Cas PLNE Compacte
    elseif choixMethode == "5"
        p = defNbStations(nbEtats)
        if choixCycle == 1
            t = @elapsed testVitesse_ae_ppv_plne(p)
        elseif choixCycle == 2
            t = @elapsed testVitesse_ae_2opt_plne(p)
        elseif choixCycle == 3
            t = @elapsed testVitesse_ae_plne_plne(p)
        end
        println("L'exécution a pris $t secondes\n")
        return t

    else
        print("Mauvaise valeure entrée, réessayez.")
        return -1
    end

end

function testVitesse_ppv_Glouton(p)
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
        println("Le problème n'est pas réalisable")
    elseif status == UNBOUNDED
        println("Le problème est non borné")
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
function testVitesse_ae_2opt_glouton(p)

    coords, minX, maxX, minY, maxY = initCoordN()

    stations = defStationsGlouton(p, coords, minX, maxX, minY, maxY)

    affect = affecterMedians(coords, stations)
    # ordreDeVisite = plusProcheVoisin_2opt(coords, stations)
    cout = coutPmedian(coords, stations) + coutTsp(coords, ordreDeVisite)

end

function testVitesse_ae_2opt_random(p, nbEssais=1)

end

function testVitesse_ae_2opt_metaHeuristiqueGlouton(p)

end

function testVitesse_ae_2opt_metaHeuristiqueRandom(p, nbEssais=50)

end

function testVitesse_ae_2opt_plne(p)

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