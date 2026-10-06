(* Devoir 1 INF6120 (entraînement) — Émile Brunelle, code permanent à compléter
   Partie 6 (suite) et Q8.2 : évolution des automates. *)

open Automata

(* Q6.4 et Q8.2 — Une étape d'évolution.
   Idée : la nouvelle case i vaut evol (ancienne i - 1, ancienne i,
   ancienne i + 1). Comme pour set_value, on ne calcule rien : on
   construit une fonction (calcul retardé).
   Q8.2 : on lit l'ancien ruban à travers [Memoization.memo], de sorte
   que chaque case de l'ancien automate n'est calculée qu'une fois, même
   si trois cases voisines du nouveau la demandent. En chaînant les
   évolutions, chaque niveau a sa propre table : le coût passe
   d'exponentiel à polynomial (voir Memoization.ml, Q8.1).
   Piège : appeler [Memoization.memo] HORS de la fermeture (fun i -> ...),
   une seule fois par évolution ; placé dedans, la table serait recréée à
   chaque lecture et la mémoïsation ne servirait à rien. *)
let evolution (aut : 'a automata) : 'a automata =
  let old = Memoization.memo (get_value aut) in
  { aut with ribbon = (fun i -> evol aut (old (i - 1), old i, old (i + 1))) }

(* Q6.5 — [aut; evolution aut; evolution (evolution aut); ...], n + 1
   automates. C'est exactement compose_iter appliqué à evolution :
   réutiliser l'outil plutôt que réécrire la récursion. *)
let evolutions (aut : 'a automata) (n : int) : 'a automata list =
  Tools.compose_iter evolution aut n

(* Q6.6 — Pour chaque automate de la suite, le contenu de la portion. *)
let evolutions_bunch (aut : 'a automata) (b : Bunches.bunches) (n : int) :
    'a list list =
  List.map (fun a -> Bunches.get_bunch_values a b) (evolutions aut n)

(* Q6.7 — Une ligne par évolution, séparées par des sauts de ligne.
   Piège : String.concat met le séparateur ENTRE les lignes ; pas de "\n"
   final, c'est print_endline qui l'ajoute. *)
let string_representation (aut : 'a automata) (b : Bunches.bunches) (n : int)
    (val_to_string : 'a -> string) : string =
  evolutions_bunch aut b n
  |> List.map (Tools.list_to_string val_to_string)
  |> String.concat "\n"

(* Q6.8 — La portion revient-elle à un contenu déjà vu en au plus n
   évolutions ?
   Idée : « il existe k ≠ k' avec des contenus identiques » est exactement
   « la liste des contenus contient un doublon ».
   Piège : ne pas confondre avec « la portion revient à son état initial » ;
   deux états intermédiaires identiques suffisent. *)
let is_resurgent (aut : 'a automata) (b : Bunches.bunches) (n : int) : bool =
  not (Tools.is_duplicate_free (evolutions_bunch aut b n))
