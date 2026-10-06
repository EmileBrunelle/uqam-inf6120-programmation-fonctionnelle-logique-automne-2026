(* Devoir 1 INF6120 (entraînement) — Émile Brunelle, code permanent à compléter
   Q9.1 : dune exec CellularAutomata -- <début> <fin> <n>
   Affiche n évolutions de Sierpinski (1 en case 0), « . » pour 0, « * »
   pour 1. *)

open Cellular_automata

(* Convertit une case de Sierpinski en caractère affichable. *)
let cell_to_string (x : int) : string = if x = 0 then "." else "*"

(* Sys.argv contient le nom du programme puis les arguments. On le
   convertit en liste pour filtrer par motif sur sa forme exacte ;
   int_of_string_opt évite l'exception sur un argument non entier.
   Piège : oublier le nom du programme en tête (d'où le premier _). *)
let () =
  match List.map int_of_string_opt (Array.to_list Sys.argv) with
  | [ _; Some start; Some stop; Some n ] ->
      let aut = Automata.set_value Examples.sierpinski 0 1 in
      Evolutions.string_representation aut (start, stop) n cell_to_string
      |> print_endline
  | _ ->
      prerr_endline "Usage : CellularAutomata <début> <fin> <itérations>";
      exit 1
