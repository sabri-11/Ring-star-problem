using JuMP
using GLPK
# using CPLEX
using Random
using BenchmarkTools
using Plots


#################################### Lecture du fichier att48.tsp ######################################

function initCoordN(chemin)
    coords = Vector{Tuple{Float64, Float64}}()
    minX = Inf
    maxX = -Inf
    maxY = -Inf
    minY = Inf
    b = false


    for ligne in eachline(chemin)
        l = strip(ligne)    # Pas forcément necéssaire, mais nettoie la ligne au cas ou elle prends un \n à la fin
        
        # On veut sortir de la boucle quand on a fini dfe lire la section NODE_COORD_SECTION, et c'est TOUR_SECTION ou EOF qui vient juste après en fonction du type de fichier
        if l == "TOUR_SECTION" || l == "EOF"
            break
        end

        # On veut commencer à lire quand on entre dans la section NODE_COORD_SECTION, on place donc un booléen à vrai.
        # Si on commençait à lire dès que était vrai il lisait la ligne NODE_COORD_SECTION or on veut lire à partir de la prochaine ligne, on fait donc continue pour faire un tour de boucle en plus.
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



################################### Fonctions pour glouton ###############################################

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


# On regroupe par paires de stations les plus proches et on en supprime une des 2
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
            deleteat!(stations, indice) # supprime l'elt à l'indice 'indice' du tableau 'stations'
        end
    end
    return stations
end

# choisit des points aléaoire qui ne sont pas stations et les met stations
function comblerStations(stations, nbEtats, p)
    perm = randperm(nbEtats-1).+1

    for i in perm
        if length(stations ) == p
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

function meilleureSolutionRandom(p, coords, nbEssais)
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

######################################## Fonctions pour métaheuristiques (Random et Glouton)  ##########################################

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
# Permet d'obtenir une solution optimale locale pour un ensemble de stations données
function applicationStochastique_ppv(p, coords, stations, alpha)

    if length(stations) <= 1
        println("On ne peut pas utiliser la méta heuristique gloutonne car on n'a qu'une seule station et le point 1 est forcément une station, on ne peut donc pas l'échanger avec une autre.\n")
        return stations, [1],coutPmedian(coords, stations)
    end

    nbEtats = length(coords)  
    cpt = 2*nbEtats    # On fixe notre compteur arbitrairement en fct du nb d'Etats que l'on a
    ordreDeVisite = plusProcheVoisin(coords, stations)
    cout = coutPmedian(coords, stations) + coutTsp(coords, ordreDeVisite, alpha)
    
    while cpt > 0       
        stationsTest = swapStation(stations, nbEtats)   # On fait un échange entre une stations et un Etats n'ayant pas de stations
        ordreDeVisiteTest = plusProcheVoisin(coords, stationsTest)
        coutTest = coutPmedian(coords, stationsTest) + coutTsp(coords, ordreDeVisite, alpha)   # On calcule le coût de cette nouvelle solution 
        if coutTest < cout  # On va affecter cette nouvelles liste de stations si elle est une meilleure solution.
            cpt = 2*nbEtats
            stations = stationsTest
            ordreDeVisite = ordreDeVisiteTest
            cout = coutTest
        else
            cpt-=1   # Si on a fait lenght(coords) essais sans améliorations, on s'arrête.
        end
    end
    return stations, ordreDeVisite, cout

end

# pareil mais utilise le cycle ppv 2 opt
function applicationStochastique_ppv2opt(p, coords, stations, alpha)

    if length(stations) <= 1
        println("On ne peut pas utiliser la méta heuristique gloutonne car on n'a qu'une seule station et le point 1 est forcément une station, on ne peut donc pas l'échanger avec une autre.\n")
        return stations, coutPmedian(coords, stations)
    end

    nbEtats = length(coords)  
    cpt = 2*nbEtats    # On fixe notre compteur arbitrairement en fct du nb d'Etats que l'on a
    ordreDeVisite = plusProcheVoisin_2opt(coords, stations)
    cout = coutPmedian(coords, stations) + coutTsp(coords, ordreDeVisite, alpha)
    
    while cpt > 0       
        stationsTest = swapStation(stations, nbEtats)   # On fait un échange entre une stations et un Etats n'ayant pas de stations
        ordreDeVisiteTest = plusProcheVoisin_2opt(coords, stationsTest)
        coutTest = coutPmedian(coords, stationsTest) + coutTsp(coords, ordreDeVisite, alpha)   # On calcule le coût de cette nouvelle solution 
        if coutTest < cout  # On va affecter cette nouvelles liste de stations si elle est une meilleure solution.
            cpt = 2*nbEtats
            stations = stationsTest
            ordreDeVisite = ordreDeVisiteTest
            cout = coutTest
        else
            cpt-=1   # Si on a fait lenght(coords) essais sans améliorations, on s'arrête.
        end
    end
    return stations, ordreDeVisite, cout

end

# Va effectuer nbEssais itérations en prenant un ensemble de stations aléatoires que l'on va améliorer avec notre application stochastique. On garde à la fin le meilleur résultat amélioré.
# Permet d'atteindre un maximum global et de ne pas rester bloquer dans un maximum local que l'on obtient avec une unique application stochastique.
function iterationsStochastiqueRandom_ppv(p, coords, nbEssais, alpha)

    bestCout= Inf
    bestStations = Int[]
    bestOrdreDeVisite = Int[]
    nbEtats = length(coords)

    for i in 1:nbEssais 
        stations = defStationsRandom(p, nbEtats)
        stationsTest, ordreDeVisiteTest, cout = applicationStochastique_ppv(p, coords, stations, alpha)
        if cout < bestCout
            bestCout = cout
            bestStations = copy(stationsTest)
            bestOrdreDeVisite = copy(ordreDeVisiteTest)
        end
    end
    return bestStations, bestOrdreDeVisite, bestCout
end

function iterationsStochastiqueRandom_ppv2opt(p, coords, nbEssais, alpha)

    bestCout= Inf
    bestStations = Int[]
    bestOrdreDeVisite = Int[]
    nbEtats = length(coords)

    for i in 1:nbEssais 
        stations = defStationsRandom(p, nbEtats)
        stationsTest, ordreDeVisiteTest, cout = applicationStochastique_ppv2opt(p, coords, stations, alpha)
        if cout < bestCout
            bestCout = cout
            bestStations = copy(stationsTest)
            bestOrdreDeVisite = copy(ordreDeVisiteTest)
        end
    end
    return bestStations, bestOrdreDeVisite, bestCout
end

############################################# Fonctions pour PLNE Compacte ############################################

# Initialise une matrice de distance séparant chaque villes. 

function pMedian_plneCompacte(p, chemin)
    coords, = initCoordN(chemin)
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
    stations = Int[]
    affect = Vector{Int}(undef, nbEtats)
    cout = Inf

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
                    break       # On a trouvé sa station affectée, on passe au point suivant.
                end
            end
        end

        # println("Liste des ièmes Etats choisis pour avoir une station de metro/bus via résolution d'un PLNE compacte : \n$stations\n")
        # println("Affectation des autres Etats à la station la plus proche. Affect[i] = j signifie que l'Etat i est affecté à la station de l'Etat j : \n$affect\n")
        # println("Calcul du coût de la solution...")
        cout = objective_value(m)
        # println("Cout de la solution (à minimiser) : $cout")
        # interfaceGraphhiquePmedian(coords, stations, affect)
        
    end
    return coords, stations, affect, cout
end

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


