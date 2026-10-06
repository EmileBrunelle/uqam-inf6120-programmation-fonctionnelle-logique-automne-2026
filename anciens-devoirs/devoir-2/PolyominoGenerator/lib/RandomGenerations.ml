(* Devoir 2 (INF6120, automne 2025) — solution d'entraînement.
   Auteur : Émile Brunelle — code permanent : à compléter.

   Partie 5 : génération aléatoire de polyominos par marche aléatoire. *)

(* Type et fonction imposés, recopiés tels quels (l'énoncé l'exige pour que
   les tests avec [Random.init] soient reproductibles). *)
type directions = Up | Down | Left | Right

(* « Retardateur » : le paramètre [()] retarde le tirage jusqu'à l'appel.
   Sans lui, [random_direction] serait UNE valeur tirée une seule fois au
   chargement du module. *)
let random_direction () =
  match Random.int 4 with 0 -> Up | 1 -> Down | 2 -> Left | _ -> Right

(* Voisine d'une case dans une direction : un filtrage sur la direction.
   Rappel de la convention : Up augmente l'ordonnée, Right l'abscisse. *)
let adjacent_square (Squares.Square (x, y) : Squares.squares) (dir : directions)
    : Squares.squares =
  match dir with
  | Up -> Squares.make x (y + 1)
  | Down -> Squares.make x (y - 1)
  | Left -> Squares.make (x - 1) y
  | Right -> Squares.make (x + 1) y

(* Marche aléatoire. L'état mutable de l'algorithme (case marquée,
   polyomino courant) devient deux PARAMÈTRES d'une fonction récursive
   terminale : c'est la traduction fonctionnelle d'une boucle « tant que ».
   À chaque pas : on tire UNE direction, on déplace la marque ; si la case
   atteinte est vide, on l'ajoute. Dans les deux cas, la marque reste sur
   la nouvelle case. Pas besoin de tester « remplie ? » : [add_square]
   renvoie le polyomino inchangé si la case y est déjà.
   Piège : les tests de l'énoncé ne passent que si on fait exactement un
   appel à [random_direction] par pas, dans cet ordre ; tirer en trop (ou
   repartir de l'origine après chaque ajout) change tous les dessins. *)
let build_random (n : int) : Polyominos.polyominos =
  let rec walk (marked : Squares.squares) (poly : Polyominos.polyominos) :
      Polyominos.polyominos =
    if Polyominos.area poly >= n then poly
    else
      let next = adjacent_square marked (random_direction ()) in
      walk next (Polyominos.add_square next poly)
  in
  walk Squares.origin Polyominos.origin
