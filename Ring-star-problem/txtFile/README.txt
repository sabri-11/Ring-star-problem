Pour compiler le programme, vous pourriez avoir besoin d'exécuter ces commandes : 
placez vous le dossier Rinsg-star-problem/src/ et executez : 
julia

import Pkg
Pkg.add("JuMP")
Pkg.add("GLPK")
Pkg.add("Plots")
Pkg.add("BenchmarkTools")

Si vous utilisez CPLEX, il faudra fairz également : 
Pkg.add("CPLEX")
Pkg.build("CPLEX")


