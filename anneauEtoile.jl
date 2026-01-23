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
        choixCycle = choixTsp()
        choixMethode = choixPMedian()
        p = defNbStations(nbEtats)
        
        stations, affect, ordreDeVisite, cout, temps = executionProgramme(p, choixCycle, choixMethode)
        temps = round(temps, digits="3")
        remplirHistorique(choixCycle, choixMethode, p, cout, temps)
        interfaceGraphhiqueTsp(coords, stations, affect, ordreDeVisite, cout)
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
    
    return stations, affect, ordreDeVisite, cout
end

function ae_ppv_random(p, nbEssais=1)
    coords, = initCoordN()

    stations = meilleureSolution(p, coords, nbEssais)

    affect = affecterMedians(coords, stations)
    ordreDeVisite = plusProcheVoisin(coords, stations)
    cout = coutPmedian(coords, stations) + coutTsp(coords, ordreDeVisite)

    return stations, affect, ordreDeVisite, cout
end

function ae_ppv_metaHeuristiqueGlouton(p)
    coords, minX, maxX, minY, maxY = initCoordN()

    stations = defStationsGlouton(p, coords, minX, maxX, minY, maxY)
    stations, cout_pMedian = applicationStochastique(p, coords, stations)

    affect = affecterMedians(coords, stations)
    ordreDeVisite = plusProcheVoisin(coords, stations)
    cout = cout_pMedian + coutTsp(coords, ordreDeVisite)

    return stations, affect, ordreDeVisite, cout
end

function ae_ppv_metaHeuristiqueRandom(p, nbEssais=50)
    coords, = initCoordN()

    stations, cout_pMedian = iterationsStochastiqueRandom(p, coords, nbEssais)

    affect = affecterMedians(coords, stations)
    ordreDeVisite = plusProcheVoisin(coords, stations)
    cout = cout_pMedian + coutTsp(coords, ordreDeVisite)

    return stations, affect, ordreDeVisite, cout
end

function ae_ppv_plne(p)
    coords, stations, affect, cout_pMedian = pMedian_plneCompacte(p)
    ordreDeVisite = plusProcheVoisin(coords, stations)
    cout = cout_pMedian + coutTsp(coords, ordreDeVisite)

    return stations, affect, ordreDeVisite, cout
end

#### plus proche voisin amélioré
function ae_ppv2opt_glouton(p)
    coords, minX, maxX, minY, maxY = initCoordN()

    stations = defStationsGlouton(p, coords, minX, maxX, minY, maxY)

    affect = affecterMedians(coords, stations)
    ordreDeVisite = plusProcheVoisin_2opt(coords, stations)
    cout = coutPmedian(coords, stations) + coutTsp(coords, ordreDeVisite)

    return stations, affect, ordreDeVisite, cout
end

function ae_ppv2opt_random(p, nbEssais=1)
    coords, = initCoordN()

    stations = meilleureSolution(p, coords, nbEssais)

    affect = affecterMedians(coords, stations)
    ordreDeVisite = plusProcheVoisin_2opt(coords, stations)
    cout = coutPmedian(coords, stations) + coutTsp(coords, ordreDeVisite)
    return stations, affect, ordreDeVisite, cout
end

function ae_ppv2opt_metaHeuristiqueGlouton(p)
    coords, minX, maxX, minY, maxY = initCoordN()

    stations = defStationsGlouton(p, coords, minX, maxX, minY, maxY)
    stations, cout_pMedian = applicationStochastique(p, coords, stations)

    affect = affecterMedians(coords, stations)
    ordreDeVisite = plusProcheVoisin_2opt(coords, stations)
    cout = cout_pMedian + coutTsp(coords, ordreDeVisite)
    return stations, affect, ordreDeVisite, cout
end

