include("pMedian.jl")
include("tsp.jl")
include("anneauEtoile.jl")



# Définition de constantes pour le statut de résolution du problème
const OPTIMAL = JuMP.MOI.OPTIMAL
const INFEASIBLE = JuMP.MOI.INFEASIBLE
const UNBOUNDED = JuMP.MOI.DUAL_INFEASIBLE;



function main()
    fichier = choixFichier()
    coords, = initCoordN(fichier)
    nbEtats = length(coords)

    f = open("historique.txt", "w")
    write(f, "historique des tests réalisés : \n\n")
    flush(f)
    run(`xdg-open historique.txt`)

    texte(nbEtats)
    while true
        q = pressEnter()
        if q == "q"
            return
        end

        

        choixMethode = choixPMedian()
        if choixMethode != 6
            choixCycle = choixTsp()
        else
            choixCycle = 0
        end

        p = defNbStations(nbEtats)
        stations, affect, ordreDeVisite, cout, temps = executionProgramme(p, fichier, choixCycle, choixMethode)
        # println(f, "stations : $stations de coord : $([coords[i] for i in stations])")
        # println(f, "ordre de visite : $ordreDeVisite")
        remplirHistorique(f, choixCycle, choixMethode, p, cout, temps)
        interfaceGraphhique_anneauEtoile(coords, stations, affect, ordreDeVisite, cout)
    end
end





################################## Fonctions pour le main ###################################

function texte(nbEtats)
    
    print("\n")
    println("Nous nous intéressons à la résolution du problème de l'anneau étoile avec une instance de $nbEtats Etats des Etats Unis. Nous voulons construire des arrêts de métro/bus dans p Etats de manière à minimiser les distances à parcourir à pieds pour les citoyens puis tracer un cycle reliant toute les stations et de distance minimale. Ce sera à vous de choisir le nombre p de stations à construire sachant qu'il ne peut y avoir qu'un maximum de 1 station par Etat\n")
    println("Nous avons donc implémenté plusieurs manières, plus ou moins bonnes pour résoudre ce problème. Pour ce qui est de la définition des stations, nous avons une méthode Gloutonne, une méthode aléatoire ainsi qu'une résolution avec un programme linéaire donnant nécessairement la meilleure solution. Nous avons également deux méta-heuristiques améliorant les solutions aléatoires et gloutonnes en les répétant un certains nombres de fois et ne gardant que la meilleure solution.")
    println("\nPour ce qui est du tracé du cycle reliant toutes les stations entre elles, nous avons 3 méthodes : \n-La méthode du plus proche voisin, qui part de la première station et construit un cycle de station proche en proche.\n-Une amélioration de ce même algorithme par une méthode itérative, empêchant les croisements d'arrêtes.\n-Une résolution par programme linéaire donnant nécessairement la meilleure solution\n\n")
end

function pressEnter()
    println("(Appuyez sur 'entrée' pour continuer ou 'q' pour quitter...)")
    while ((c=readline()) != "")    # le \n est supprimer par readline, quand on fait entrée, il renvoie une chaîne vide ""
        if c == "q"
            return c
        end
        println("(Appuyez sur 'entrée' ou pour continuer ou 'q' pour quitter...)")
    end
end

function choixFichier()
    print("Entrez le nom exact du fichier sur lequel vous voulez travailler : ")
    entree = readline()
    println()
    return entree
end

function choixTsp()
    println("Choisissez quelle méthode de tracé de cycle vous voulez utiliser, entrez : \n\t1 : Plus proche voisin\n\t2 : Plus proche voisin 2 opt")
    while true
        print("\nVotre saisie : ")
        entree = tryparse(Int, readline())
        println()
        if !isnothing(entree) && (entree == 1 || entree == 2)
            return entree
        else
            println("Mauvaise entrée, réessayez : ")
        end
    end
    
end


