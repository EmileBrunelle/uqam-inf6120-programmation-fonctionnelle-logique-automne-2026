(* Laboratoire 03 : filtrage par motif, types algébriques et listes.

   Règle d'or des listes : `[]` est le cas de base, `x :: t` le cas
   récursif. Presque tout se fait avec un `match` à ces deux branches. *)

(* ---------- 1.1 Cartes ---------- *)

type suit = Heart | Diamond | Club | Spade
type rank = Num of int | Jack | Queen | King
type card = { rank : rank; suit : suit }

(* Idée : ramener chaque rang à un entier, puis comparer les entiers.
   Piège : la couleur n'entre PAS dans la comparaison (« par valeur »).
   On n'utilise pas `compare` directement : il ne garantit pas -1/0/1. *)
let value (c : card) : int =
  match c.rank with Num n -> n | Jack -> 11 | Queen -> 12 | King -> 13

let card_compare (a : card) (b : card) : int =
  let va = value a and vb = value b in
  if va = vb then 0 else if va > vb then 1 else -1

(* ---------- 1.2 Formes ---------- *)

type shape =
  | Rectangle of float * float
  | Circle of float
  | Rhombus of float * float

(* Idée : un cas par constructeur. Piège : opérateurs flottants (étoile-point, barre-point),
   et `2.` et non `2` pour le losange. *)
let surface (s : shape) : float =
  let pi = acos (-1.0) in
  match s with
  | Rectangle (l, w) -> l *. w
  | Circle r -> pi *. r *. r
  | Rhombus (p, q) -> p *. q /. 2.

(* ---------- 2.1 Entiers de 0 à n ---------- *)

(* Problème : la liste sort DÉCROISSANTE ([n; ...; 0]), car on ajoute n en
   tête avant les plus petits. Non terminale : une pile d'appels de taille n. *)
let rec integers_1 (n : int) : int list =
  if n < 0 then [] else n :: integers_1 (n - 1)

(* Croissante, mais `@` recopie sa liste de gauche à chaque appel : O(n^2)
   (et pile de taille n). Avec n = 100 000, c'est très lent. *)
let rec integers_2 (n : int) : int list =
  if n < 0 then [] else integers_2 (n - 1) @ [ n ]

(* Croissante en O(n) : on renverse la liste de integers_1 (un parcours de
   plus, mais linéaire). *)
let integers_3 (n : int) : int list = List.rev (integers_1 n)

(* Version terminale de integers_1 : l'accumulateur reçoit 0, puis 1, ... et
   l'appel récursif est la dernière opération (pas de pile qui grandit).
   Même résultat que integers_1 ([n; ...; 0]), en O(n) et espace constant de
   pile. Comparé à integers_3 : même complexité O(n), mais un seul parcours
   au lieu de deux et aucune liste intermédiaire. *)
let integers_1_terminal (n : int) : int list =
  let rec aux (i : int) (acc : int list) : int list =
    if i > n then acc else aux (i + 1) (i :: acc)
  in
  aux 0 []

(* ---------- 2.2 Traiter des listes ---------- *)

exception EmptyList

(* Idée : on s'arrête après 3 éléments. `List.length` parcourt TOUTE la
   liste (coût inutile, et infini sur une liste infinie) ; le filtrage
   regarde seulement les trois premières cellules. *)
let three_or_more (l : 'a list) : bool =
  match l with _ :: _ :: _ :: _ -> true | _ -> false

(* Base : [] = 0. Piège : ne pas oublier le `1 +` (pas terminale). *)
let rec size (l : 'a list) : int = match l with [] -> 0 | _ :: t -> 1 + size t

(* Base : le singleton. Piège : [] n'a pas de dernier élément -> exception. *)
let rec last (l : 'a list) : 'a =
  match l with [] -> raise EmptyList | [ x ] -> x | _ :: t -> last t

(* Idée : comparer chaque élément à son voisin. Base : [] et singleton
   sont croissantes. Piège : `<=` (5; 5 est croissant, voir l'énoncé). *)
let rec is_increasing (l : int list) : bool =
  match l with x :: (y :: _ as t) -> x <= y && is_increasing t | _ -> true

(* Idée : deux éléments à la fois, impair puis pair. Base : [] vrai ;
   un seul élément restant doit être impair. Piège : `mod` d'un négatif
   peut être -1, donc tester `<> 0` plutôt que `= 1`. *)
let rec even_odd (l : int list) : bool =
  match l with
  | [] -> true
  | [ x ] -> x mod 2 <> 0
  | x :: y :: t -> x mod 2 <> 0 && y mod 2 = 0 && even_odd t

(* Base : [] -> faux. Pourrait s'écrire avec `||` ; court-circuit. *)
let rec find (e : 'a) (l : 'a list) : bool =
  match l with [] -> false | x :: t -> x = e || find e t

(* Idée : on retourne la liste elle-même (`l`, pas `t`) quand la tête
   vaut e : c'est la portion qui commence à e. Base : [] -> []. *)
let rec member (e : 'a) (l : 'a list) : 'a list =
  match l with [] -> [] | x :: t -> if x = e then l else member e t

(* Idée : on cherche d'abord dans la QUEUE ; si on y trouve e, c'est la
   dernière occurrence ; sinon la tête décide. Un seul parcours. *)
let rec member_last (e : 'a) (l : 'a list) : 'a list =
  match l with
  | [] -> []
  | x :: t -> (
      match member_last e t with [] -> if x = e then l else [] | r -> r)

(* Base : [] -> 0. *)
let rec nb_occ (e : 'a) (l : 'a list) : int =
  match l with
  | [] -> 0
  | x :: t -> if x = e then 1 + nb_occ e t else nb_occ e t

(* nème élément, en comptant à partir de 1 (nth 3 [1;2;3;..] = 3).
   Base : n = 1 -> la tête. Piège : liste trop courte -> EmptyList. *)
let rec nth (n : int) (l : 'a list) : 'a =
  match l with
  | [] -> raise EmptyList
  | x :: t -> if n <= 1 then x else nth (n - 1) t

(* Idée : le maximum de la queue contre la tête. Base : singleton. *)
let rec max_list (l : int list) : int =
  match l with
  | [] -> raise EmptyList
  | [ x ] -> x
  | x :: t -> max x (max_list t)

(* Un seul parcours : on porte (max courant, nombre de fois vu).
   Nouveau plus grand -> compteur remis à 1 ; égal -> +1. *)
let nb_max (l : int list) : int =
  let rec aux (m : int) (c : int) (l : int list) : int =
    match l with
    | [] -> c
    | x :: t ->
        if x > m then aux x 1 t
        else if x = m then aux m (c + 1) t
        else aux m c t
  in
  match l with [] -> raise EmptyList | x :: t -> aux x 1 t

(* Un seul parcours : somme ET longueur en même temps. Piège : `float_of_int`
   pour la longueur ; liste vide -> EmptyList (division par 0 sinon). *)
let average (l : float list) : float =
  let rec aux (s : float) (n : int) (l : float list) : float =
    match l with [] -> s /. float_of_int n | x :: t -> aux (s +. x) (n + 1) t
  in
  match l with [] -> raise EmptyList | _ -> aux 0. 0 l

(* Idée : calculer la taille (size) puis la comparer aux bornes, dans
   n'importe quel ordre (a, b) ou (b, a). *)
let size_in_range (a : int) (b : int) (l : 'a list) : bool =
  let n = size l in
  min a b <= n && n <= max a b

(* Idée : `is_prefix p l` teste si p commence l ; find_pattern essaie ce
   test à chaque position. Base : le motif [] est toujours présent.
   Piège : [1;1] n'est PAS dans [1;2;1] (éléments consécutifs). *)
let rec is_prefix (p : 'a list) (l : 'a list) : bool =
  match (p, l) with
  | [], _ -> true
  | _, [] -> false
  | x :: pt, y :: lt -> x = y && is_prefix pt lt

let rec find_pattern (p : 'a list) (l : 'a list) : bool =
  is_prefix p l || match l with [] -> false | _ :: t -> find_pattern p t

(* ---------- 2.3 Créer des listes ---------- *)

(* Idée : reconstruire cellule par cellule. *)
let rec list_copy (l : 'a list) : 'a list =
  match l with [] -> [] | x :: t -> x :: list_copy t

(* Idée : n tirages de `Random.int max` (dans [0, max-1]).
   Piège : `let x = ... in` force l'ordre d'évaluation (sinon l'ordre des
   arguments de `::` n'est pas garanti). *)
let rec random_list (n : int) (max : int) : int list =
  if n <= 0 then []
  else
    let x = Random.int max in
    x :: random_list (n - 1) max

(* Idée : accumulateur ; chaque élément lu passe en tête de l'accumulateur,
   donc l'ordre s'inverse. O(n) (contrairement à `reverse t @ [x]`). *)
let reverse (l : 'a list) : 'a list =
  let rec aux (acc : 'a list) (l : 'a list) : 'a list =
    match l with [] -> acc | x :: t -> aux (x :: acc) t
  in
  aux [] l

(* Base : [] -> []. Sinon `@` de la première sous-liste et de l'aplatissement
   du reste. *)
let rec flatten_list (l : 'a list list) : 'a list =
  match l with [] -> [] | x :: t -> x @ flatten_list t

(* Idée : deux accumulateurs (a, b) = deux nombres de Fibonacci consécutifs ;
   on émet `a` en tête, donc l'ordre est déjà le bon (rien à renverser). *)
let fibo (n : int) : int list =
  let rec aux (n : int) (a : int) (b : int) : int list =
    if n <= 0 then [] else a :: aux (n - 1) b (a + b)
  in
  aux n 0 1

(* Liste TRIÉE : les doublons sont voisins, on compare à la cellule suivante. *)
let rec without_duplicates (l : int list) : int list =
  match l with
  | x :: (y :: _ as t) ->
      if x = y then without_duplicates t else x :: without_duplicates t
  | _ -> l

(* Idée : on porte le plus grand vu jusqu'ici. Un élément est un record
   s'il est STRICTEMENT plus grand ; le premier en est toujours un. *)
let records (l : int list) : int list =
  let rec aux (m : int) (l : int list) : int list =
    match l with [] -> [] | x :: t -> if x > m then x :: aux x t else aux m t
  in
  match l with [] -> [] | x :: t -> x :: aux x t

(* Idée : pour la tête x, compter ses occurrences, puis recommencer sur la
   queue débarrassée de x. Résultat dans l'ordre de première apparition. *)
let rec frequences (l : 'a list) : ('a * int) list =
  match l with
  | [] -> []
  | x :: t ->
      (x, 1 + nb_occ x t) :: frequences (List.filter (fun y -> y <> x) t)

(* Décrire un terme à voix haute : [1;1;2] -> « deux 1, un 2 » -> [2;1;1;2].
   `describe` compte la série de chiffres identiques en tête.
   Le résultat est le plus récent en premier (voir l'énoncé). *)
let describe (l : int list) : int list =
  let rec aux (d : int) (c : int) (l : int list) : int list =
    match l with
    | x :: t when x = d -> aux d (c + 1) t
    | _ -> c :: d :: (match l with [] -> [] | x :: t -> aux x 1 t)
  in
  match l with [] -> [] | x :: t -> aux x 1 t

let look_and_say (n : int) : int list list =
  let rec aux (k : int) (cur : int list) (acc : int list list) : int list list =
    if k <= 0 then acc else aux (k - 1) (describe cur) (cur :: acc)
  in
  aux n [ 1 ] []

(* ---------- 2.4 Tris ---------- *)

(* Idée : distribuer en alternance ; tailles égales à 1 près.
   Base : [] et singleton (le singleton va à gauche). *)
let rec f_split (l : 'a list) : 'a list * 'a list =
  match l with
  | [] -> ([], [])
  | [ x ] -> ([ x ], [])
  | x :: y :: t ->
      let a, b = f_split t in
      (x :: a, y :: b)

(* Idée : comparer les deux têtes, prendre la plus petite. Base : l'une des
   listes vide -> l'autre. Piège : `<=` garde le tri stable. *)
let rec f_merge (a : 'a list) (b : 'a list) : 'a list =
  match (a, b) with
  | [], l | l, [] -> l
  | x :: ta, y :: tb -> if x <= y then x :: f_merge ta b else y :: f_merge a tb

(* Base : 0 ou 1 élément = déjà trié. Piège : sans le cas du singleton,
   f_split [x] = ([x], []) et on boucle à l'infini. *)
let rec fusion_sort (l : 'a list) : 'a list =
  match l with
  | [] | [ _ ] -> l
  | _ ->
      let a, b = f_split l in
      f_merge (fusion_sort a) (fusion_sort b)

(* Pivot = première valeur ; trois listes : plus petits, égaux (pivot
   compris), plus grands. Les égaux évitent la boucle infinie du quicksort
   à deux listes quand il y a des doublons. *)
let q_split (l : 'a list) : 'a list * 'a list * 'a list =
  match l with
  | [] -> ([], [], [])
  | p :: _ ->
      ( List.filter (fun x -> x < p) l,
        List.filter (fun x -> x = p) l,
        List.filter (fun x -> x > p) l )

(* Les trois listes sont déjà triées et ordonnées entre elles : on les
   concatène, rien à comparer. *)
let q_merge (a : 'a list) (b : 'a list) (c : 'a list) : 'a list = a @ b @ c

(* Base : [] . Les sous-listes `petits` et `grands` sont STRICTEMENT plus
   courtes que l (le pivot est dans `egaux`), donc la récursion termine. *)
let rec quick_sort (l : 'a list) : 'a list =
  match l with
  | [] -> []
  | _ ->
      let a, b, c = q_split l in
      q_merge (quick_sort a) b (quick_sort c)
