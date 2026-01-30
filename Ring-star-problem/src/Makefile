depotTemp = /tmp/julia_depot_"e12210775"_ringStarProblem
runUniv = JULIA_DEPOT_PATH=$(depotTemp) julia
main = main.jl

all: setupUniv setup run runUniv clearUniv

setupUniv:
	$(runUniv) -e 'using Pkg; \
	Pkg.add(name="GR", version="0.66"); \
	Pkg.pin("GR"); \
	Pkg.add(name="Plots", version="1.32"); \
	Pkg.add(["JuMP", "GLPK", "BenchmarkTools"]); \
	Pkg.precompile()'

setup:
	julia -e 'using Pkg; \
	Pkg.add(["JuMP", "GLPK", "Plots", "BenchmarkTools"]); \
	Pkg.precompile()'

runUniv:
	$(runUniv) $(main)

run:
	julia $(main)

clearUniv:
	rm -rf $(depotTemp)
