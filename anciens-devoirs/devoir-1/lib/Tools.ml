(* Devoir 1 INF6120 (entraînement) — Émile Brunelle, code permanent à compléter
   Partie 3 : fonctions outils sur les listes. *)

(* Q3.1 — [interval a b] = [a; a + 1; ...; b], vide si a > b.
   Idée : List.init n g construit [g 0; ...; g (n - 1)] ; ici g = (+) a.
   Cas de base : a > b donne une longueur négative, d'où le [max 0 ...].
   Piège : List.init lève Invalid_argument sur une longueur négative ;
   sans le max, [interval 9 3] plante au lieu de renvoyer []. *)
let interval (a : int) (b : int) : int list =
  List.init (max 0 (b - a + 1)) (( + ) a)

(* Q3.2 — Concatène les images par [f] des éléments de [lst].
   Idée : map puis concaténation avec un séparateur vide.
   Cas de base : la liste vide donne "".
   Piège : faire un fold_left avec ( ^ ) marche aussi, mais recopie
   la chaîne à chaque étape (quadratique) ; String.concat est linéaire. *)
let list_to_string (f : 'a -> string) (lst : 'a list) : string =
  String.concat "" (List.map f lst)

(* Q3.3 — [x; f x; f (f x); ...] de longueur n + 1.
   Idée : la tête est x, la queue est la même liste à partir de f x
   avec un élément de moins.
   Cas de base : n = 0 donne [x] (la composée 0-ième est l'identité).
   Piège : écrire « if n < 0 then [] » applique f une fois de trop
   (OCaml évalue l'argument f x avant l'appel) ; coûteux si f est lourde. *)
let rec compose_iter (f : 'a -> 'a) (x : 'a) (n : int) : 'a list =
  if n <= 0 then [ x ] else x :: compose_iter f (f x) (n - 1)

(* Q3.4 — [u] est-il un préfixe de [v] ?
   Idée : filtrer sur le couple (u, v) et avancer des deux côtés tant que
   les têtes sont égales.
   Cas de base : u vide → vrai (même si v est vide) ; v vide et u non vide
   → faux.
   Piège : l'ordre des cas — ([], []) doit tomber dans le premier cas. *)
let rec is_prefix_lists (u : 'a list) (v : 'a list) : bool =
  match (u, v) with
  | [], _ -> true
  | _, [] -> false
  | a :: u', b :: v' -> a = b && is_prefix_lists u' v'

(* Q3.5 — [u] est-il un facteur (bloc contigu) de [v] ?
   Idée : un facteur de v est un préfixe d'un suffixe de v ; on essaie
   chaque suffixe en retirant la tête de v.
   Cas de base : v vide → u doit être vide (le test de préfixe le règle).
   Piège : oublier de tester le préfixe AVANT d'avancer, ce qui ferait
   échouer [is_factor_lists [] []]. *)
let rec is_factor_lists (u : 'a list) (v : 'a list) : bool =
  is_prefix_lists u v
  || match v with [] -> false | _ :: v' -> is_factor_lists u v'

(* Q3.6 — [u] est-il un sous-mot de [v] (éléments dans l'ordre, pas
   forcément contigus) ?
   Idée gloutonne : si les têtes coïncident, on consomme les deux ;
   sinon on saute la tête de v seulement.
   Cas de base : u vide → vrai ; v vide et u non vide → faux.
   Piège : le glouton est correct ici (prendre la première occurrence
   possible ne fait jamais perdre de solution) ; inutile d'essayer les
   deux branches, ce qui serait exponentiel. *)
let rec is_subword_lists (u : 'a list) (v : 'a list) : bool =
  match (u, v) with
  | [], _ -> true
  | _, [] -> false
  | a :: u', b :: v' when a = b -> is_subword_lists u' v'
  | _, _ :: v' -> is_subword_lists u v'

(* Q3.7 — Chaque élément apparaît-il une seule fois ?
   Idée : la tête ne doit pas réapparaître dans la queue, et la queue
   doit elle-même être sans doublon.
   Cas de base : [] est sans doublon.
   Piège : quadratique (List.mem sur chaque queue) — acceptable ici ;
   trier puis comparer les voisins serait en n log n. *)
let rec is_duplicate_free (lst : 'a list) : bool =
  match lst with
  | [] -> true
  | x :: rest -> (not (List.mem x rest)) && is_duplicate_free rest
