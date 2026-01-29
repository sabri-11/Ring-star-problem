Pour compiler le programme, vous pourriez avoir besoin d'exécuter ces commandes : 
placez vous le dossier Rinsg-star-problem/src/ et executez : 
julia

import Pkg
Pkg.add("JuMP")
Pkg.add("GLPK")
Pkg.add("Plots")
Pkg.add("BenchmarkTools")

Si vous utilisez CPLEX, il faudra également faire : 
ENV["CPLEX_STUDIO_BINARIES"] = "/opt/ibm/ILOG/CPLEX_Studio2211/cplex/bin/x86-64_linux/"		# (mettre le chemin ou cplex est installé)
Pkg.add("CPLEX")
Pkg.build("CPLEX")



Notice d'utilisation du programme : 


