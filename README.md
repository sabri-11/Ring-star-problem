Pour compiler le programme, placez vous dans le dossier src/ et exécutez ces commandes : 

Pour le lancer depuis les machines de l'université faites : 
make setupUniv
make runUniv

Pour le lancer depuis un autre ordinateur, faites : 
make setup
make run


Si vous utilisez CPLEX, il faudra également faire : 
ENV["CPLEX_STUDIO_BINARIES"] = "/opt/ibm/ILOG/CPLEX_Studio2211/cplex/bin/x86-64_linux/"		# (mettre le chemin ou cplex est installé)
Pkg.add("CPLEX")
Pkg.build("CPLEX")



Notice d'utilisation du programme : 
Tout d'abord, le programme vous demandera d'entrer le nom exact de l'instance avec laquelle vous voulez travailler, rentrez par exemple att48.tsp

Il affiche ensuite une explication de ce qu'est le problème et de ce que l'on cherche à faire. 
Vous pouvez appuyer sur entrée pour commencer.

Laissez vous ensuite guider par le programme qui vous demande de paramétrer quelle méthode de résolution vous souhaitez utiliser parmi celles disponibles. 

Vous pouvez ensuite voir vos historiques de solutions sur le terminal ainsi que plus précisément dans le fichier historique.txt dans le dossier txtFile.
Le graphique de la dernière méthode trouvée se trouve dans le dossier graphique et a pour nom sol.png. Il s'affiche automatiquement quand la solution est trouvée.
