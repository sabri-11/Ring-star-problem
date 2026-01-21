include("pMedian.jl")

################################# Nouvelles fonctions ####################

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

function tspSurGlouton(p)
    coords, minX, maxX, minY, maxY = initCoordN()
    stations = defStationsGlouton(p, coords, minX, maxX, minY, maxY)
    println("Définition des stations. $stations")
    ordreDeVisite = plusProcheVoisin(coords, stations)
    println("Ordre de visite des stations. $ordreDeVisite")
    cout = coutTsp(coords, ordreDeVisite)
    println("Cout Tsp (à minimiser). $cout")
end


# Faire une fonction interfaceGraphhique qui numérote les stations en fonctions de leur ordre de visite