function ae_ppv2opt_metaHeuristiqueRandom(p, nbEssais=50)
    coords, = initCoordN()

    stations, cout_pMedian = iterationsStochastiqueRandom(p, coords, nbEssais)

    affect = affecterMedians(coords, stations)
    ordreDeVisite = plusProcheVoisin_2opt(coords, stations)
    cout = cout_pMedian + coutTsp(coords, ordreDeVisite)
    return stations, affect, ordreDeVisite, cout
end

function ae_ppv2opt_plne(p)
    coords, stations, affect, cout_pMedian = pMedian_plneCompacte(p)
    ordreDeVisite = plusProcheVoisin_2opt(coords, stations)
    cout = cout_pMedian + coutTsp(coords, ordreDeVisite)
    return stations, affect, ordreDeVisite, cout
end

#### plne compacte
function ae_plne_glouton(p)

    coords, minX, maxX, minY, maxY = initCoordN()

    stations = defStationsGlouton(p, coords, minX, maxX, minY, maxY)

    affect = affecterMedians(coords, stations)
    # ordreDeVisite = plusProcheVoisin_2opt(coords, stations)
    cout = coutPmedian(coords, stations) + coutTsp(coords, ordreDeVisite)
    return stations, affect, ordreDeVisite, cout

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
    println("\nPour ce qui est du tracé du cycle reliant toutes les stations entre elles, nous avons 3 méthodes : \n-La méthode du plus proche voisin, qui part de la première station et construit un cycle de station proche en proche.\n-Une amélioration de ce même algorithme par une méthode itérative, empêchant les croisements d'arrêtes.\n-Une résolution par programme linéaire donnant nécessairement la meilleure solution\n\n")
end

function choixTsp()
    println("Choisissez quelle méthode de tracé de cycle vous voulez utiliser, entrez : \n\t1 : Plus proche voisin\n\t2 : Plus proche voisin 2 opt\n\t3 : Programme linéaire")
    print("\nVotre saisie : ")
    entree = parse(Int, readline())
    println()
    while entree != 1 && entree != 2
        print("Mauvaise entrée, réessayez : ")
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
    # cas Glouton
    if choixMethode == 1
        stations, affect, ordreDeVisite, cout, temps = choix1(p, choixCycle)
        return stations, affect, ordreDeVisite, cout, temps

        # Cas glouton amélioré
    elseif choixMethode == 2
        stations, affect, ordreDeVisite, cout, temps = choix2(p, choixCycle)
        return stations, affect, ordreDeVisite, cout, temps

        # Cas Random
    elseif choixMethode == 3
        stations, affect, ordreDeVisite, cout, temps = choix3(p, choixCycle)
        return stations, affect, ordreDeVisite, cout, temps
    
        # Cas Random amélioré
    elseif choixMethode == 4
        stations, affect, ordreDeVisite, cout, temps = choix4(p, choixCycle)
        return stations, affect, ordreDeVisite, cout, temps

        # Cas PLNE Compacte
    elseif choixMethode == 5
        stations, affect, ordreDeVisite, cout, temps = choix5(p, choixCycle)
        return stations, affect, ordreDeVisite, cout, temps
    end
end

function choix1(p, choixCycle)
    
    if p == "q"
        return
    else
        if choixCycle == 1
            res = @timed ae_ppv_glouton(p)
            temps = res.time
            stations, affect, ordreDeVisite, cout = res.value
        elseif choixCycle == 2
            res = @timed ae_ppv2opt_glouton(p)
            temps = res.time
            stations, affect, ordreDeVisite, cout = res.value
        elseif choixCycle == 3
            res = ae_plne_glouton(p)
            temps = res.time
            stations, affect, ordreDeVisite, cout = res.value
        end
        return stations, affect, ordreDeVisite, cout, temps
    end

end

