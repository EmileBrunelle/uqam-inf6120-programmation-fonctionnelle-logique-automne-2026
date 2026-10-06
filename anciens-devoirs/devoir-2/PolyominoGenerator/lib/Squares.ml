(* Devoir 2 (INF6120, automne 2025) — solution d'entraînement.
   Auteur : Émile Brunelle — code permanent : à compléter.

   Partie 3 : les cases du plan discret Z × Z. *)

(* Type imposé : un constructeur unique autour d'un couple. L'intérêt est
   que les signatures disent [squares] et non [int * int] ; le prix est
   qu'il faut filtrer (pattern matching) pour lire les coordonnées. *)
type squares = Square of (int * int)

(* [make x y] : la case (x, y). Simple application du constructeur.
   Piège : [Square x y] ne compile pas, le constructeur prend UN couple. *)
let make (x : int) (y : int) : squares = Square (x, y)

(* La case (0, 0). Une constante, pas une fonction : pas de [()]. *)
let origin : squares = make 0 0

(* Abscisse d'une case. Le filtrage se fait directement dans le paramètre :
   avec un seul constructeur, le motif est exhaustif, donc aucun warning. *)
let x_coordinate (Square (x, _) : squares) : int = x

(* Ordonnée d'une case, même idée que [x_coordinate]. *)
let y_coordinate (Square (_, y) : squares) : int = y
