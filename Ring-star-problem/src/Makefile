depotTemp = /tmp/julia_depot_"e12210775"_ringStarProblem
runUniv = JULIA_DEPOT_PATH=$(depotTemp) julia
main = main.jl

all: installUniv install run runUniv clearUniv

installUniv:
	$(runUniv) -e 'using Pkg; \
	Pkg.add(name="GR", version="0.66"); \
	Pkg.pin("GR"); \
	Pkg.add(name="Plots", version="1.32"); \
	Pkg.add(["JuMP", "GLPK", "BenchmarkTools"]); \
	Pkg.precompile()'

install:
	julia -e 'using Pkg; Pkg.add(name="GR", version="0.66"); \
	Pkg.pin("GR"); \
	Pkg.add(name="Plots", version="1.32"); \
	Pkg.add(["JuMP", "GLPK", "BenchmarkTools"]); \
	Pkg.precompile()'

runUniv:
	$(runUniv) $(main)

run:
	julia -e $(main)

clearUniv:
	rm -rf $(depotTemp)