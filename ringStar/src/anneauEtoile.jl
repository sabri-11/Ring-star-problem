include("pMedian.jl")
include("tsp.jl")


######################################## Affichage graphique des résultats ################################

function interfaceGraphhique_anneauEtoile(coords, stations, affect, ordreDeVisite, cout)
    allX = [c[1] for c in coords]
    allY = [c[2] for c in coords]

     # Créer un nuage de points 
    p = scatter(allX, allY, 
        label="Villes", 
        color = :blue, 
        markersize=3.5,
        legend = :outertopright,
        title = "Visualisation problème Anneau etoile.\nCoût sol (à minimiser) : $(round(cout, digits=2))",
        xlabel = "X", ylabel = "Y",
        aspect_ratio = :equal   # force les axes x et y à avoir la même échelle
    )

    # Affecte chaque ville à sa station la plus proche en la reliant par un trait gris fin
    for i in 1:length(coords)
        indice = affect[i]
        xVille, yVille = coords[i]
        xStation, yStation = coords[indice]

        plot!(p, [xVille, xStation], [yVille, yStation], color=:gray, alpha=0.5, label="")
    end


    # Tracé du cycle avec une ligne noire
    cycleX = [coords[i][1] for i in ordreDeVisite]
    cycleY = [coords[i][2] for i in ordreDeVisite]
    
    # Fermeture de la boucle
    push!(cycleX, coords[ordreDeVisite[1]][1])
    push!(cycleY, coords[ordreDeVisite[1]][2])

    plot!(p, cycleX, cycleY, color=:black, linewidth=2, label="Métro")

    # affichage des stations 
    # On retire le dernier point (doublon de fermeture) pour ne pas afficher deux fois l'étoile
    scatter!(p, cycleX[1:end-1], cycleY[1:end-1], 
        color = :red, 
        markersize = 9, 
        marker = :star5, 
        label = "Stations"
    )

    
    # On annote directement dans la boucle 
    for (k, s) in enumerate(ordreDeVisite)  # enumerate permet d'associer le couple (k, s) avec s la valeur dans la liste ordreDeVisite et k l'indice de la liste
        (x, y) = coords[s]
        annotate!(p, x, y+150, text(string(k), 10, :black, :bottom))
    end

    display(p)
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

function ae_plne(p)
    coords, = initCoordN()
    nbEtats = length(coords)   
    d = initMatriceDistance(coords, nbEtats)

    stations = Int[]
    affect = Vector{Int}(undef, nbEtats)
    ordreDeVisite = Int[]
    cout = 0.0

    # On avait une erreur si on décidait de placer qu'une seule station car le solveur ne pouvait pas faire de cycle, on gère donc ce cas spécial. 
    if p == 1
        return uneStation(affect, nbEtats, d)
    end 

    m = Model(GLPK.Optimizer)
    tMax = 60.0     # temps max pour trouver une solution (en s)
    set_time_limit_sec(m, tMax)

    @variable(m, y[1:nbEtats, 1:nbEtats], Bin)      # yii = 1 si p est une station et yij = 1 si la ville i est affectée à la station j
    @variable(m, x[1:nbEtats, 1:nbEtats], Bin)      # x représente les arrêtes, il y a autant d'arrête que de stations. xij = 1 si i et j sont des stations reliées par une arrête
    @variable(m, 0 <= z[1:nbEtats, 1:nbEtats] <= p-1, Int)

    @objective( m,  Min, sum(d[i, j]*x[i, j] for i in 1:nbEtats, j in 1:nbEtats) + sum(d[i, j]*y[i, j] for i in 1:nbEtats, j in 1:nbEtats) )


    @constraint(m, sum(y[i, i] for i in 1:nbEtats) == p)    # cte (1)
    @constraint(m, y[1, 1] == 1)       # On doit forcer le point 1 à être une station

    for i in 1:nbEtats
        @constraint(m, sum(y[i, j] for j in 1:nbEtats) == 1)    # cte (2)
        # On voit le graphe comme un graphe orienté formant un cycle, si on fait 2*y[i, i], on pourrait
        # avoir 2 arrêtes partant d'un même sommet et non une arrête entrante et une sortante
        @constraint(m, sum(x[i, j] for j in 1:nbEtats) == y[i, i])   # cte (4)
        @constraint(m, sum(x[j, i] for j in 1:nbEtats) == y[i, i])   # cte (4)

        @constraint(m, x[i, i] == 0)    # il ne peut pas y avoir d'arêtes boucles sur une station

    end

    for i in 1:nbEtats
        for j in 1:nbEtats
            @constraint(m, y[i, j] <= y[j, j])   # cte (3)  (si i = j ici y[j, j] <= y[j, j] renvoie vrai, ça ne gène donc pas le solveur)
            @constraint(m, z[i, j] <= (p - 1) * x[i, j])   # cte (7)
        end
    end
    
    @constraint(m, sum(z[1, j] for j in 2:nbEtats) == p-1)  # cte (5)
    
    for i in 2:nbEtats
        zji = sum(z[j, i] for j in 1:nbEtats)
        zij = sum(z[i, j] for j in 1:nbEtats)

        @constraint(m, zji == zij + y[i, i])   # cte (6)
    end

    optimize!(m)

    status = termination_status(m)
    if status == INFEASIBLE
        println("Le problème n'est pas réalisable")
    elseif status == UNBOUNDED
        println("Le problème est non borné")
    elseif status == OPTIMAL || (status == TIME_LIMIT && has_values(m))
        if status == TIME_LIMIT
            println("$(tMax)s se sont écoulées, affichage de la meilleure solution non optimale trouvée : \n")
        end
        resolution(p, x, y, stations, affect, ordreDeVisite, nbEtats)
        cout = objective_value(m)
    end

    return stations, affect, ordreDeVisite, cout
end


function uneStation(affect, nbEtats, d)
    cout = 0.0
    stations = ordreDeVisite = [1]
    for i in 1:nbEtats
        affect[i] = 1
        cout += d[i, 1]
    end
    return stations, affect, ordreDeVisite, cout

end

function resolution(p, x, y, stations, affect, ordreDeVisite, nbEtats)
    for i in 1:nbEtats
        if value(y[i, i]) > 0.9
            push!(stations, i)
        end
    end
    for i in 1:nbEtats
        for j in 1:nbEtats
            if value(y[i, j]) > 0.9
                affect[i] = j
                break   # On a trouvé sa station affectée, on passe au point suivant.
            end
        end
    end
    
    etat = 1

    while length(ordreDeVisite) < p
        push!(ordreDeVisite, etat)
        bool = false

        for j in 1:nbEtats
            if value(x[etat, j]) > 0.9      # si il y a une arrête entre l'état ou on est et l'etat j, alors on passe à j qu'on ajoutera à ordreDeVisite
                etat = j
                bool = true
                break 
            end
        end

        if !bool 
            break
        end
    end
end