function choixPMedian()

    println("\nChoisissez la méthode que vous souhaitez utiliser, entrez : \n
    1 : heuristique gloutonne
    2 : heuristique gloutonne améliorée
    3 : heuristique aléatoire
    4 : heuristique aléatoire amélioréé
    5 : p-médian par programme linéaire
    6 : résolution complète par programme linéaire")

    while true 

        print("\nVotre saisie : ")
        entree = tryparse(Int, readline())
        print("\n")
        

        if !isnothing(entree) && (entree >= 1 && entree <= 6)
            return entree
        else
            println("Mauvaise valeure entrée, réessayez")
        end
    
    end

    
end

function executionProgramme(p, fichier, choixCycle, choixMethode)
    # cas Glouton
    if choixMethode == 1
        stations, affect, ordreDeVisite, cout, temps = choix1(p, fichier, choixCycle)
        return stations, affect, ordreDeVisite, cout, temps

        # Cas glouton amélioré
    elseif choixMethode == 2
        stations, affect, ordreDeVisite, cout, temps = choix2(p, fichier, choixCycle)
        return stations, affect, ordreDeVisite, cout, temps

        # Cas Random
    elseif choixMethode == 3
        stations, affect, ordreDeVisite, cout, temps = choix3(p, fichier, choixCycle)
        return stations, affect, ordreDeVisite, cout, temps
    
        # Cas Random amélioré
    elseif choixMethode == 4
        stations, affect, ordreDeVisite, cout, temps = choix4(p, fichier, choixCycle)
        return stations, affect, ordreDeVisite, cout, temps

        # Cas PLNE Compacte pour p médian
    elseif choixMethode == 5
        stations, affect, ordreDeVisite, cout, temps = choix5(p, fichier, choixCycle)
        return stations, affect, ordreDeVisite, cout, temps

        # Cas Plne pour résolution complète
    elseif choixMethode == 6
        stations, affect, ordreDeVisite, cout, temps = choix6(p, fichier)
    end
end

function choix1(p, fichier, choixCycle)
    
    if choixCycle == 1
        res = @timed ae_ppv_glouton(p, fichier)
    elseif choixCycle == 2
        res = @timed ae_ppv2opt_glouton(p, fichier)
    end
    temps = res.time
    stations, affect, ordreDeVisite, cout = res.value
    return stations, affect, ordreDeVisite, cout, temps
end

function choix2(p, fichier, choixCycle)
    if choixCycle == 1
        res = @timed ae_ppv_metaHeuristiqueGlouton(p, fichier)
    elseif choixCycle == 2
        res = @timed ae_ppv2opt_metaHeuristiqueGlouton(p, fichier)
    end
    temps = res.time
    stations, affect, ordreDeVisite, cout = res.value
    return stations, affect, ordreDeVisite, cout, temps

end

function choix3(p, fichier, choixCycle)
    println("Choisissez le nombres d'essais alétatoires que vous voulez effectuer : ")
    print("\rNb essais aléatoires : ")
    nbEssais = defNbEssais()
    
    if choixCycle == 1
        res = @timed ae_ppv_random(p, fichier)
    elseif choixCycle == 2
        res = @timed ae_ppv2opt_random(p, fichier)
    end
    temps = res.time
    stations, affect, ordreDeVisite, cout = res.value
    return stations, affect, ordreDeVisite, cout, temps

end

function choix4(p, fichier, choixCycle)
    println("Choisissez le nombres d'itérations d'amélioration par descente stochastique sur une heuristique alétatoire que vous voulez effectuer (100 recommandées) : ")
    print("\rNb essais itérations descente stochastique : ")
    nbEssais = defNbEssais()

    if choixCycle == 1
        res = @timed ae_ppv_metaHeuristiqueRandom(p, fichier, nbEssais)
    elseif choixCycle == 2
        res = @timed ae_ppv2opt_metaHeuristiqueRandom(p, fichier, nbEssais)
    end
    temps = res.time
    stations, affect, ordreDeVisite, cout = res.value
    return stations, affect, ordreDeVisite, cout, temps

end

function choix5(p, fichier, choixCycle)
    if choixCycle == 1
        res = @timed ae_ppv_plne(p, fichier)
    elseif choixCycle == 2
        res = @timed ae_ppv2opt_plne(p, fichier)
    end
    temps = res.time
    stations, affect, ordreDeVisite, cout = res.value
    return stations, affect, ordreDeVisite, cout, temps
end

function choix6(p, fichier)
    res = @timed ae_plne(p, fichier)
    temps = res.time
    stations, affect, ordreDeVisite, cout = res.value
    return stations, affect, ordreDeVisite, cout, temps
end



function defNbStations(nbEtats)
    while true
        println("Choisissez le nombres de stations que vous voulez placer parmis les $nbEtats Etats (un entier entre 1 et $nbEtats compris) : ")
        print("Nb stations à placer : ")
        p = tryparse(Int, readline())    # tryparse au lieu de parse permet de renvoyer nothing si p n'est pas un nombre
        if !isnothing(p) && p <= nbEtats && p > 0
            print("\n")
            return p
        else
            println("\nMauvaise valeure entrée, réessayez.")
        end
    end
end

function defNbEssais()
    while true
        print("\nNb Essais : ")
        nbEssais = tryparse(Int, readline())
        if !isnothing(nbEssais) && nbEssais > 0 
            print("\n")
            return nbEssais
        else
            println("\nMauvaise valeure entrée, réessayez.")
        end
    end

end

function remplirHistorique(f, choixCycle, choixMethode, p, cout, temps)
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
        methodePmedian = "PL"

    elseif choixMethode == 6
        methodePmedian = "PL"
        methodeCycle = "PL"
    end

    if choixCycle == 1
        methodeCycle = "plus proche voisin"
    elseif choixCycle == 2
        methodeCycle = "plus proche voisin 2 opt"
    end


    # On remplit le fichier historique.txt et on affiche les résultats sur le terminal
    
    println("Test de solution : ")
    println(f, "Test de solution : ")

    println("Nombre de stations à placer : $p")
    println(f, "Nombre de stations à placer : $p")

    println("Méthode p-Médian choisie : $methodePmedian")
    println(f, "Méthode p-Médian choisie : $methodePmedian")

    println("Méthode TSP choisie : $methodeCycle")
    println(f, "Méthode TSP choisie : $methodeCycle")

    println("Coût de la solution (à minimiser) : $(round(cout, digits=2))")
    println(f, "Coût de la solution : $(round(cout, digits=2))")
    
    println("Temps d'exécution : $temps")
    println(f, "Temps d'exécution : $temps")

    println()
    println(f)
    println("------------------------------------")
    println(f, "------------------------------------")
    println()
    println(f)

    flush(f)
    
end