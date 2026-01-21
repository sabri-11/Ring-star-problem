using JuMP
using GLPK
using Random
using BenchmarkTools
using Plots

# Définition de constantes pour le statut de résolution du problème
const OPTIMAL = JuMP.MOI.OPTIMAL
const INFEASIBLE = JuMP.MOI.INFEASIBLE
const UNBOUNDED = JuMP.MOI.DUAL_INFEASIBLE;

##################################################   Main   #########################################################

function main()
    coords, = initCoordN()
    nbEtats = length(coords)

    print("\n")
    println("Nous nous intéressons à la résolution du problème de l'anneau étoile avec une instance de $nbEtats Etats des Etats Unis. Nous voulons construire des arrêts de métro/bus dans p Etats de manière 
à minimiser les distances à parcourir à pieds pour les citoyens puis tracer un cycle reliant toute les stations et de distance minimale. Ce sera à vous de choisir le nombre p de stations à construire sachant qu'il ne peut y avoir qu'un maximum de 1 station par Etat\n")
    println("Nous avons donc implémenté plusieurs manières, plus ou moins bonnes pour résoudre ce problème. Pour ce qui est de la définition des stations, nous avons une méthode Gloutonne, une méthode aléatoire ainsi
qu'une résolution avec un programme linéaire donnant nécessairement la meilleure solution. Nous avons également deux méta-heuristiques améliorant les solutions aléatoires et
gloutonnes en les répétant un certains nombres de fois et ne gardant que la meilleure solution.")
    println("Pour ce qui est du tracé du cycle reliant toutes les stations entre elles, nous avons 2 méthodes : \n-La méthode du plus proche voisin, qui part de la première station et construit un cycle de 
station proche en proche.\n-Une amélioration de ce même algorithme par une méthode itérative, empêchant les croisements d'arrêtes.")

    while true
        println("\nChoisissez la méthode que vous souhaitez utiliser, entrez : \n
        1 pour utiliser l'heuristique gloutonne
        2 pour utiliser l'heuristique gloutonne améliorée
        3 pour utiliser l'heuristique aléatoire
        4 pour utiliser l'heuristique aléatoire amélioréé
        5 pour utiliser la résolution par programme linéaire.
        6 pour tester les temps d'exécution pures et sans affichage des différentes méthodes
        q pour quitter")
        print("\nVotre saisie : ")
        entree = readline()
        print("\n")

         # Cas glouton
        if entree == "1"
            choix1(nbEtats)
            break

         # Cas glouton amélioré
        elseif entree == "2"
            choix2(nbEtats)
            break

         # Cas Random
        elseif entree == "3"
            choix3(nbEtats)
            break
        
         # Cas Random amélioré
        elseif entree == "4"
            choix4(nbEtats)
            break

         # Cas PLNE Compacte
        elseif entree == "5"
            choix5(nbEtats)
            break
        
         # Test des vitesses d'exécution 
        elseif entree == "6"
            choix6(nbEtats)
            break

         # Cas d'arrêt
        elseif entree == "q"
            break
        else
            println("Mauvaise valeure entrée, réessayez ou entrez q pour quitter.")
            continue
        end
    end

end

######################################## Fonctions pour le main ################################################
function choix1(nbEtats)
    p = defPMain(nbEtats)
    if p == "q"
        return
    else
        pMedian_heuristiqueGloutonne(p)
        return
    end

end

function choix2(nbEtats)
    p = defPMain(nbEtats)
    if p == "q"
        return
    else
        pMedian_metaHeuristiqueGlouton(p)
        return
    end

end

function choix3(nbEtats)
    p = defPMain(nbEtats)
    print("Choisissez le nombres d'essais alétatoires que vous voulez effectuer : ")
    nbEssais = defNbEssaisMain()
    if nbEssais == "q"
        return
    else
        pMedian_heuristiqueRandomisee(p, nbEssais)
        return
    end
end

function choix4(nbEtats)

    p = defPMain(nbEtats)
    print("Choisissez le nombres d'itérations d'amélioration par descente stochastique sur une heuristique alétatoire que vous voulez effectuer (100 recommandées) : ")
    nbEssais = defNbEssaisMain()
    if nbEssais == "q"
        return
    else
        pMedian_metaHeuristiqueRandom(p ,nbEssais)     
        return           
    end

end

function choix5(nbEtats)
    p = defPMain(nbEtats)
    pMedian_plneCompacte(p)
    return
end

function choix6(nbEtats)
    
    while true
        println("\nChoisissez la méthode dont vous voulez tester la vitesse d'exécution, entrez : \n
        1 pour utiliser l'heuristique gloutonne
        2 pour utiliser l'heuristique gloutonne améliorée
        3 pour utiliser l'heuristique aléatoire
        4 pour utiliser l'heuristique aléatoire amélioréé
        5 pour utiliser la résolution par programme linéaire.
        r pour revenir au menu précédent
        q pour quitter")
        print("\nVotre saisie : ")
        entree = readline()
        print("\n")

        # Cas glouton
        if entree == "1"
            p = defPMain(nbEtats)
            t = @elapsed testVitesse_glouton(p)
            println("L'exécution a pris $t secondes") 
            

         # Cas glouton amélioré
        elseif entree == "2"
            p = defPMain(nbEtats)
            t = @elapsed testVitesse_metaHeuristiqueGlouton(p)
            println("L'exécution a pris $t secondes") 
            

         # Cas Random
        elseif entree == "3"
            p = defPMain(nbEtats)
            print("Choisissez le nombres d'essais alétatoires que vous voulez effectuer : ")
            nbEssais = defNbEssaisMain()
            if nbEssais == "q"
                return
            else
                t = @elapsed testVitesse_random(p, nbEssais)
                println("L'exécution a pris $t secondes")
                  
            end
        
         # Cas Random amélioré
        elseif entree == "4"
            p = defPMain(nbEtats)
            print("Choisissez le nombres d'itérations d'amélioration par descente stochastique sur une heuristique alétatoire que vous voulez effectuer (100 recommandées) : ")
            nbEssais = defNbEssaisMain()
            if nbEssais == "q"
                return
            else
                t = @elapsed testVitesse_metaHeuristiqueRandom(p, nbEssais)
                println("L'exécution a pris $t secondes")
                  
            end
         # Cas PLNE Compacte
        elseif entree == "5"
            p = defPMain(nbEtats)
            t = @elapsed testVitesse_plneCompacte(p)
            println("L'exécution a pris $t secondes") 

         # Cas de retour au menu précédent
        elseif entree == "r"
            main()
            return  # Si on fait q dans le menu précédent, on va revenir ici et on return

         # Cas d'arrêt
        elseif entree == "q"
            break
        else
            print("Mauvaise valeure entrée, réessayez ou entrez q pour quitter.")
            continue
        end
    end

end

function defPMain(nbEtats)
    while true
        print("Choisissez le nombres de stations que vous voulez placer parmis les $nbEtats Etats (un entier entre 1 et $nbEtats compris) : ")
        p = readline()
        if p == "q"
            print("\n")
            return "q"
        end
        p = parse(Int, p)
        if p <= nbEtats && p > 0
            print("\n")
            return p
        else
            println("\nMauvaise valeure entrée, réessayez ou entrez q pour quitter.")
        end
    end
end

function defNbEssaisMain()
    while true
        nbEssais = readline()
        if nbEssais == "q"
            print("\n")
            return "q"
        end
        nbEssais = parse(Int, nbEssais)
        if nbEssais > 0 
            print("\n")
            return nbEssais
        else
            println("\nMauvaise valeure entrée, réessayez ou entrez q pour quitter.")
        end
    end

end

function interfaceGraphhique(coords, stations, affect)
    allX = [c[1] for c in coords]
    allY = [c[2] for c in coords]

    # Créer un nuage de points 
    p = scatter(allX, allY, 
        label="Villes", 
        color = :blue, 
        markersize=4,
        legend = :outertopright,
        title = "Visualisation p-médian",
        xlabel = "X", ylabel = "Y"
    )

    # Affecte chaque ville à sa station la plus proche en la reliant par un trait gris fin
    for i in 1:length(coords)
        indice = affect[i]
        xVille, yVille = coords[i]
        xStation, yStation = coords[indice]

        plot!(p, [xVille, xStation], [yVille, yStation], color=:gray, alpha=0.5, label="")
    end

    allStationX = [coords[s][1] for s in stations]
    allStationY = [coords[s][2] for s in stations]

    scatter!(allStationX, allStationY, 
        label = "Stations", 
        color = :red, 
        markersize = 8, 
        marker = :star5 # Forme d'étoile pour bien les voir
    )

    display(p)

end

###############################  Fonction globales d'appel ##############################

function pMedian_heuristiqueGloutonne(p)
    # Pour p=20, on a 18 stations choisies au lieue de 20 car certains rectangles peuvent être vide. Faut il choisir combler avec n'importe quelle stations
    # ou laisser moins de stations que les p demandées initialement ?
    print("\n")

    coords, minX, maxX, minY, maxY = initCoordN()
    # println("Coordonnées (x, y) de chaque ville extraite du fichier 'att48.tsp', représentant 48 états des Etats Unis : \n$coords\n")

    stations = defStationsGlouton(p, coords, minX, maxX, minY, maxY)
    #println("Liste des ièmes Etats choisis pour avoir une station de metro/bus via l'algorithme glouton : \n$stations\n")
    println("Définition des stations.")

    affect = affecterMedians(coords, stations)
    # println("Affectation des autres Etats à la station la plus proche. Affect[i] = j signifie que l'Etat i est affecté à la station de l'Etat j : \n$affect\n")
    println("Affectation des autres Etats à la station la plus proche.")

    println("Calcule du coût de la solution...")
    cout = coutPmedian(coords, stations)
    println("Coût de la solution (à minimiser) : $cout")

    interfaceGraphhique(coords, stations, affect)
end

function pMedian_metaHeuristiqueGlouton(p)
    print("\n")

    coords, minX, maxX, minY, maxY = initCoordN()
    # println("Coordonnées (x, y) de chaque ville extraite du fichier 'att48.tsp', représentant 48 états des Etats Unis : \n$coords\n")

    stations = defStationsGlouton(p, coords, minX, maxX, minY, maxY)
    coutAvant = coutPmedian(coords, stations)
    

    stations, coutApres = applicationStochastique(p, coords, stations)
    # println("Liste des ièmes Etats choisis pour avoir une station de metro/bus après améliorations par descente stochastique avec l'heuristique Gloutonne: \n$stations\n")
    println("Définition des stations.")

    affect = affecterMedians(coords, stations)
    #println("Affectation des autres Etats à la station la plus proche. Affect[i] = j signifie que l'Etat i est affecté à la station de l'Etat j : \n$affect\n")
    println("Affectation des autres Etats à la station la plus proche.")

    println("Cout de la solution (à minimiser) avant et après descente stochastique :\nCout avant, heuristique Gloutonne : $coutAvant\nCout après, heuristique Gloutonne améliorée : $coutApres")

    interfaceGraphhique(coords, stations, affect)
end


function pMedian_heuristiqueRandomisee(p, nbEssais=1)
    print("\n")
    
    coords, = initCoordN()
    # println("Coordonnées (x, y) de chaque ville extraite du fichier 'att48.tsp', représentant 48 états des Etats Unis : \n$coords\n")

    stations = meilleureSolution(p, coords, nbEssais)
    #println("Liste des ièmes Etats choisis aléatoirement pour avoir une station de metro/bus après $nbEssais essais d'améliorations : \n$stations\n")
    println("Définition des stations.")

    affect = affecterMedians(coords, stations)
    # println("Affectation des autres Etats à la station la plus proche. Affect[i] = j signifie que l'Etat i est affecté à la station de l'Etat j : \n$affect\n")
    println("Affectation des autres Etats à la station la plus proche.")

    println("Calcul du coût de la solution...")
    cout = coutPmedian(coords, stations)
    println("Cout de la solution (à minimiser) : $cout")

    interfaceGraphhique(coords, stations, affect)

end

function pMedian_metaHeuristiqueRandom(p,nbEssais=50)
    print("\n")

    coords, = initCoordN()
    # println("Coordonnées (x, y) de chaque ville extraite du fichier 'att48.tsp', représentant 48 états des Etats Unis : \n$coords\n")

    stations, cout = iterationsStochastiqueRandom(p, coords, nbEssais)
    #println("Liste des ièmes Etats choisis aléatoirement pour avoir une station de metro/bus après $nbEssais essais d'améliorations : \n$stations\n")
    println("Définition des stations.")

    affect = affecterMedians(coords, stations)
    # println("Affectation des autres Etats à la station la plus proche. Affect[i] = j signifie que l'Etat i est affecté à la station de l'Etat j : \n$affect\n")
    println("Affectation des autres Etats à la station la plus proche.")

    println("Calcul du coût de la solution...")

    println("Cout de la solution (à minimiser) : $cout")

    interfaceGraphhique(coords, stations, affect)

end


function pMedian_plneCompacte(p)
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

    println("Résolution par le solveur linéaire")
    optimize!(m)
    
    println("Affichage des résultats : \n")
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

        println("Calcul du coût de la solution...")
        cout = objective_value(m)
        println("Cout de la solution (à minimiser) : $cout")
    end

    interfaceGraphhique(coords, stations, affect)
    
end


################################### Fonctions pour glouton ###############################################

function initCoordN()
    coords = Vector{Tuple{Float64, Float64}}()
    minX = Inf
    maxX = -Inf
    maxY = -Inf
    minY = Inf
    b = false
    for l in eachline("att48.tsp")
        # On veut sortir de la boucle quand on a fini dfe lire la section NODE_COORD_SECTION, et c'est TOUR_SECTION qui vient juste après
        if l == "TOUR_SECTION"  
            break
        end

        # On veut commencer à lire quand on entre dans la section NODE_COORD_SECTION, on place donc un booléen à vrai.
        # Si on commençait à lire dès que était vrai il lisait la ligne NODE_COORD_SECTION or on veut lire à partir de la prochaine ligne, on fait donc continuer pour faire un tour de boucle en plus.
        if l == "NODE_COORD_SECTION"
            b = true
            continue
        end
        
        if b
            tabLigne = split(l)
            x = parse(Float64, tabLigne[2])
            y = parse(Float64, tabLigne[3])
            
            # On en profite pour récupérer en même temps les dimensions max et min des points sur les 2 axes du plan comme demandés dans le sujet.
            if x > maxX
                maxX = x
            end
            if x < minX
                minX = x
            end
            if y > maxY
                maxY = y
            end
            if y < minY
                minY = y
            end
            ##############

            push!(coords, (x, y))
        end
    end
    return coords, minX, maxX, minY, maxY
end


# Va affecter tous les points de coords à leur station la plus proche
function affecterMedians(coords, stations)

    affect = Vector{Int}(undef, length(coords))
    for i in 1:length(coords)
        indice = -1
        (x, y) = coords[i]
        distMin = Inf
        for j in stations
            (x1, y1) = coords[j]
            dist_ij = sqrt((x-x1)^2 + (y-y1)^2)
            if dist_ij < distMin
                distMin = dist_ij
                indice = j   # indice est la station j la plus proche pour l'instant
            end
        end
        if indice != -1
            affect[i] = indice  # On affecte ici le point i à la station indice qui est la plus proche parmis nos stations.
        end
    end
    return affect
end

function defStationsGlouton(p, coords, minX, maxX, minY, maxY)
    q = ceil(sqrt(p))  # Renvoie la racine carrée arrondie à l'entier supérieur
    nbRect = q*q

    LRect = (maxX-minX)/q   # longeur d'un petit rectange
    lRect = (maxY-minY)/q   # largeur        //

    stations = Int[]
    push!(stations, 1) # On nous dit que le point 1 est toujours une station, on l'ajoute donc dès le début.

    # lister tous les points dans chaque rectangle 
    for i in 1:q
        for j in 1:q
            # On calcule les bornes inf et sup du rectangle où on se trouve
            minRectX = minX + (i-1)*LRect
            maxRectX = minX + i*LRect
            minRectY = minY + (j-1)*lRect
            maxRectY = minY + j*lRect

            # On calcule les coord du centre du rectangle où on se trouve 
            centreRectX = (minRectX + maxRectX)/2
            centreRectY = (minRectY + maxRectY)/2

            distOpt = Inf
            n=-1    # indice des stations que l'on va choisir, on le place à -1 qui ne peut pas être une station au début

            for k in 1:length(coords)
                (x, y) = coords[k]
                
                if (x >= minRectX && x <= maxRectX && y >= minRectY && y <= maxRectY) # On vérifie que notre point se trouve dans le rectangle où on est
                    dist = sqrt((x-centreRectX)^2 + (y - centreRectY)^2) # distance entre notre point actuel et le centre du rectangle
                    # Si c'est le point le plus proche du centre que l'on a trouvé pour l'instant, on affecte k à n.
                    if dist < distOpt
                        distOpt = dist
                        n = k
                    end
                end
            end

            if (n != -1)
                push!(stations, n)  
            end

        end
    end

    # unique permet d'éviter les doublons si un point est pile sur la limite entre 2 rectangles
    stations = unique(stations)
    if length(stations) > p
        stations = trierStations(stations, coords, p)
    elseif length(stations) < p
        stations = comblerStations(stations, length(coords), p)
    end
    return stations
end

#= 
# L'ennoncé impose enfait une méthode qui est de regrouper par paires de stations les plus proches et on en supprime une des 2
# Cette fonction n'est donc pas optimale

function trierStations(stations, coords, p)
    nbStations = length(stations)
    # On définit pour l'instant arbitrairement que 2 stations ne doivent pas être à 200m d'écart 
    ecartMin = 200 - 30
    while nbStations > p
        ecartMin += 30     # Si on a toujours trop de stations, on augmente la distance minimale acceptée entre 2 stations de 30m
        i = 1
        while i < nbStations
            (x, y) = coords[stations[i]]
            for j in nbStations:-1:(i+1)    # Parcourt à l'envers afin de ne pas sauter des elt du tableau lors du parcours de boucle  
                (x1, y1) = coords[stations[j]]
                dist_ij = sqrt((x-x1)^2 + (y-y1)^2)
                if dist_ij <= ecartMin
                    deleteat!(stations, j)  # Supprime stations[j]
                    nbStations -=1
                end
            end
            i+=1
        end
    end
    return stations
end
 =#


function trierStations(stations, coords, p)

    while length(stations) > p
        distMin = Inf
        indice = -1

        for i in 1:length(stations)
            (x, y) = coords[stations[i]]
            for j in (i+1):length(stations)   
                (x1, y1) = coords[stations[j]]
                dist_ij = sqrt((x-x1)^2 + (y-y1)^2)
                if dist_ij <= distMin
                    distMin = dist_ij
                    if stations[i] == 1
                        indice = j     # Si l'indice i est le point 1, on supprimera l'indice j
                    else
                        indice = i     # Sinon, on supprimera l'indice i
                    end
                end
            end
        end
        if indice != -1
            deleteat!(stations, indice)
        end
    end
    return stations
end

# Si il n'y a pas assez de stations, on comble par ordre croissant avec les premiers Etats qui ne sont pas des stations
function comblerStations(stations, nbEtats, p)
    
    for i in 1:nbEtats
        if (length(stations) == p)
            break
        end
        if !(i in stations)
            push!(stations, i)
        end
    end
    return stations
end


#################################################### Fonctions pour Random ###########################################################

function defStationsRandom(p, nbEtats)

    stations = Int[]
    push!(stations, 1)     # Le point 1 est toujours une station
    permTab = randperm(nbEtats-1).+1  # créer une permutation aléatoire allant de 2 à lenght(coords)
    append!(stations, permTab[1:p-1])       # Ajoute à stations les elt de permTab 1 par 1
    return stations
end

function coutPmedian(coords, stations)
    cout = 0.0
    affect = affecterMedians(coords, stations)
    for i in 1:length(coords)
        (x, y) = coords[i]
        j = affect[i]
        (x1, y1) = coords[j]
        cout += sqrt((x-x1)^2 + (y-y1)^2)   # Le cout s'exprime en fonction de la distance entre chaque point et sa station la plus proche, ce que l'on voudra ensuite minimiser
    end
    return cout
end

function meilleureSolution(p, coords, nbEssais)
    minCout = Inf       # On va chercher le cout minimal
    bestStations = Int[]    # On voudra sauvegarder la station trouvée quand on a un coût minimal
    nbEtats = length(coords)  # Permet de ne pas recalculer length(coords) à de nombreuses reprises dans nos boucles et de devoir passer tout le tableau coords en arguments quand on a juste besoin du nb d'etats
    
    for i in 1:nbEssais
        stations = defStationsRandom(p, nbEtats)
        cout = coutPmedian(coords, stations)
        if cout < minCout
            minCout = cout
            bestStations = copy(stations)
        end
    end
    return bestStations
end

######################################## Fonctions pour meta heuristiques (Random et Glouton)  ##########################################

function swapStation(stations, nbEtats)
    
    stations2 = copy(stations)      # Il faut utiliser copy car sinon stations2 et stations pointeraient vers le même tableau et une modif sur stations2 modifieraient stations.
    i = rand(2:length(stations2))   # on commence à 2 car l'Etat 1 est toujours une station
    deleteat!(stations2, i)         # On supprime l'Etat i des stations que l'on va ensuite remplacer
    
    while(true)
        j = rand(2:nbEtats)
        if j!=i && !(j in stations2)    # Si l'Etat j n'est pas une station et n'est pas l'étt i qu'on a tiré juste avant, on le mets dans stations pour remplacer l'Etat i.
            push!(stations2, j)
            break
        end
    end
    return stations2
end

# Améliore une solution de stations en échangeant un Etat qui n'est pas une station avec un Etat qui en est une et voit si cela améliore notre solution
# Permet d'obtenir une solution optimale locale pour une solution de stations 
function applicationStochastique(p, coords, stations)

    if length(stations) <= 1
        println("On ne peut pas utiliser la méta heuristique gloutonne car on n'a qu'une seule station et le point 1 est forcément une station, on ne peut donc pas l'échanger avec une autre.\n")
        return stations, coutPmedian(coords, stations)
    end

    nbEtats = length(coords)  
    cpt = nbEtats    # On fixe notre compteur arbitrairement en fct du nb d'Etats que l'on a
    cout = coutPmedian(coords, stations)
    
    while cpt > 0       
        stationsTest = swapStation(stations, nbEtats)   # On fait un échange entre une stations et un Etats n'ayant pas de stations
        coutTest = coutPmedian(coords, stationsTest)   # On calcule le coût de cette nouvelle solution 
        if coutTest < cout  # On va affecter cette nouvelles liste de stations si elle est une meilleure solution.
            cpt = nbEtats
            stations = stationsTest
            cout = coutTest
        else
            cpt-=1   # Si on a fait lenght(coords) essais sans améliorations, on s'arrête.
        end
    end
    return stations, cout

end

# Va effectuer nbEssais itérations en prenant un ensemble de stations aléatoires que l'on va améliorer avec notre application stochastique. On garde à la fin le meilleur résultat amélioré.
# Permet d'atteindre un maximum global et de ne pas rester bloquer dans un maximum local que l'on obtient avec une unique application stochastique.
function iterationsStochastiqueRandom(p, coords, nbEssais)

    bestCout= Inf
    bestStations = Int[]
    nbEtats = length(coords)

    for i in 1:nbEssais 
        stations = defStationsRandom(p, nbEtats)
        stationsTest, cout = applicationStochastique(p, coords, stations)
        if cout < bestCout
            bestCout = cout
            bestStations = copy(stationsTest)
        end
    end
    return bestStations, bestCout

end

############################################# Fonctions pour PLNE Compacte ############################################

# Initialise une matrice de distance séparant chaque villes. 
function initMatriceDistance(coords, nbEtats)
    d = Matrix{Float64}(undef, nbEtats, nbEtats)
    for i in 1:nbEtats
        for j in 1:nbEtats
            (x, y) = coords[i]
            (x1, y1) = coords[j]
            d[i, j] = sqrt((x-x1)^2 + (y-y1)^2)
        end
    end
    return d
end



########################################## Test de rapidité des différentes méthodes pures ###################################

function testVitesse_glouton(p)
    coords, minX, maxX, minY, maxY = initCoordN()
    stations = defStationsGlouton(p, coords, minX, maxX, minY, maxY)
    affect = affecterMedians(coords, stations)
    cout = coutPmedian(coords, stations)
end


function testVitesse_metaHeuristiqueGlouton(p)
    # On appelle pas la fonction coutPmedian avec coutAvant car elle n'est pas nécéssaire pour la méta heuristique glouton,
    # on l'utilisait juste pour avoir un comparatif. On teste ici juste la vitesse d'exécution des fonctions purement nécéssaires.

    coords, minX, maxX, minY, maxY = initCoordN()
    stations = defStationsGlouton(p, coords, minX, maxX, minY, maxY)
    stations, coutApres = applicationStochastique(p, coords, stations)
    affect = affecterMedians(coords, stations)
end


function testVitesse_random(p, nbEssais)
    coords, = initCoordN()
    stations = meilleureSolution(p, coords, nbEssais)
    affect = affecterMedians(coords, stations)
    cout = coutPmedian(coords, stations)
end


function testVitesse_metaHeuristiqueRandom(p, nbEssais)
    coords, = initCoordN()
    stations = meilleureSolution(p, coords, nbEssais)
    affect = affecterMedians(coords, stations)
    cout = coutPmedian(coords, stations)
end


function testVitesse_plneCompacte(p)
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
        return      # pas de println qui ralentissent la fonction 
    elseif status == UNBOUNDED
        return      # pas de println qui ralentissent la fonction 
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

        cout = objective_value(m)
    end
end
