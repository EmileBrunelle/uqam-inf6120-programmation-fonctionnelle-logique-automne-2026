(* Laboratoire 6 : théorèmes et révisions pour l'intra (résolution commentée).
   Les preuves sont dans `preuves.md`, les réponses théoriques dans le
   README. Ce fichier contient tout le code.

   ATTENTION : on redéfinit ici `append`, `rev`, `filter`, `fold_left`, etc.
   comme le demande l'énoncé ; dans ce module ils masquent ceux de la
   bibliothèque standard (qui vivent dans `List`). *)

(* ================= Théorèmes sur append / filter / fold ================= *)

(* Idée : on consomme la première liste ; la seconde est livrée telle quelle
   au bout. Cas de base : [] @ l2 = l2. Piège : la récursion est sur l1,
   jamais sur l2 (c'est pourquoi append xs [] = xs demande une preuve). *)
let rec append (l1 : 'a list) (l2 : 'a list) : 'a list =
  match l1 with [] -> l2 | head :: tail -> head :: append tail l2

(* Idée : inverser la queue, puis accrocher la tête à la fin. Cas de base :
   [] . Piège : O(n²) à cause de append ; la version efficace utilise un
   accumulateur (voir `length_terminale` pour le même truc). *)
let rec rev (l : 'a list) : 'a list =
  match l with [] -> [] | head :: tail -> append (rev tail) [ head ]

(* Idée : garder la tête seulement si le prédicat l'accepte. Cas de base :
   []. Piège : dans les DEUX branches on récurse sur `tail`. *)
let rec filter (p : 'a -> bool) (l : 'a list) : 'a list =
  match l with
  | [] -> []
  | head :: tail -> if p head then head :: filter p tail else filter p tail

(* Conjonction de deux prédicats : retourne un prédicat (fonction qui
   retourne une fonction). *)
let combine (f : 'a -> bool) (g : 'a -> bool) : 'a -> bool = fun x -> f x && g x

(* fold_left f acc [a; b; c] = f (f (f acc a) b) c : l'accumulateur avance
   de gauche à droite (récursive terminale). Cas de base : on rend acc. *)
let rec fold_left (f : 'b -> 'a -> 'b) (acc : 'b) (l : 'a list) : 'b =
  match l with [] -> acc | head :: tail -> fold_left f (f acc head) tail

(* fold_right f [a; b; c] init = f a (f b (f c init)) : on remplace `::`
   par f et `[]` par init. Pas terminale. Piège : l'ordre des arguments de
   f diffère de fold_left (élément en premier, accumulateur en second). *)
let rec fold_right (f : 'a -> 'b -> 'b) (l : 'a list) (init : 'b) : 'b =
  match l with [] -> init | head :: tail -> f head (fold_right f tail init)

(* Somme sans repli : 0 pour la liste vide. *)
let rec sum (l : int list) : int =
  match l with [] -> 0 | head :: tail -> head + sum tail

(* ================= Révisions pour l'intra ================= *)

(* ---- Shadowing ----
   À la ligne indiquée, le `x` de `x + 2` est le PARAMÈTRE de f (le x
   extérieur, lié à 1, est masqué), donc il vaut 1 à cet endroit, et le
   `let x = ...` qui suit lie un nouveau x = 3. Résultat de `f x` : 3. *)
let shadowing : int =
  let x = 1 in
  let f x =
    let x = x + 2 in
    x
  in
  f x

(* Même sémantique, chaque variable a son propre nom. *)
let shadowing_renomme : int =
  let x = 1 in
  let f y =
    let z = y + 2 in
    z
  in
  f x

(* ---- RLE (codage par plage) ----
   compress : 'a list -> (int * 'a) list
   decompress : (int * 'a) list -> 'a list *)

(* n copies de x (aide pour decompress). Cas de base : n <= 0 -> []. *)
let rec replicate (n : int) (x : 'a) : 'a list =
  if n <= 0 then [] else x :: replicate (n - 1) x

(* Idée : compresser la queue d'abord ; si son premier groupe porte le même
   élément que la tête, on l'allonge d'une unité, sinon on ouvre un groupe
   (1, tête). Cas de base : [] -> [].
   Piège : le `when` doit comparer le groupe de la queue avec la tête.

   Trace de compress [1; 1; 1; 2] (ATTENTION : `[1,1,1,2]` avec des
   virgules est une liste d'UN seul quadruplet, pas quatre entiers) :
   Évaluation, de l'intérieur vers l'extérieur :
     compress []        = []
     compress [2]       = (1,2) :: []                      (rien à fusionner)
     compress [1;2]     = (1,1) :: [(1,2)]                 (1 <> 2)
     compress [1;1;2]   = (2,1) :: [(1,2)]                 (1 = 1)
     compress [1;1;1;2] = (3,1) :: [(1,2)]                 (1 = 1) *)
let rec compress (l : 'a list) : (int * 'a) list =
  match l with
  | [] -> []
  | x :: tail -> (
      match compress tail with
      | (n, y) :: rest when y = x -> (n + 1, y) :: rest
      | groupes -> (1, x) :: groupes)

(* Idée : chaque groupe (n, x) redevient n copies de x. *)
let rec decompress (l : (int * 'a) list) : 'a list =
  match l with
  | [] -> []
  | (n, x) :: rest -> append (replicate n x) (decompress rest)

(* Propriété de correction : pour toute liste l, `decompress (compress l) = l`
   (aller-retour sans perte). Testée dans test_labo6.ml. Bonus : aucun
   groupe n'a de compteur nul et deux groupes voisins n'ont jamais le même
   élément. *)

(* Mêmes fonctions par repli : le cœur du `match` devient la fonction du
   repli, et [] devient la valeur initiale. *)
let compress_fold (l : 'a list) : (int * 'a) list =
  fold_right
    (fun x acc ->
      match acc with
      | (n, y) :: rest when y = x -> (n + 1, y) :: rest
      | _ -> (1, x) :: acc)
    l []

let decompress_fold (l : (int * 'a) list) : 'a list =
  fold_right (fun (n, x) acc -> append (replicate n x) acc) l []

(* ---- find ----
   find : ('a -> bool) -> 'a list -> 'a option
   Pas d'exception : `None` s'il n'y a aucun élément qui convient. *)
let rec find (p : 'a -> bool) (l : 'a list) : 'a option =
  match l with
  | [] -> None
  | head :: tail -> if p head then Some head else find p tail

(* ---- filter_map ----
   Applique f ; garde les `Some`, jette les `None`. Piège : le résultat
   est une liste de 'b, pas de 'b option. *)
let rec filter_map (f : 'a -> 'b option) (l : 'a list) : 'b list =
  match l with
  | [] -> []
  | head :: tail -> (
      match f head with
      | Some y -> y :: filter_map f tail
      | None -> filter_map f tail)

(* Exemple : racines carrées entières exactes des nombres qui sont des carrés
   parfaits (0, 1, 4, 9 -> 0, 1, 2, 3 ; 5 et 7 sont jetés). *)
let racine_exacte (n : int) : int option =
  let r : int = int_of_float (sqrt (float_of_int n)) in
  if r * r = n then Some r else None

let exemple_filter_map : int list =
  filter_map racine_exacte [ 0; 1; 5; 4; 7; 9 ]
(* = [0; 1; 2; 3] *)

(* ---- Listes associatives ---- *)
type ('a, 'b) dict = ('a * 'b) list

(* Première association trouvée (la plus récente masque les anciennes). *)
let rec lookup (k : 'a) (d : ('a, 'b) dict) : 'b option =
  match d with
  | [] -> None
  | (k', v) :: rest -> if k = k' then Some v else lookup k rest

(* On ajoute EN TÊTE : ainsi `lookup` voit la nouvelle valeur en premier. *)
let extend (k : 'a) (v : 'b) (d : ('a, 'b) dict) : ('a, 'b) dict = (k, v) :: d

(* Clé de la valeur maximale ; `None` si le dictionnaire est vide (il n'y a
   pas de maximum). Type : ('a, 'b) dict -> 'a option. Idée : on porte le
   meilleur couple vu jusqu'ici ; en cas d'égalité, la première clé gagne. *)
let dict_max (d : ('a, 'b) dict) : 'a option =
  let rec aux (meilleur : 'a * 'b) (d : ('a, 'b) dict) : 'a =
    match d with
    | [] -> fst meilleur
    | (k, v) :: rest ->
        if v > snd meilleur then aux (k, v) rest else aux meilleur rest
  in
  match d with [] -> None | premier :: rest -> Some (aux premier rest)

(* Type : ('a, 'b) dict -> 'b list. *)
let rec values (d : ('a, 'b) dict) : 'b list =
  match d with [] -> [] | (_, v) :: rest -> v :: values rest

(* Type : ('a, int) dict -> int. Réutilise `values` et `sum`. *)
let dict_sum (d : ('a, int) dict) : int = sum (values d)

(* ---- iterate ----
   iterate : ('a -> 'a) -> 'a -> 'a Seq.t
   Une `list` OCaml est toujours finie et construite d'avance : une liste
   « infinie » est donc une séquence paresseuse (Seq.t), dont la suite n'est
   calculée que sur demande (le `fun () -> ...`). Piège : sans la paresse,
   la fonction ne terminerait jamais. *)
let rec iterate (f : 'a -> 'a) (x : 'a) : 'a Seq.t =
 fun () -> Seq.Cons (x, iterate f (f x))

(* ---- Conversion ----
   convert : ('a -> 'c) -> ('b -> 'c) -> ('a, 'b) result list -> 'c list
   Applique f aux Ok, g aux Error : tout finit dans le même type 'c. *)
let rec convert (f : 'a -> 'c) (g : 'b -> 'c) (l : ('a, 'b) result list) :
    'c list =
  match l with
  | [] -> []
  | Ok a :: rest -> f a :: convert f g rest
  | Error b :: rest -> g b :: convert f g rest

(* Exemple : Ok 3 -> "3", Error "oups" -> "oups" donne ["3"; "oups"; "5"]. *)
let exemple_convert : string list =
  convert string_of_int (fun (s : string) -> s) [ Ok 3; Error "oups"; Ok 5 ]

(* ---- Définition de type : JSON ---- *)
type json =
  | JString of string
  | JNumber of float
  | JList of json list
  | JDict of (string * json) list

(* ["foo", 42, 1, 3] et {"clé1": "valeur1", "clé2": 10} *)
let exemple_json_liste : json =
  JList [ JString "foo"; JNumber 42.; JNumber 1.; JNumber 3. ]

let exemple_json_dict : json =
  JDict [ ("clé1", JString "valeur1"); ("clé2", JNumber 10.) ]

(* ================= Intra été 2024 ================= *)

(* Q2 : nombres de Stirling de seconde espèce. Un `if` par cas de la
   définition mathématique, dans l'ordre : (0,0) avant (0,k) et (n,0).
   Piège : S(0,0) = 1 mais S(n,0) = S(0,k) = 0 sinon. *)
let rec stirling (n : int) (k : int) : int =
  if n = 0 && k = 0 then 1
  else if n = 0 || k = 0 then 0
  else (k * stirling (n - 1) k) + stirling (n - 1) (k - 1)

(* Q3 : `function` n'a qu'un argument, donc on imbrique (curryfication). *)
let f_q3 : int -> int -> int = function x -> ( function y -> x + (2 * y))

(* Q4 : f 1 2 3 : x = 1 est masqué par le troisième paramètre (x = 3),
   y = 2, donc le résultat est (3, 2). *)
let q4 : int * int =
  let f = fun x -> fun y -> fun x -> (x, y) in
  f 1 2 3

(* Q5 : map (min 7) donne [1;...;7;7;7;7] (min plafonne à 7), filtré avec
   > 5 donne [6; 7; 7; 7; 7]. `minimum` = le `min` de l'énoncé. *)
let minimum (x : int) (y : int) : int = if x < y then x else y

let q5 : int list =
  List.filter
    (fun x -> x > 5)
    (List.map (minimum 7) [ 1; 2; 3; 4; 5; 6; 7; 8; 9; 10 ])

(* Q6 : `length` n'est pas récursive terminale : après l'appel récursif il
   reste `1 + ...` à faire, donc chaque élément empile un cadre sur la pile
   d'appels ; avec 500 000 éléments, la pile déborde (sur OCaml 4 ; sur
   OCaml 5 la pile est bien plus grande mais le principe reste).
   Trace de length [1; 2; 3] :
     length [1;2;3] = 1 + length [2;3]
                    = 1 + (1 + length [3])
                    = 1 + (1 + (1 + length []))
                    = 1 + (1 + (1 + 0)) = 3
   Remède : accumulateur ; le dernier geste est l'appel récursif, le
   compilateur le transforme en boucle. *)
let rec length (l : 'a list) : int =
  match l with [] -> 0 | _ :: t -> 1 + length t

let length_terminale (l : 'a list) : int =
  let rec aux (acc : int) (l : 'a list) : int =
    match l with [] -> acc | _ :: t -> aux (acc + 1) t
  in
  aux 0 l

(* Q7 : is_increasing : int list -> bool. On compare deux voisins à la fois
   (motif `x :: y :: _`) ; moins de deux éléments -> true. *)
let rec is_increasing (l : int list) : bool =
  match l with
  | x :: (y :: _ as tail) -> x < y && is_increasing tail
  | _ -> true

(* Q8 : système de fichiers. Chaque entrée a un nom, des permissions
   (une liste : plusieurs à la fois) et soit un contenu, soit des entrées. *)
type permission = Read | Write | Execute

type fs =
  | File of { name : string; permissions : permission list; content : string }
  | Dir of { name : string; permissions : permission list; entries : fs list }

let exemple_fs : fs =
  Dir
    {
      name = "racine";
      permissions = [ Read; Write; Execute ];
      entries =
        [
          File
            {
              name = "notes.txt";
              permissions = [ Read; Write ];
              content = "salut";
            };
          Dir { name = "vide"; permissions = [ Read ]; entries = [] };
          Dir
            {
              name = "bin";
              permissions = [ Read; Execute ];
              entries =
                [
                  File { name = "run"; permissions = [ Execute ]; content = "" };
                ];
            };
        ];
    }

(* Aide pour tester : nombre de fichiers réguliers, récursion mutuelle
   évitée grâce à fold_right sur la liste d'entrées. *)
let rec count_files (e : fs) : int =
  match e with
  | File _ -> 1
  | Dir { entries; _ } ->
      fold_right (fun x acc -> count_files x + acc) entries 0

(* Q9 : simplification d'expressions. On simplifie d'abord les enfants
   (bas en haut), puis on applique les règles à la racine. Un seul passage
   suffit : une règle rend soit un enfant déjà simplifié, soit une
   constante. Piège : `0 - n` ne vaut `-n` que pour une constante `Num n` ;
   `0 - x` reste tel quel. *)
type expr =
  | Plus of expr * expr
  | Minus of expr * expr
  | Times of expr * expr
  | Divide of expr * expr
  | Num of int

let rec simplify (e : expr) : expr =
  match e with
  | Num _ -> e
  | Plus (a, b) -> (
      match (simplify a, simplify b) with
      | Num 0, x | x, Num 0 -> x
      | a', b' -> Plus (a', b'))
  | Minus (a, b) -> (
      match (simplify a, simplify b) with
      | Num 0, Num n -> Num (-n)
      | x, Num 0 -> x
      | a', b' -> Minus (a', b'))
  | Times (a, b) -> (
      match (simplify a, simplify b) with
      | Num 1, x | x, Num 1 -> x
      | a', b' -> Times (a', b'))
  | Divide (a, b) -> (
      match (simplify a, simplify b) with
      | x, Num 1 -> x
      | a', b' -> Divide (a', b'))

(* Q10 : occurrences. count : 'a -> 'a list -> int. *)
let rec count (x : 'a) (l : 'a list) : int =
  match l with
  | [] -> 0
  | head :: tail -> (if head = x then 1 else 0) + count x tail

let count_fold (x : 'a) (l : 'a list) : int =
  fold_left (fun acc y -> if y = x then acc + 1 else acc) 0 l

(* Q11 : Tsil, une liste « à l'envers » (dernier élément en tête de
   structure). Snoc (préfixe, dernier). Piège : le `length` et le `map`
   récursent sur le PRÉFIXE ; map garde l'ordre (f x s'applique au dernier
   élément, le préfixe est transformé récursivement). *)
module type TSIL = sig
  type 'a t = Nil | Snoc of 'a t * 'a

  val nil : 'a t
  val snoc : 'a t -> 'a -> 'a t
  val length : 'a t -> int
  val map : ('a -> 'b) -> 'a t -> 'b t
end

module Tsil : TSIL = struct
  type 'a t = Nil | Snoc of 'a t * 'a

  let nil : 'a t = Nil
  let snoc (t : 'a t) (x : 'a) : 'a t = Snoc (t, x)

  let rec length (t : 'a t) : int =
    match t with Nil -> 0 | Snoc (prefixe, _) -> 1 + length prefixe

  let rec map (f : 'a -> 'b) (t : 'a t) : 'b t =
    match t with Nil -> Nil | Snoc (prefixe, x) -> Snoc (map f prefixe, f x)
end

(* Q12 : la fonction à prouver (preuve dans preuves.md). *)
let rec exp (x : int) (n : int) : int = if n = 0 then 1 else x * exp x (n - 1)
