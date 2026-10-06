(* Laboratoire 01 : premiers pas avec OCaml.

   Les sections 2 et 4 de l'énoncé (types des expressions, liaisons) se
   répondent au toplevel : les réponses vérifiées sont dans README.md.
   Ici : les sections 3 (liaison locale), 5 (conditions) et 6 (fonctions). *)

(* ---------- Section 3 : liaison locale ---------- *)

(* Idée : nommer pi, r et h une seule fois avec `let ... in`, puis tout
   calculer dans UNE expression.
   Piège : `let pi = acos (-1.0)` -- le `-1.0` doit être entre parenthèses
   et être un flottant ; `r *. r` et non `r * r` (opérateurs flottants). *)
let aire_disque (r : float) : float =
  let pi = acos (-1.0) in
  pi *. r *. r

(* Idée : `and` lie plusieurs noms en parallèle, mais les noms liés ne se
   voient pas entre eux : d'où trois `let ... in` imbriqués pour que `a`
   et `v` réutilisent `d` et `p` sans les recalculer.
   Retourne (p, a, v) = (périmètre, aire totale, volume). *)
let cylindre (r : float) (h : float) : float * float * float =
  let pi = acos (-1.0) in
  let d = pi *. r *. r in
  let p = 2.0 *. pi *. r in
  (p, (2.0 *. d) +. (p *. h), d *. h)

(* ---------- Section 5 : conditions ---------- *)

(* Idée : `if` est une expression, ses deux branches ont le même type. *)
let maximum (a : int) (b : int) : int = if a > b then a else b

(* Idée : min de trois = min du min de deux et du troisième. *)
let minimum3 (a : int) (b : int) (c : int) : int =
  let m = if a < b then a else b in
  if m < c then m else c

(* `if a mod 2 = 0 then a else "odd"` est rejeté : les deux branches
   doivent avoir le même type (int contre string). *)

(* `if a < 10 then let b = "small" else let b = "large"` est rejeté :
   un `let` sans `in` est une définition, pas une expression. Correct :
   on lie le `if` tout entier. *)
let etiquette (a : int) : string = if a < 10 then "small" else "large"

(* Idée : ceil(a/2) = a/2 si a est pair, sinon on arrondit vers le haut.
   Piège : la division entière d'OCaml tronque vers 0 ; pour a négatif
   impair (-3), a/2 = -1 est DÉJÀ le plafond de -1,5. Donc +1 seulement
   si a > 0. *)
let plafond_moitie (a : int) : int =
  if a mod 2 = 0 then a / 2 else if a > 0 then (a / 2) + 1 else a / 2

(* Idée : min(a,b) est calculé une fois (liaison locale), le test
   `c mod 3 = 0` une fois aussi, puis on bâtit le résultat. *)
let expression (a : int) (b : int) (c : int) : int =
  let m = if a < b then a else b in
  let carre = m * m in
  if c mod 3 = 0 then carre + 1 else carre

(* ---------- Section 6 : fonctions ---------- *)

let double (x : int) : int = x * 2

(* Idée : division entière (tronquée). Piège : avec des flottants il
   faut `+.` et `/.` : ce n'est donc pas réutilisable tel quel
   (`average 1.0 2.0 3.0` ne type pas) ; version flottante ci-dessous. *)
let average (a : int) (b : int) (c : int) : int = (a + b + c) / 3

let average_float (a : float) (b : float) (c : float) : float =
  (a +. b +. c) /. 3.0

(* Idée : a => b  est  (non a) ou b. Faux seulement si a vrai et b faux.
   Piège : `||` est séquentiel, `b` n'est évalué que si `a` est vrai. *)
let implies (a : bool) (b : bool) : bool = (not a) || b

(* Version polymorphique avec fst et snd : type 'a * 'b -> 'b * 'a. *)
let inv_fst_snd (p : 'a * 'b) : 'b * 'a = (snd p, fst p)

(* Version par filtrage dans le paramètre : plus idiomatique. *)
let inv ((a, b) : 'a * 'b) : 'b * 'a = (b, a)

(* Même chose restreinte aux entiers : l'annotation fixe le type
   int * int -> int * int. *)
let inv_int ((a, b) : int * int) : int * int = (b, a)

(* Prend () (le seul élément de unit) : type unit -> int. *)
let f_one () : int = 1

(* Idée : trois cas exclusifs, le 0 est le cas du milieu. *)
let sign (x : int) : int = if x < 0 then -1 else if x = 0 then 0 else 1
