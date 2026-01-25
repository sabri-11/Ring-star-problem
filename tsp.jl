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


# Algorithme du plus proche voisin pour construire un cycle passant par toutes les stations 
function plusProcheVoisin(coords, stations)
    ordreDeVisite = Int[]
    push!(ordreDeVisite, 1)
  
    while length(ordreDeVisite) < length(stations)
        distMin = Inf
        plusProcheStation = -1
        
        derniereVisite = ordreDeVisite[end]     # On repart du dernier point qu'on a visité

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

# Empeche les arrêtes qui se croise en testant chaque paire d'arrête (ei, ej), si le chemin pour aller de ei à ej
function plusProcheVoisin_2opt(coords, stations)
    ordreDeVisite = plusProcheVoisin(coords, stations)

    mieux = true 
    n = length(ordreDeVisite)
    while mieux
        mieux = false
        for i in 1:n-2                  # à la fin, i = n-2 et j = n (avec n : length(ordreDeVisite))
            valI = ordreDeVisite[i]
            valNextI = ordreDeVisite[i+1]

            xi, yi = coords[valI][1], coords[valI][2]
            xNextI, yNextI = coords[valNextI][1], coords[valNextI][2]
            for j in (i+2):n
                if j == n && i == 1
                    continue
                end

                valJ = ordreDeVisite[j]
                if j < n
                    valNextJ = ordreDeVisite[j+1]
                elseif j == n
                    valNextJ = ordreDeVisite[1]     # on le relie au point 1 si j est au dernier point pour faire un cycle
                end

                xj, yj = coords[valJ][1], coords[valJ][2]
                xNextJ, yNextJ = coords[valNextJ][1], coords[valNextJ][2]
                
                dist_iNextI = sqrt((xNextI - xi)^2 + (yi - yNextI)^2)
                dist_jNextJ = sqrt((xNextJ - xj)^2 + (yj - yNextJ)^2)

                dist_ij = sqrt((xj - xi)^2 + (yj - yi)^2)
                dist_nextINextJ = sqrt((xNextJ - xNextI)^2 + (yNextJ - yNextI)^2)

                coutBase = dist_iNextI + dist_jNextJ   # on a [i, i+1, j, j+1] avec une arrête qui se croise si pas optimal 
                coutPossible = dist_ij + dist_nextINextJ  # on essaye de faire [i, j, i+1, j+1] avec les points entre i+1 et j dans l'ordre inverse

                if coutPossible < coutBase
                    mieux = true
                    reverse!(ordreDeVisite, i+1, j)     # On inverse tout le segments entre i+1 et j, 6-7-8-9-10 devient 6-9-8-7-10
                end
            end

        end
    end

    return ordreDeVisite

end





