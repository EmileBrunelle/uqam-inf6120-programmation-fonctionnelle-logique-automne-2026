(* Laboratoire 02 : définitions de fonctions.
   Convention : toutes les fonctions numériques supposent des entiers
   naturels en entrée (n >= 0) ; avec un n négatif, la récursion ne
   termine pas. *)

(* ---------- 1. Factorielle ---------- *)

(* Idée : n! = n * (n-1)!.  Cas de base : 0! = 1.
   Piège : oublier `rec`, ou le cas de base (récursion infinie).
   Non terminale : après l'appel récursif, il reste une multiplication. *)
let rec fact (n : int) : int = if n = 0 then 1 else n * fact (n - 1)

(* ---------- 2. Fibonacci ---------- *)

(* Idée : fib n = fib (n-1) + fib (n-2).  Deux cas de base : 0 et 1.
   Piège : oublier un des deux cas de base ; complexité exponentielle
   (on recalcule les mêmes termes) -> voir fib' plus bas. *)
let rec fib (n : int) : int =
  if n = 0 then 0 else if n = 1 then 1 else fib (n - 1) + fib (n - 2)

(* ---------- 3. PGCD ---------- *)

(* Idée : l'énoncé donne les trois cas ; chaque appel diminue le couple.
   Cas de base : m = 0, le résultat est n.
   Terminale : les deux appels récursifs sont la dernière chose faite. *)
let rec pgcd (m : int) (n : int) : int =
  if m = 0 then n else if m > n then pgcd n m else pgcd (n mod m) m

(* ---------- 4. Ackermann-Péter ---------- *)

(* Idée : transcription directe des trois cas.
   Piège : le troisième cas contient un appel imbriqué
   `ackermann m (n-1)` ; la valeur explose (ne pas tester avec m >= 4).
   Non terminale : l'appel interne n'est pas en position terminale (même
   si l'appel externe l'est). *)
let rec ackermann (m : int) (n : int) : int =
  if m = 0 then n + 1
  else if n = 0 then ackermann (m - 1) 1
  else ackermann (m - 1) (ackermann m (n - 1))

(* ---------- 5. Coefficients binomiaux ---------- *)

(* Idée : formule de Pascal C(n+1,k+1) = C(n,k) + C(n,k+1).
   Cas de base : C(n,0) = 1, et C(n,k) = 0 si n < k.
   Piège : tester `k = 0` AVANT `n < k` pour que C(0,0) = 1 ; et pour
   n = 0, k > 0 le cas n < k donne 0 (sinon on appellerait n - 1 < 0). *)
let rec binom (n : int) (k : int) : int =
  if k = 0 then 1
  else if n < k then 0
  else binom (n - 1) (k - 1) + binom (n - 1) k

(* Vérification en une seule expression : pour tous 0 <= k <= n <= 3,
   binom n k = n! / (k! (n-k)!).  `List.init (n + 1) Fun.id` = [0; ...; n]. *)
let binom_verifie : bool =
  List.for_all
    (fun (n : int) ->
      List.for_all
        (fun (k : int) -> binom n k = fact n / (fact k * fact (n - k)))
        (List.init (n + 1) Fun.id))
    [ 0; 1; 2; 3 ]

(* ---------- 6. Fonctions mutuellement récursives ---------- *)

(* Idée : n est pair ssi n = 0 ou n-1 est impair ; n est impair ssi n <> 0
   et n-1 est pair.  `and` relie les deux définitions.
   Piège : oublier `and` (la deuxième fonction serait inconnue de la
   première).  `||` et `&&` sont séquentiels : l'appel de droite reste en
   position terminale, donc les deux fonctions sont récursives terminales. *)
let rec is_even (n : int) : bool = n = 0 || is_odd (n - 1)
and is_odd (n : int) : bool = n <> 0 && is_even (n - 1)

(* ---------- 7. Récursivité terminale ---------- *)

(* Bilan des exercices 1 à 6 :
   - fact : non terminale (multiplication après l'appel)
   - fib : non terminale (addition de deux appels)
   - pgcd : TERMINALE (les deux appels sont en dernière position)
   - ackermann : non terminale (l'appel interne est un argument)
   - binom : non terminale (addition de deux appels)
   - is_even / is_odd : TERMINALES (mutuellement) *)

(* Idée : l'accumulateur porte le produit déjà calculé ; on le renvoie
   au cas de base.  fact' 3 : aux 3 1 -> aux 2 3 -> aux 1 6 -> aux 0 6 = 6.
   Piège : initialiser l'accumulateur à 1 (élément neutre de la multiplication), pas 0. *)
let fact' (n : int) : int =
  let rec aux (n : int) (acc : int) : int =
    if n = 0 then acc else aux (n - 1) (n * acc)
  in
  aux n 1

(* Idée : deux accumulateurs (a = rang k-2, b = rang k-1) ; à chaque pas
   on avance d'un rang : (a, b) devient (b, a + b).  Linéaire au lieu
   d'exponentiel.  Cas de base : n = 0 -> a (= fib 0 au départ). *)
let fib' (n : int) : int =
  let rec aux (n : int) (a : int) (b : int) : int =
    if n = 0 then a else aux (n - 1) b (a + b)
  in
  aux n 0 1

(* (L'exercice sur la suite de Syracuse est en commentaire dans le HTML de
   l'énoncé : non inclus.) *)

(* ---------- 8. Exponentielle ---------- *)

(* Idée : x^n = x * x^(n-1), x^0 = 1.  n multiplications. *)
let rec exp (x : int) (n : int) : int = if n = 0 then 1 else x * exp x (n - 1)

(* Version terminale : l'accumulateur multiplie x à chaque pas. *)
let exp' (x : int) (n : int) : int =
  let rec aux (n : int) (acc : int) : int =
    if n = 0 then acc else aux (n - 1) (acc * x)
  in
  aux n 1

(* Idée : x^(2k) = (x^k)^2 et x^(2k+1) = (x^k)^2 * x : on divise n par 2
   à chaque appel, donc environ log2 n appels au lieu de n.
   Piège : calculer `fast_exp x k` UNE fois (let ... in) ; l'écrire deux
   fois (`fast_exp x k * fast_exp x k`) redonne une complexité linéaire. *)
let rec fast_exp (x : int) (n : int) : int =
  if n = 0 then 1
  else
    let r = fast_exp x (n / 2) in
    if n mod 2 = 0 then r * r else r * r * x

(* Avec compteur d'appels récursifs : paire (résultat, nb d'appels).
   exp_nb 2 10 = (1024, 10). *)
let rec exp_nb (x : int) (n : int) : int * int =
  if n = 0 then (1, 0)
  else
    let r, nb = exp_nb x (n - 1) in
    (x * r, nb + 1)

(* fast_exp_nb 2 10 = (1024, 4) : 10 -> 5 -> 2 -> 1 -> 0, soit
   floor(log2 n) + 1 appels, contre n pour exp_nb. *)
let rec fast_exp_nb (x : int) (n : int) : int * int =
  if n = 0 then (1, 0)
  else
    let r, nb = fast_exp_nb x (n / 2) in
    ((if n mod 2 = 0 then r * r else r * r * x), nb + 1)

(* Bonus : on compte les multiplications.
   exp : exactement n multiplications. *)
let rec exp_mult (x : int) (n : int) : int * int =
  if n = 0 then (1, 0)
  else
    let r, m = exp_mult x (n - 1) in
    (x * r, m + 1)

(* fast_exp : 1 multiplication (le carré) par appel, +1 si n est impair
   (multiplication par x).  Lien avec la base 2 : chaque appel consomme un
   chiffre binaire de n ; le carré coûte 1 par chiffre, et la multiplication
   par x coûte 1 par chiffre égal à 1.  Total = (nombre de chiffres de n en
   base 2) + (nombre de 1 dans l'écriture binaire de n).
   Ex. n = 21 = 10101 : 5 chiffres + 3 uns = 8 multiplications. *)
let rec fast_exp_mult (x : int) (n : int) : int * int =
  if n = 0 then (1, 0)
  else
    let r, m = fast_exp_mult x (n / 2) in
    if n mod 2 = 0 then (r * r, m + 1) else (r * r * x, m + 2)

(* ---------- 9. Sommes doubles ---------- *)

(* sum1 n m = somme pour a de n à m de (somme pour b de a à m de b).
   Idée : deux récursions emboîtées ; `interne a m` = a + (a+1) + ... + m.
   Cas de base : intervalle vide (a > m) -> 0 (d'où sum1 5 3 = 0). *)
let rec interne (a : int) (m : int) : int =
  if a > m then 0 else a + interne (a + 1) m

let rec sum1 (n : int) (m : int) : int =
  if n > m then 0 else interne n m + sum1 (n + 1) m

(* sum2 n = somme des k / j pour 0 <= k < j <= n, division FLOTTANTE.
   Piège : `k / j` entier donnerait 0 ; convertir avec float_of_int et
   utiliser `/.` et `+.`.  `ligne j k` = somme des k / j pour k de k à j-1. *)
let rec ligne (j : int) (k : int) : float =
  if k >= j then 0.0 else (float_of_int k /. float_of_int j) +. ligne j (k + 1)

let rec sum2 (n : int) : float =
  if n <= 0 then 0.0 else sum2 (n - 1) +. ligne n 0

(* ---------- 10. Application partielle ---------- *)

(* add : int -> int -> int  (c'est int -> (int -> int) : la flèche associe
   à droite).  add 5 : int -> int (application partielle). *)
let add (x : int) (y : int) : int = x + y

(* addx est la même fonction écrite avec un `fun` explicite : même type
   int -> int -> int, même comportement.  `let add x y = ...` n'est que du
   sucre pour `let add = fun x -> fun y -> ...`. *)
let addx (x : int) : int -> int = fun y -> x + y

(* add3 : int -> int.  Pas de paramètre, mais c'est quand même une
   fonction : elle vient de l'application partielle addx 3. *)
let add3 : int -> int = addx 3
