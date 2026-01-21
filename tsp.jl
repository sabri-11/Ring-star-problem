include("pMedian.jl")


# Le cout du tsp est calculé en fonction de la longueru total du cycle
function coutTsp(coords, ordreDeVisite)
    cout = 0.0
    for i in 1:(length(ordreDeVisite)-1)
        station1 = ordreDeVisite[i]
        station2 = ordreDeVisite[i+1]
        (x, y) = coords[station1]
        (x1, y1) = coords[station2]
        dist = sqrt((x-x1)^2 + (y-y1)^2)
        cout += dist
    end
    derniereStation = ordreDeVisite[end]
    (xf, yf) = coords[derniereStation]
    (x1, y1) = coords[1]
    distFinal = sqrt((xf-x1)^2 + (yf-y1)^2)
    cout += distFinal

    return cout
end



function plneCompacteTsp(p)

end

# Algorithme du plus proche voisin pour construire un cycle passant par toutes les stations 
function plusProcheVoisin(coords, stations)
    ordreDeVisite = Int[]
    push!(ordreDeVisite, 1)
  
    while length(ordreDeVisite) < length(stations)
        distMin = Inf
        plusProcheStation = -1
        
        derniereVisite = ordreDeVisite[end]

        (x, y) = coords[derniereVisite]
        for j in stations
            if !(j in ordreDeVisite)
                (x1, y1) = coords[j]
                dist = sqrt((x-x1)^2 + (y-y1)^2)
                if dist < distMin
                    distMin = dist
                    plusProcheStation = j
                end
            end
        end
        if plusProcheStation > 0
            push!(ordreDeVisite, plusProcheStation)
        end
    end
    return ordreDeVisite
end

function plusProcheVoisin_2opt(coords, stations)
    
end



# Réalise le modèle PLNE compact pour le TSP avec p stations
function tspSurPlne(p)
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
        interfaceGraphhiqueTsp(coords, stations, affect, ordreDeVisite, cout)

    end

    

end

function interfaceGraphhiqueTsp(coords, stations, affect, ordreDeVisite, cout)
    allX = [c[1] for c in coords]
    allY = [c[2] for c in coords]

     # Créer un nuage de points 
    p = scatter(allX, allY, 
        label="Villes", 
        color = :blue, 
        markersize=4,
        legend = :outertopright,
        title = "Visualisation Tsp Anneau etoile.\nCout solution (à min) : $(round(cout, digits=2))",
        xlabel = "X", ylabel = "Y",
        aspect_ratio = :equal
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
        markersize = 10, 
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


