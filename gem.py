import math
import numpy as np
import matplotlib.pyplot as plt

def lire_tsp_file(filename):
    """
    Lit un fichier au format TSPLIB (comme att48.tsp).
    On cherche la section NODE_COORD_SECTION et on lit les coord x y.
    """
    coords = []
    start_reading = False
    
    with open(filename, 'r') as f:
        lines = f.readlines()
        
    for line in lines:
        line = line.strip()
        
        # Arrêter si on atteint la fin
        if line == 'TOUR_SECTION':
            break
            
        # Repérer le début des données
        if line.startswith('NODE_COORD_SECTION'):
            start_reading = True
            continue
            
        if start_reading:
            parts = line.split()
            # Le format est généralement : ID X Y
            if len(parts) >= 3:
                # On prend X et Y (indices 1 et 2), on ignore l'ID (indice 0)
                # On convertit en float pour le calcul
                x = float(parts[1])
                y = float(parts[2])
                coords.append([x, y])
                
    return np.array(coords)

def distance_euclidienne(p1, p2):
    """Calcule la distance euclidienne entre deux points[cite: 25]."""
    return np.sqrt(np.sum((p1 - p2)**2))

def heuristique_gloutonne_p_median(points, p):
    """
    Implémente l'heuristique gloutonne basée sur une grille[cite: 67].
    
    Args:
        points (np.array): Tableau numpy (n, 2) des coordonnées.
        p (int): Nombre de stations (médians) à sélectionner.
    """
    n = len(points)
    
    # 1. Repérage des dimensions Min/Max [cite: 66]
    x_min, y_min = np.min(points, axis=0)
    x_max, y_max = np.max(points, axis=0)
    
    epsilon = 1e-9
    width = (x_max - x_min) + epsilon
    height = (y_max - y_min) + epsilon

    # 2. Diviser le plan en q x q rectangles [cite: 67]
    q = math.ceil(math.sqrt(p))
    dx = width / q
    dy = height / q
    
    candidats = set()
    grid_lines = {'x': [x_min + i*dx for i in range(q+1)], 
                  'y': [y_min + i*dy for i in range(q+1)]}

    # 3. Pour chaque rectangle, chercher le point le plus proche du centre [cite: 68]
    for i in range(q):
        for j in range(q):
            rect_x_center = x_min + (i + 0.5) * dx
            rect_y_center = y_min + (j + 0.5) * dy
            center_geo = np.array([rect_x_center, rect_y_center])
            
            x_cond = (points[:, 0] >= x_min + i*dx) & (points[:, 0] < x_min + (i+1)*dx)
            y_cond = (points[:, 1] >= y_min + j*dy) & (points[:, 1] < y_min + (j+1)*dy)
            
            indices_in_rect = np.where(x_cond & y_cond)[0]
            
            if len(indices_in_rect) > 0:
                best_idx = -1
                min_dist_center = float('inf')
                for idx in indices_in_rect:
                    d = distance_euclidienne(points[idx], center_geo)
                    if d < min_dist_center:
                        min_dist_center = d
                        best_idx = idx
                if best_idx != -1:
                    candidats.add(best_idx)

    # Contrainte : Le sommet 1 (index 0) est TOUJOURS une station [cite: 53]
    candidats.add(0) 

    # 4. Ajustement pour avoir exactement p médians [cite: 69]
    list_candidats = list(candidats)
    
    # Cas A : Trop de candidats -> On retire les paires trop proches
    while len(list_candidats) > p:
        min_dist_pair = float('inf')
        pair_to_merge = (-1, -1)
        
        for i in range(len(list_candidats)):
            u = list_candidats[i]
            if u == 0: continue # On protège le sommet 1
            for j in range(i + 1, len(list_candidats)):
                v = list_candidats[j]
                if v == 0: continue # On protège le sommet 1
                
                d = distance_euclidienne(points[u], points[v])
                if d < min_dist_pair:
                    min_dist_pair = d
                    pair_to_merge = (u, v)
        
        if pair_to_merge != (-1, -1):
            list_candidats.remove(pair_to_merge[1])
        else:
            list_candidats.pop() 

    # Cas B : Pas assez de candidats -> On ajoute les isolés
    while len(list_candidats) < p:
        max_dist_to_medians = -1
        best_new_candidate = -1
        candidates_set = set(list_candidats)
        for i in range(n):
            if i not in candidates_set:
                d_min = min([distance_euclidienne(points[i], points[m]) for m in list_candidats])
                if d_min > max_dist_to_medians:
                    max_dist_to_medians = d_min
                    best_new_candidate = i
        if best_new_candidate != -1:
            list_candidats.append(best_new_candidate)
        else:
            break

    medians = list_candidats

    # 5. Affectation au plus proche [cite: 70]
    assignments = {}
    total_cost = 0.0
    
    for i in range(n):
        if i in medians:
            assignments[i] = i
        else:
            closest_m = -1
            min_dist = float('inf')
            for m in medians:
                d = distance_euclidienne(points[i], points[m])
                if d < min_dist:
                    min_dist = d
                    closest_m = m
            assignments[i] = closest_m
            total_cost += min_dist

    return medians, assignments, total_cost, grid_lines

def visualiser_resultat(points, medians, assignments, grid_lines, p):
    """Visualisation adaptée pour le rendu."""
    plt.figure(figsize=(10, 8))
    
    # Tracer la grille
    for gx in grid_lines['x']:
        plt.axvline(gx, color='gray', linestyle='--', alpha=0.3)
    for gy in grid_lines['y']:
        plt.axhline(gy, color='gray', linestyle='--', alpha=0.3)
        
    # Tracer les affectations
    for i, m in assignments.items():
        if i != m and isinstance(i, int): # check simple
            plt.plot([points[i][0], points[m][0]], 
                     [points[i][1], points[m][1]], 
                     'k--', alpha=0.2, linewidth=0.8)

    non_medians = [i for i in range(len(points)) if i not in medians]
    plt.scatter(points[non_medians, 0], points[non_medians, 1], c='blue', s=30, label='Zones')
    plt.scatter(points[medians, 0], points[medians, 1], c='red', s=100, marker='*', label='Stations')
    plt.scatter(points[0, 0], points[0, 1], c='yellow', edgecolors='black', s=120, label='Dépôt (Sommet 1)')

    plt.title(f"Heuristique Gloutonne (att48) - p={p} stations")
    plt.legend()
    # Inverser Y pour que la carte ressemble aux USA si c'est att48 (convention visuelle)
    # plt.gca().invert_yaxis() 
    plt.axis('equal')
    plt.show()

# --- MAIN ---
if __name__ == "__main__":
    nom_fichier = "att48.tsp"
    
    try:
        print(f"Lecture du fichier {nom_fichier}...")
        coords = lire_tsp_file(nom_fichier)
        print(f"Chargé {len(coords)} points.")
        
        # Test avec p=10 stations par exemple
        p_stations = 10
        
        print(f"Calcul des {p_stations} stations (p-médian)...")
        stations_choisies, affectations, cout, grid = heuristique_gloutonne_p_median(coords, p_stations)
        
        print(f"Stations choisies (indices): {stations_choisies}")
        print(f"Coût total (distances affectations): {cout:.2f}")
        
        visualiser_resultat(coords, stations_choisies, affectations, grid, p_stations)
        
    except FileNotFoundError:
        print(f"ERREUR: Le fichier '{nom_fichier}' est introuvable.")
        print("Vérifiez qu'il est bien dans le même dossier que ce script.")
    except Exception as e:
        print(f"Une erreur est survenue : {e}")