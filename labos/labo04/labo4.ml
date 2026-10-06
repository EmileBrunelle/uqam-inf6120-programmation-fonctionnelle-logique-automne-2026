(* Laboratoire 04 : fonctions d'ordre supérieur.

   Une fonction est une valeur : on peut la passer en argument, la renvoyer,
   l'appliquer partiellement (curryfication : `f a b` = `(f a) b`). *)

exception EmptyList

let square (x : int) : int = x * x
let my_list : int list = [ 3; 12; 3; 40; 6; 4; 6; 0 ]

(* ---------- Premières fonctions d'ordre supérieur ---------- *)

(* Type : ('a -> int) -> 'a -> 'a -> int. Piège : f doit rendre un int
   (à cause du +), mais son argument peut être de n'importe quel type. *)
let f_sum (f : 'a -> int) (a : 'a) (b : 'a) : int = f a + f b

(* Même chose avec `function` seulement : une fonction à un argument par
   `function`, donc trois imbriquées (`fun x y` = `function x -> function y`). *)
let f_sum_function : ('a -> int) -> 'a -> 'a -> int = function
  | f -> ( function a -> ( function b -> f a + f b))

(* Chaque annotation de type détermine le corps : lire la flèche de gauche
   à droite, un paramètre par flèche au premier niveau. *)
let f1 : int -> int -> int = fun a b -> a + b
let f2 : (int -> int) -> int = fun f -> f 0
let f3 : (int -> int) -> int -> int = fun f x -> f x

(* Piège : f4 renvoie une fonction ; `int -> int` à droite est entre
   parenthèses mais c'est la même chose que ... -> int -> int. *)
let f4 : (int -> int) -> int -> int = fun f x -> f (f x)

(* f5 reçoit une fonction qui elle-même reçoit une fonction. *)
let f5 : ((int -> int) -> int) -> int = fun g -> g (fun x -> x + 1)

(* Application partielle de `square` à List.map. *)
let squares : int list = List.map square my_list

(* L'opérateur de multiplication en fonction s'écrit avec des espaces
   (parenthèse, étoile, parenthèse), sinon c'est un commentaire.
   La fonction obtenue appliquée à 2 est la fonction « multiplier par 2 » (application partielle). *)
let doubles : int list = List.map (( * ) 2) my_list

(* Type : (unit -> 'a) -> int -> 'a list.
   Piège : `let x = make () in` impose l'ordre des appels (important avec
   des effets comme Random) ; n <= 0 donne []. *)
let rec make_list (make : unit -> 'a) (n : int) : 'a list =
  if n <= 0 then []
  else
    let x = make () in
    x :: make_list make (n - 1)

let random_bools : bool list = make_list Random.bool 64
let random_ints : int list = make_list (fun () -> Random.int 128) 16

(* ---------- Sur une ligne ---------- *)

let entiers : int list = [ 2; 5; 7; 3; 12; 4; 9; 2; 11 ]

let animaux : string list =
  [
    "Wombat";
    "aXolotl";
    "pangolin";
    "suricate";
    "paresseuX";
    "quokka";
    "lemurien";
  ]

let longueurs : int list = List.map String.length animaux
let majuscules : string list = List.map String.uppercase_ascii animaux

(* Une chaîne est en minuscules si elle égale sa version en minuscules. *)
(* Piège : « quokka » est aussi en minuscules (absent de l'exemple de l'énoncé). *)
let en_minuscules : string list =
  List.filter (fun s -> String.equal (String.lowercase_ascii s) s) animaux

let longueur_paire : string list =
  List.filter (fun s -> String.length s mod 2 = 0) animaux

let pair_impair : (int * string) list =
  List.map (fun x -> (x, if x mod 2 = 0 then "pair" else "impair")) entiers

(* `make_list` n'est pas « une nouvelle fonction » : on l'utilise. *)
let n_fois_n : int list list =
  List.map (fun x -> make_list (fun () -> x) x) entiers

let commence_par_s : bool = List.exists (fun s -> s.[0] = 's') animaux

(* Piège : « congru à 2 modulo 5 » = longueur mod 5 = 2 (faux ici). *)
let tous_2_mod_5 : bool =
  List.for_all (fun s -> String.length s mod 5 = 2) animaux

(* ---------- Replis ---------- *)

(* Idée de fold_left f init l : f (... (f (f init x1) x2) ...) xn. L'accumulateur
   résume ce qu'on a déjà vu ; choisir init = le résultat sur la liste vide. *)
let sum (l : int list) : int = List.fold_left ( + ) 0 l
let size (l : 'a list) : int = List.fold_left (fun n _ -> n + 1) 0 l

(* Le dernier élément écrase l'accumulateur à chaque tour. Piège : vide -> exception. *)
let last (l : 'a list) : 'a =
  match l with
  | [] -> raise EmptyList
  | x :: t -> List.fold_left (fun _ y -> y) x t

let nb_occ (e : 'a) (l : 'a list) : int =
  List.fold_left (fun n x -> if x = e then n + 1 else n) 0 l

let max_list (l : int list) : int =
  match l with [] -> raise EmptyList | x :: t -> List.fold_left max x t

(* Un seul repli sur le couple (somme, taille) : sans sum ni size. *)
let average (l : int list) : float =
  let s, n = List.fold_left (fun (s, n) x -> (s + x, n + 1)) (0, 0) l in
  float_of_int s /. float_of_int n

(* ---------- Prédicats ---------- *)

(* Base : [] -> true (« tous » sur rien est vrai). `&&` court-circuite. *)
let rec my_for_all (p : 'a -> bool) (l : 'a list) : bool =
  match l with [] -> true | x :: t -> p x && my_for_all p t

let my_for_all2 (p : 'a -> bool) (l : 'a list) : bool =
  List.fold_left (fun acc x -> acc && p x) true l

(* fold_right : f x1 (f x2 (... (f xn init))) ; ici l'accumulateur est à droite. *)
let my_for_all3 (p : 'a -> bool) (l : 'a list) : bool =
  List.fold_right (fun x acc -> p x && acc) l true

(* Base : [] -> false (aucun témoin). *)
let rec my_exists (p : 'a -> bool) (l : 'a list) : bool =
  match l with [] -> false | x :: t -> p x || my_exists p t

(* Dualité : none = pas d'élément qui vérifie p. *)
let rec none (p : 'a -> bool) (l : 'a list) : bool =
  match l with [] -> true | x :: t -> (not (p x)) && none p t

(* not_all = il existe un élément qui NE vérifie PAS p. *)
let rec not_all (p : 'a -> bool) (l : 'a list) : bool =
  match l with [] -> false | x :: t -> (not (p x)) || not_all p t

(* Idée : p sur chaque paire de voisins. Base : [] et singleton -> vrai
   (aucune paire à tester). *)
let rec ordered (p : 'a -> 'a -> bool) (l : 'a list) : bool =
  match l with x :: (y :: _ as t) -> p x y && ordered p t | _ -> true

(* Idée : avancer sur les deux listes ensemble ; garder le couple si p le
   valide. Base : l'une des deux vide -> []. *)
let rec filter2 (p : 'a -> 'b -> bool) (l1 : 'a list) (l2 : 'b list) :
    ('a * 'b) list =
  match (l1, l2) with
  | x :: t1, y :: t2 ->
      if p x y then (x, y) :: filter2 p t1 t2 else filter2 p t1 t2
  | _ -> []

(* ---------- Permutations ---------- *)

(* `insere x l` : toutes les façons d'insérer x dans l.
   insere 1 [2; 3] = [[1;2;3]; [2;1;3]; [2;3;1]]. *)
let rec insere (x : 'a) (l : 'a list) : 'a list list =
  match l with
  | [] -> [ [ x ] ]
  | y :: t -> (x :: l) :: List.map (fun r -> y :: r) (insere x t)

(* Idée : permutations de (x :: t) = x inséré partout dans chaque
   permutation de t. Base : [] a UNE permutation, la liste vide (pas zéro). *)
let rec perm (l : 'a list) : 'a list list =
  match l with [] -> [ [] ] | x :: t -> List.concat_map (insere x) (perm t)
