include("pMedian.jl")
include("tsp.jl")
include("anneauEtoile.jl")
include("mainFonctions.jl")



# Définition de constantes pour le statut de résolution du problème
const OPTIMAL = JuMP.MOI.OPTIMAL
const INFEASIBLE = JuMP.MOI.INFEASIBLE
const UNBOUNDED = JuMP.MOI.DUAL_INFEASIBLE;



function main()
    fichier = choixFichier()
    chemin = joinpath("..", "tspFile", fichier)
    # chemin = "../tspFile/att48.tsp"

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
        interfaceGraphhique_anneauEtoile(coords, stations, affect, ordreDeVisite, cout)
        remplirHistorique(f, choixCycle, choixMethode, p, stations, ordreDeVisite, affect, cout, temps, nbEssais, alpha)
        
    end
end


main()