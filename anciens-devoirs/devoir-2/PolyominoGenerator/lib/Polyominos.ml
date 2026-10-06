(* Devoir 2 (INF6120, automne 2025) — solution d'entraînement.
   Auteur : Émile Brunelle — code permanent : à compléter.

   Partie 4 : les polyominos, ensembles finis de cases. *)

(* Type imposé. Invariant à maintenir PARTOUT : la liste est triée
   (abscisse, puis ordonnée) et sans doublon. Toute fonction qui construit
   un polyomino passe donc par [make], seul endroit qui rétablit
   l'invariant. *)
type polyominos = Polyomino of Squares.squares list

(* [make sq_lst] : trie et retire les doublons avec [List.sort_uniq].
   L'idée : [compare] polymorphe compare [Square (x, y)] comme le couple
   [(x, y)], donc lexicographiquement — exactement l'ordre exigé.
   Piège : [List.sort] seul garde les doublons. *)
let make (sq_lst : Squares.squares list) : polyominos =
  Polyomino (List.sort_uniq compare sq_lst)

(* Le polyomino réduit à la case origine. *)
let origin : polyominos = make [ Squares.origin ]

(* Les cases d'un polyomino : on retire l'emballage du constructeur. *)
let squares (Polyomino sq_lst : polyominos) : Squares.squares list = sq_lst

(* Appartenance : [List.mem] utilise l'égalité structurelle [=].
   Piège : [==] (égalité physique) répondrait faux pour une case
   reconstruite avec [Squares.make]. *)
let is_filled_square (sq : Squares.squares) (poly : polyominos) : bool =
  List.mem sq (squares poly)

(* L'aire est le nombre de cases ; l'invariant « sans doublon » rend ce
   [List.length] correct. *)
let area (poly : polyominos) : int = List.length (squares poly)

(* Ajout d'une case : on la met en tête et [make] retrie et dédoublonne.
   Si la case est déjà là, [sort_uniq] la retire : on retrouve [poly]. *)
let add_square (sq : Squares.squares) (poly : polyominos) : polyominos =
  make (sq :: squares poly)

(* Rectangle englobant : un [fold_left] qui fait grandir un rectangle
   (coin bas-gauche, coin haut-droit) case par case, en partant de la
   première case. Le cas vide est traité à part, d'où l'option.
   Piège : la liste est triée par abscisse, donc la première et la dernière
   case donnent bien x min et x max, mais PAS y min et y max. *)
let bounding_box (poly : polyominos) :
    (Squares.squares * Squares.squares) option =
  let grow
      ((Squares.Square (x_min, y_min), Squares.Square (x_max, y_max)) :
        Squares.squares * Squares.squares)
      (Squares.Square (x, y) : Squares.squares) :
      Squares.squares * Squares.squares =
    ( Squares.make (min x_min x) (min y_min y),
      Squares.make (max x_max x) (max y_max y) )
  in
  match squares poly with
  | [] -> None
  | sq :: rest -> Some (List.fold_left grow (sq, sq) rest)

(* Entiers de [a] à [b] inclus ([[]] si [a > b]). *)
let range (a : int) (b : int) : int list =
  List.init (max 0 (b - a + 1)) (fun i -> a + i)

(* Dessin : une ligne par ordonnée, de la plus GRANDE à la plus petite
   (le haut du dessin est le haut du plan), et dans chaque ligne les
   abscisses croissantes. Pas de boucle : [range] + [List.map] +
   [String.concat].
   Piège : « · » est un caractère UTF-8 sur deux octets ; c'est une
   [string], pas un [char]. *)
let to_string (poly : polyominos) : string =
  let symbol (sq : Squares.squares) : string =
    if not (is_filled_square sq poly) then "·"
    else if sq = Squares.origin then "X"
    else "O"
  in
  match bounding_box poly with
  | None -> ""
  | Some (Squares.Square (x_min, y_min), Squares.Square (x_max, y_max)) ->
      let line (y : int) : string =
        range x_min x_max
        |> List.map (fun x -> symbol (Squares.make x y))
        |> String.concat ""
      in
      range y_min y_max |> List.rev |> List.map line |> String.concat "\n"

(* Version Prolog : le dessin en commentaire, puis un fait par case dans
   l'ordre du polyomino (déjà trié grâce à l'invariant).
   Piège : pas de « \n » final, [print_endline] l'ajoute. *)
let to_prolog (poly : polyominos) : string =
  let fact (Squares.Square (x, y) : Squares.squares) : string =
    Printf.sprintf "filled(square(%d, %d))." x y
  in
  "/*\n" ^ to_string poly ^ "\n*/\n\n"
  ^ String.concat "\n" (List.map fact (squares poly))
