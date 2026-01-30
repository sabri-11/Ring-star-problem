include("pMedian.jl")
include("tsp.jl")
include("anneauEtoile.jl")
include("mainFonctions")



# Définition de constantes pour le statut de résolution du problème
const OPTIMAL = JuMP.MOI.OPTIMAL
const INFEASIBLE = JuMP.MOI.INFEASIBLE
const UNBOUNDED = JuMP.MOI.DUAL_INFEASIBLE;



function main()
    # fichier = choixFichier()
    # chemin = joinpath("..", "tspFile", fichier)
    chemin = "../tspFile/att48.tsp"

    coords, = initCoordN(chemin)
    nbEtats = length(coords)
    
    f = open("../txtFile/historique.txt", "w")
    write(f, "historique des tests réalisés : \n\n")
    
    run(`xdg-open ../txtFile/historique.txt`)  # ouvre le fichier historique.txt automatiquement
    
    texte(nbEtats)
    while true
        q = pressEnter()
        if q == "q"
            close(f)
            return
        end
        choixMethode = choixPMedian()
        if choixMethode != 6
            choixCycle = choixTsp()
            alpha = choixAlpha()
        else
            alpha = choixAlpha()
            choixCycle = -1
        end

        p = defNbStations(nbEtats)
        stations, affect, ordreDeVisite, cout, temps, nbEssais = executionProgramme(p, chemin, choixCycle, choixMethode, alpha)
        # println(f, "stations : $stations de coord : $([coords[i] for i in stations])")
        # println(f, "ordre de visite : $ordreDeVisite")
        interfaceGraphhique_anneauEtoile(coords, stations, affect, ordreDeVisite, cout)
        remplirHistorique(f, choixCycle, choixMethode, p, cout, temps, nbEssais, alpha)
        
    end
end


main()