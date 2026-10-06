(* Devoir 1 INF6120 (entraînement) — Émile Brunelle, code permanent à compléter
   Partie 5 : portions de rubans.

   Toutes les fonctions se ramènent à « extraire la portion en liste », puis
   réutilisent les outils de Tools : c'est la réutilisation que le barème
   valorise. *)

open Automata

type bunches = int * int

(* Q5.1 — Valeurs du ruban de [start] à [stop] inclus.
   Idée : map de get_value sur la liste des indices.
   Piège : la déconstruction du couple directement dans le paramètre,
   ((start, stop) : bunches), évite un match inutile. *)
let get_bunch_values (aut : 'a automata) ((start, stop) : bunches) : 'a list =
  List.map (get_value aut) (Tools.interval start stop)

(* Q5.2 — La portion en chaîne, chaque case convertie par [f]. *)
let to_string (aut : 'a automata) (b : bunches) (f : 'a -> string) : string =
  Tools.list_to_string f (get_bunch_values aut b)

(* Q5.3 — La portion contient-elle [lst] comme facteur ?
   Piège : l'ordre des arguments de is_factor_lists (le motif cherché
   d'abord, la liste où chercher ensuite). *)
let has_factor (aut : 'a automata) (b : bunches) (lst : 'a list) : bool =
  Tools.is_factor_lists lst (get_bunch_values aut b)

(* Q5.4 — La portion contient-elle [lst] comme sous-mot ? *)
let has_subword (aut : 'a automata) (b : bunches) (lst : 'a list) : bool =
  Tools.is_subword_lists lst (get_bunch_values aut b)