function choix2(p, choixCycle)
    if p == "q"
        return
    else
        if choixCycle == 1
            res = @timed ae_ppv_metaHeuristiqueGlouton(p)
            temps = res.time
            stations, affect, ordreDeVisite, cout = res.value
        elseif choixCycle == 2
            res = @timed ae_ppv2opt_metaHeuristiqueGlouton(p)
            temps = res.time
            stations, affect, ordreDeVisite, cout = res.value
        elseif choixCycle == 3
            res = @timed ae_plne_metaHeuristiqueGlouton(p)
            temps = res.time
            stations, affect, ordreDeVisite, cout = res.value
        end

        return stations, affect, ordreDeVisite, cout, temps
    end

end

function choix3(p, choixCycle)
    print("Choisissez le nombres d'essais alétatoires que vous voulez effectuer : ")
    nbEssais = defNbEssais()
    if nbEssais == "q"
        return
    else
        if choixCycle == 1
            res = @timed ae_ppv_random(p)
            temps = res.time
            stations, affect, ordreDeVisite, cout = res.value
        elseif choixCycle == 2
            res = @timed ae_ppv2opt_random(p)
            temps = res.time
            stations, affect, ordreDeVisite, cout = res.value
        elseif choixCycle == 3
            res = @timed ae_plne_random(p)
            temps = res.time
            stations, affect, ordreDeVisite, cout = res.value
        end
        return stations, affect, ordreDeVisite, cout, temps
    end
end

function choix4(p, choixCycle)
    print("Choisissez le nombres d'itérations d'amélioration par descente stochastique sur une heuristique alétatoire que vous voulez effectuer (100 recommandées) : ")
    nbEssais = defNbEssais()
    if nbEssais == "q"
        return
    else
        if choixCycle == 1
            stations, affect, ordreDeVisite, cout, temps = @timed ae_ppv_metaHeuristiqueRandom(p, nbEssais)
            temps = res.time
            stations, affect, ordreDeVisite, cout = res.value
        elseif choixCycle == 2
            stations, affect, ordreDeVisite, cout, temps = @timed ae_ppv2opt_metaHeuristiqueRandom(p, nbEssais)
            temps = res.time
            stations, affect, ordreDeVisite, cout = res.value
        elseif choixCycle == 3
            stations, affect, ordreDeVisite, cout, temps = @timed ae_plne_metaHeuristiqueRandom(p, nbEssais)
            temps = res.time
            stations, affect, ordreDeVisite, cout = res.value
        end   
        return stations, affect, ordreDeVisite, cout, temps
    end

end

function choix5(p, choixCycle)
    if choixCycle == 1
        stations, affect, ordreDeVisite, cout, temps = @timed ae_ppv_plne(p)
        temps = res.time
        stations, affect, ordreDeVisite, cout = res.value
    elseif choixCycle == 2
        stations, affect, ordreDeVisite, cout, temps = @timed ae_ppv2opt_plne(p)
        temps = res.time
        stations, affect, ordreDeVisite, cout = res.value
    elseif choixCycle == 3
        stations, affect, ordreDeVisite, cout, temps = @timed ae_plne_plne(p)
        temps = res.time
        stations, affect, ordreDeVisite, cout = res.value
    end
    return stations, affect, ordreDeVisite, cout, temps
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

function defNbEssais()
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

function remplirHistorique(choixCycle, choixMethode, p, cout, temps)
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


    # On remplit le fichier historique.txt et on affiche les résultats sur le terminal
    open("historique.txt", "a") do f
        println("Test de solution : ")
        println(f, "Test de solution : ")

        println("Nombre de stations à placer : $p")
        println(f, "Nombre de stations à placer : $p")

        println("Méthode p-Médian choisie : $methodePmedian")
        println(f, "Méthode p-Médian choisie : $methodePmedian")

        println("Méthode TSP choisie : $methodeCycle")
        println(f, "Méthode TSP choisie : $methodeCycle")
    
        println("Coût de la solution : $(round(cout, digits=2))")
        println(f, "Coût de la solution : $(round(cout, digits=2))")
        
        println("Temps d'exécution : $temps")
        println(f, "Temps d'exécution : $temps")

        println()
        println("------------------------------------")
        println()
        println(f)
    end
end
###########################################################


