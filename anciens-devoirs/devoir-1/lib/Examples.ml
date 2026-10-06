(* Devoir 1 INF6120 (entraînement) — Émile Brunelle, code permanent à compléter
   Partie 7 : constructions d'automates. *)

open Automata

(* Q7.1 — Automate de Sierpinski : f(a, b, c) = (a + b + c) mod 2, vide 0.
   Le motif fun (a, b, c) -> ... déconstruit le triplet directement. *)
let sierpinski : int automata = create (fun (a, b, c) -> (a + b + c) mod 2) 0

(* Q7.2 — Type somme des deux couleurs. *)
type wb = White | Black

(* Fonction d'évolution de l'automate chaotique (règle 30 de Wolfram).
   Idée : au lieu d'écrire les 8 lignes du tableau, on regroupe les 4 cas
   qui donnent Black ; tout le reste donne White.
   (White, Black, _) couvre d'un coup WBB et WBW.
   Piège : avec un cas attrape-tout, le compilateur ne vérifie plus
   l'exhaustivité ; il faut s'assurer à la main que les cas listés sont
   exactement ceux du tableau. *)
let chaos_evol (triple : wb * wb * wb) : wb =
  match triple with
  | Black, White, White | White, Black, _ | White, White, Black -> Black
  | _ -> White

(* Q7.2 — L'automate chaotique, vide White. *)
let chaos : wb automata = create chaos_evol White
