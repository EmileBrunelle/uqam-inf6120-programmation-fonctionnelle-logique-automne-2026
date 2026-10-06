# 25 exemples OCaml commentés (révision QCM)

Tous les exemples portent sur des problèmes originaux (aucun lien avec les TP ni les devoirs).
Chaque sortie a été vérifiée dans le toplevel (OCaml 5.5.1). Chaque exemple : énoncé, code, trace
à la main, puis des pièges de lecture du genre « que fait ce code ? ».

Réflexe QCM : lis le **type** avant le corps, puis déroule sur un petit exemple à la main.

---

## 1. Compter les voyelles

**Énoncé** : nombre de voyelles (minuscules, `y` inclus) d'une chaîne.

```ocaml
let est_voyelle (c : char) : bool = String.contains "aeiouy" c

let compter_voyelles (s : string) : int =
  String.fold_left (fun acc c -> if est_voyelle c then acc + 1 else acc) 0 s
```

**Trace** `compter_voyelles "oca"` : acc = 0 ; `'o'` voyelle → 1 ; `'c'` non → 1 ; `'a'` voyelle → 2. Résultat `2`.

**Pièges**
- `compter_voyelles "ocaml"` → `2` ; `compter_voyelles ""` → `0`.
- `compter_voyelles "Aeiou"` → `4` : le `'A'` majuscule n'est pas dans `"aeiouy"`.
- `String.fold_left (fun acc c -> c :: acc) [] "abc"` → `['c'; 'b'; 'a']` (le dernier caractère arrive en tête).

---

## 2. Aplatir une liste de listes

**Énoncé** : concaténer toutes les sous-listes, dans l'ordre.

```ocaml
let rec aplatir (ll : 'a list list) : 'a list =
  match ll with
  | [] -> []
  | l :: reste -> l @ aplatir reste
```

**Trace** `aplatir [[1; 2]; []; [3]]`
= `[1; 2] @ aplatir [[]; [3]]`
= `[1; 2] @ ([] @ aplatir [[3]])`
= `[1; 2] @ ([] @ ([3] @ []))` = `[1; 2; 3]`.

**Pièges**
- `aplatir [[]; []]` → `[]`, de type `'a list` (polymorphe, aucune information sur le contenu).
- `List.map (fun l -> l @ [0]) [[1]; [2]]` → `[[1; 0]; [2; 0]]` : `map` ne change pas le niveau d'imbrication.
- `List.flatten [[[1]]; [[2]]]` → `[[1]; [2]]` : on n'enlève qu'**un** niveau.

---

## 3. Arbre binaire de recherche

**Énoncé** : insérer (sans doublons), tester l'appartenance, lire en ordre croissant.

```ocaml
type 'a abr = Feuille | Noeud of 'a abr * 'a * 'a abr

let rec inserer (x : 'a) (t : 'a abr) : 'a abr =
  match t with
  | Feuille -> Noeud (Feuille, x, Feuille)
  | Noeud (g, v, d) ->
    if x < v then Noeud (inserer x g, v, d)
    else if x > v then Noeud (g, v, inserer x d)
    else t

let rec appartient (x : 'a) (t : 'a abr) : bool =
  match t with
  | Feuille -> false
  | Noeud (g, v, d) -> x = v || (if x < v then appartient x g else appartient x d)

let rec en_liste (t : 'a abr) : 'a list =
  match t with
  | Feuille -> []
  | Noeud (g, v, d) -> en_liste g @ (v :: en_liste d)

let arbre : int abr =
  List.fold_left (fun t x -> inserer x t) Feuille [5; 2; 8; 2; 1]
```

**Trace** (insertion de 5, 2, 8, 2, 1) : 5 devient la racine ; 2 < 5 va à gauche ; 8 > 5 va à droite ;
le second 2 retombe sur un nœud égal → arbre inchangé ; 1 < 5, 1 < 2 → à gauche de 2.

**Pièges**
- `arbre` → `Noeud (Noeud (Noeud (Feuille, 1, Feuille), 2, Feuille), 5, Noeud (Feuille, 8, Feuille))`.
- `en_liste arbre` → `[1; 2; 5; 8]` ; `appartient 8 arbre` → `true` ; `appartient 3 arbre` → `false`.
- `List.fold_right inserer [5; 2; 8; 2; 1] Feuille = arbre` → `false` : `fold_right` insère en commençant par la fin (1 d'abord), donc la forme de l'arbre change.
- `en_liste (List.fold_left (fun t x -> inserer x t) Feuille [1; 2; 3])` → `[1; 2; 3]`, mais l'arbre est une « chaîne » (hauteur 3).

---

## 4. Évaluateur d'expressions arithmétiques

**Énoncé** : évaluer et mesurer un arbre d'expression.

```ocaml
type expr = Cst of int | Add of expr * expr | Mul of expr * expr | Neg of expr

let rec eval (e : expr) : int =
  match e with
  | Cst n -> n
  | Add (a, b) -> eval a + eval b
  | Mul (a, b) -> eval a * eval b
  | Neg a -> - eval a

let rec taille (e : expr) : int =
  match e with
  | Cst _ -> 1
  | Add (a, b) | Mul (a, b) -> 1 + taille a + taille b
  | Neg a -> 1 + taille a

let e1 : expr = Add (Cst 2, Mul (Cst 3, Neg (Cst 4)))
```

**Trace** `eval e1` = `eval (Cst 2) + eval (Mul (Cst 3, Neg (Cst 4)))` = `2 + (3 * (- 4))` = `2 + (-12)` = `-10`.

**Pièges**
- `eval e1` → `-10` ; `taille e1` → `6` (2 + Add, Mul, Neg, Cst 3, Cst 4 : compte chaque constructeur).
- `eval (Neg (Neg (Cst 3)))` → `3`.
- `Neg (Cst 3)` est une **valeur** de type `expr`, pas l'entier `-3`.
- `- 2 - 3` → `-5` ; `7 - -2` → `9`.

---

## 5. Run-length encoding

**Énoncé** : compresser une liste en paires (élément, nombre de répétitions consécutives), et décompresser.

```ocaml
let rec compresser (l : 'a list) : ('a * int) list =
  match l with
  | [] -> []
  | x :: reste ->
    (match compresser reste with
     | (y, n) :: suite when y = x -> (y, n + 1) :: suite
     | resultat -> (x, 1) :: resultat)

let rec decompresser (l : ('a * int) list) : 'a list =
  match l with
  | [] -> []
  | (x, n) :: reste -> List.init n (fun _ -> x) @ decompresser reste
```

**Trace** `compresser [1; 1; 2]` : on descend d'abord. `compresser [2]` = `[(2, 1)]`.
Pour `x = 1` : tête `(2, 1)`, `2 <> 1` → `(1, 1) :: [(2, 1)]`.
Pour `x = 1` : tête `(1, 1)`, égale → `(1, 2) :: [(2, 1)]` = `[(1, 2); (2, 1)]`.

**Pièges**
- `compresser ['a'; 'a'; 'b'; 'a']` → `[('a', 2); ('b', 1); ('a', 1)]` : seulement les répétitions **consécutives**.
- `decompresser [('x', 2); ('y', 0); ('z', 1)]` → `['x'; 'x'; 'z']` (`'y'` répété 0 fois disparaît).
- `decompresser (compresser [1; 1; 2; 2; 2])` → `[1; 1; 2; 2; 2]` (aller-retour) ; `List.length (compresser [1; 1; 1])` → `1`.

---

## 6. Rotation d'une liste

**Énoncé** : décaler une liste de `n` positions vers la gauche (les `n` premiers passent à la fin).

```ocaml
let rec decouper (n : int) (l : 'a list) : 'a list * 'a list =
  match n, l with
  | 0, _ | _, [] -> ([], l)
  | _, x :: reste ->
    let (avant, apres) = decouper (n - 1) reste in
    (x :: avant, apres)

let rotation (n : int) (l : 'a list) : 'a list =
  let (avant, apres) = decouper (n mod List.length l) l in
  apres @ avant
```

**Trace** `rotation 2 [1; 2; 3; 4; 5]` : `2 mod 5 = 2`. `decouper 2 [1;2;3;4;5]` → `1 :: ` de `decouper 1 [2;3;4;5]`
→ `2 ::` de `decouper 0 [3;4;5]` = `([], [3;4;5])`. On remonte : `([1; 2], [3; 4; 5])`.
`apres @ avant` = `[3; 4; 5; 1; 2]`.

**Pièges**
- `decouper 9 [1; 2]` → `([1; 2], [])` ; `decouper (-1) [1; 2]` → `([1; 2], [])` : `n` négatif n'atteint jamais le cas `0`.
- `rotation 7 [1; 2; 3; 4; 5]` → `[3; 4; 5; 1; 2]` (`7 mod 5 = 2`) ; `rotation 0 [1; 2]` → `[1; 2]`.
- `(-1) mod 5` → `-1` en OCaml (le signe suit le dividende). `rotation 1 []` lève `Division_by_zero` (`mod 0`).

---

## 7. Fusion de listes triées

**Énoncé** : fusionner deux listes triées en une liste triée.

```ocaml
let rec fusionner (a : int list) (b : int list) : int list =
  match a, b with
  | [], l | l, [] -> l
  | x :: ra, y :: rb ->
    if x <= y then x :: fusionner ra b else y :: fusionner a rb
```

**Trace** `fusionner [1; 4] [2; 3]` : `1 <= 2` → `1 ::` `fusionner [4] [2; 3]` ; `4 > 2` → `2 ::` `fusionner [4] [3]` ;
`4 > 3` → `3 ::` `fusionner [4] []` = `[4]`. Résultat `[1; 2; 3; 4]`.

**Pièges**
- `fusionner [1; 4; 6] [2; 3; 7; 9]` → `[1; 2; 3; 4; 6; 7; 9]`.
- `fusionner [3; 1] [2]` → `[2; 3; 1]` : si une entrée n'est pas triée, la sortie ne l'est pas non plus (le code ne vérifie rien).
- `fusionner [1; 1] [1]` → `[1; 1; 1]` : les doublons sont conservés.

---

## 8. `option` chaînés

**Énoncé** : calculer `racine_entiere (a / b)` ; `None` si `b = 0` ou si le quotient est négatif.

```ocaml
let diviser (a : int) (b : int) : int option =
  if b = 0 then None else Some (a / b)

let racine_entiere (n : int) : int option =
  if n < 0 then None else Some (int_of_float (sqrt (float_of_int n)))

let calcul (a : int) (b : int) : int option =
  Option.bind (diviser a b) racine_entiere
```

**Trace** `calcul 100 4` : `diviser 100 4 = Some 25` ; `Option.bind (Some 25) racine_entiere` = `racine_entiere 25` = `Some 5`.
`calcul 1 0` : `diviser 1 0 = None` ; `bind None _ = None`.

**Pièges**
- `calcul 100 4` → `Some 5` ; `calcul 1 0` → `None` ; `calcul (-100) 4` → `None` (`-25`).
- `Option.value (calcul 1 0) ~default:(-1)` → `-1`.
- `Option.map (fun x -> Some x) (Some 1)` → `Some (Some 1)` de type `int option option` : avec `map`, la fonction qui retourne une option crée un niveau de plus (c'est le rôle de `bind` de l'éviter).

---

## 9. `result` chaînés

**Énoncé** : prendre le premier élément d'une liste, vérifier qu'il est non négatif, puis le doubler. Erreur précise sinon.

```ocaml
type erreur = Vide | Negatif of int

let premier (l : int list) : (int, erreur) result =
  match l with [] -> Error Vide | x :: _ -> Ok x

let verifier (n : int) : (int, erreur) result =
  if n < 0 then Error (Negatif n) else Ok n

let traiter (l : int list) : (int, erreur) result =
  Result.bind (premier l) (fun x -> Result.map (fun y -> y * 2) (verifier x))
```

**Trace** `traiter [4; 1]` : `premier` → `Ok 4` ; `bind` applique la fonction à `4` ; `verifier 4 = Ok 4` ;
`map` doubler → `Ok 8`. Pour `traiter []` : `Error Vide`, la fonction n'est jamais appelée.

**Pièges**
- `traiter [4; 1]` → `Ok 8` ; `traiter []` → `Error Vide` ; `traiter [-3; 1]` → `Error (Negatif (-3))`.
- `traiter [4]` → `Ok 8` : seul le premier élément compte.
- `Result.map (fun y -> y * 2) (Error "e")` → `Error "e"` (de type `(int, string) result`) : `map` ne touche jamais au `Error`.

---

## 10. `fold` pour construire une table d'association

**Énoncé** : compter les occurrences de chaque mot dans une liste.

```ocaml
let ajouter (table : (string * int) list) (mot : string) : (string * int) list =
  match List.assoc_opt mot table with
  | None -> (mot, 1) :: table
  | Some n -> (mot, n + 1) :: List.remove_assoc mot table

let frequences (mots : string list) : (string * int) list =
  List.fold_left ajouter [] mots
```

**Trace** `frequences ["a"; "b"; "a"]` : `[]` → `[("a", 1)]` → `[("b", 1); ("a", 1)]` →
`"a"` existe (1) : `("a", 2) :: [("b", 1)]` = `[("a", 2); ("b", 1)]`.

**Pièges**
- `frequences ["a"; "b"; "a"; "c"; "a"; "b"]` → `[("b", 2); ("a", 3); ("c", 1)]` : l'ordre n'est **pas** celui de la première apparition (la dernière clé mise à jour passe en tête).
- `List.assoc "b" (frequences [...])` → `2` ; `List.assoc_opt "z" (frequences ["a"])` → `None` (`List.assoc "z" ...` lèverait `Not_found`).
- `List.sort (fun (_, a) (_, b) -> compare b a) (frequences ["a"; "b"; "a"])` → `[("a", 2); ("b", 1)]` (décroissant).

---

## 11. Version terminale vs non terminale

**Énoncé** : somme des carrés d'une liste, de deux façons.

```ocaml
let rec somme_carres (l : int list) : int =
  match l with [] -> 0 | x :: r -> x * x + somme_carres r

let somme_carres_term (l : int list) : int =
  let rec aux (acc : int) (l : int list) : int =
    match l with [] -> acc | x :: r -> aux (acc + x * x) r
  in
  aux 0 l
```

**Trace non terminale** `[1; 2; 3]` : `1 + (4 + (9 + 0))` : les additions attendent le retour de l'appel (pile qui grandit).
**Trace terminale** : `aux 0 [1;2;3]` → `aux 1 [2;3]` → `aux 5 [3]` → `aux 14 []` → `14` : rien à faire au retour, la pile reste constante.

**Pièges**
- Les deux donnent `14` pour `[1; 2; 3]` ; `List.fold_left (fun a x -> a + x * x) 0 [1; 2; 3]` aussi.
- Un appel est terminal seulement si c'est la **dernière** chose faite : `x * x + somme_carres r` ne l'est pas (il reste l'addition).
- Sur une très longue liste, la version non terminale risque de dépasser la pile (en OCaml 5 la pile est très grande, mais le principe à retenir pour l'examen reste le même).

---

## 12. `fold_left` vs `fold_right`

**Énoncé** : comprendre l'ordre de parcours et d'accumulation.

```ocaml
let inverser (l : 'a list) : 'a list =
  List.fold_left (fun acc x -> x :: acc) [] l
```

**Trace** `inverser [1; 2; 3]` : `[]` → `[1]` → `[2; 1]` → `[3; 2; 1]`.

**Pièges**
- `inverser [1; 2; 3]` → `[3; 2; 1]` ; `List.fold_right (fun x acc -> x :: acc) [1; 2; 3] []` → `[1; 2; 3]` (copie).
- `List.fold_left (fun acc x -> acc - x) 10 [1; 2; 3]` → `4` : `((10 - 1) - 2) - 3`.
- `List.fold_right (fun x acc -> x - acc) [1; 2; 3] 10` → `-8` : `1 - (2 - (3 - 10))`.
- `List.fold_left (fun acc x -> acc @ [x]) [] [1; 2; 3]` → `[1; 2; 3]` mais en temps quadratique (chaque `@` reparcourt l'accumulateur).

---

## 13. `filter_map`, `partition`, quantificateurs

**Énoncé** : garder les positifs et les multiplier par 10, en un seul passage.

```ocaml
let pairs_positifs (l : int list) : int list =
  List.filter_map (fun x -> if x > 0 then Some (x * 10) else None) l
```

(Le nom est trompeur exprès : la fonction ne s'occupe pas de parité.)

**Trace** `[3; -1; 0; 2]` : `3` → `Some 30` ; `-1` → `None` ; `0` → `None` (0 n'est pas `> 0`) ; `2` → `Some 20`. Résultat `[30; 20]`.

**Pièges**
- `List.partition (fun x -> x mod 2 = 0) [1; 2; 3; 4]` → `([2; 4], [1; 3])` (une **paire** de listes).
- `List.map (fun x -> x > 1) [1; 2]` → `[false; true]` ; `List.filter (fun x -> x > 1) [1; 2; 3]` → `[2; 3]`.
- `List.exists (fun x -> x > 5) []` → `false` mais `List.for_all (fun x -> x > 5) []` → `true` (vrai à vide).

---

## 14. Portée et masquage (`let ... in`)

**Énoncé** : prédire les valeurs avec des liaisons répétées.

```ocaml
let x = 10
let f (y : int) : int = x + y
let x = 20
```

**Trace** `f 1` : `f` a capturé `x = 10` à sa définition. Le second `let x = 20` crée une **nouvelle** liaison, il ne modifie pas l'ancienne. Donc `10 + 1`.

**Pièges**
- `f 1` → `11` (et non `21`).
- `let x = 1 in let x = x + 1 in x * 2` → `4`.
- `let a = 1 in (let a = 5 in a) + a` → `6` (le `a = 5` n'existe que dans les parenthèses).
- `(let x = 3 in x) + x` → `23` : le `x` hors du `let ... in` est le `x = 20` global.

---

## 15. Curryfication et application partielle

**Énoncé** : lire des fonctions qui retournent des fonctions.

```ocaml
let ajoute (a : int) (b : int) : int = a + b
let plus_trois : int -> int = ajoute 3

let appliquer_deux_fois (f : 'a -> 'a) (x : 'a) : 'a = f (f x)
```

**Trace** `appliquer_deux_fois (ajoute 5) 0` : `f = ajoute 5`, donc `f (f 0)` = `f 5` = `10`.

**Pièges**
- `plus_trois 4` → `7` ; `List.map (ajoute 10) [1; 2]` → `[11; 12]`.
- `appliquer_deux_fois (fun s -> s ^ "!") "hé"` → `"hé!!"`.
- `List.map (fun x -> ajoute x) [1; 2]` → `[<fun>; <fun>]`, de type `(int -> int) list` : on a oublié le second argument.
- `(fun (a, b) -> a + b) (1, 2)` → `3` : ici l'argument est un **tuple**, ce n'est pas la même signature que `ajoute`.

---

## 16. Filtrage : ordre des cas, gardes, motifs de liste

**Énoncé** : lire des `match` où l'ordre des cas compte.

```ocaml
let decrire (n : int) : string =
  match n with
  | 0 -> "zéro"
  | n when n < 0 -> "négatif"
  | 1 | 2 | 3 -> "petit"
  | _ -> "grand"

let tester (l : int list) : string =
  match l with
  | [] -> "vide"
  | [_] -> "un"
  | [_; _] -> "deux"
  | _ :: _ :: _ -> "plusieurs"
```

**Trace** `decrire 2` : pas `0` ; la garde `2 < 0` échoue ; `2` est dans `1 | 2 | 3` → `"petit"`.

**Pièges**
- `List.map decrire [0; -5; 2; 99]` → `["zéro"; "négatif"; "petit"; "grand"]`.
- `List.map tester [[]; [1]; [1; 2]; [1; 2; 3]]` → `["vide"; "un"; "deux"; "plusieurs"]`.
- `match (1, 2) with (a, b) when a > b -> "gt" | (a, _) when a = 1 -> "un" | _ -> "autre"` → `"un"` : le premier cas échoue sa garde, on passe au suivant.

---

## 17. `zip`, `dezip` et tuples

**Énoncé** : associer deux listes élément par élément, et défaire l'association.

```ocaml
let rec zip (a : 'a list) (b : 'b list) : ('a * 'b) list =
  match a, b with
  | x :: ra, y :: rb -> (x, y) :: zip ra rb
  | _ -> []

let rec dezip (l : ('a * 'b) list) : 'a list * 'b list =
  match l with
  | [] -> ([], [])
  | (x, y) :: reste -> let (xs, ys) = dezip reste in (x :: xs, y :: ys)
```

**Trace** `dezip [(1, 'a'); (2, 'b')]` : `dezip [(2, 'b')]` = `([2], ['b'])` ; on ajoute en tête : `([1; 2], ['a'; 'b'])`.

**Pièges**
- `zip [1; 2; 3] ["a"; "b"]` → `[(1, "a"); (2, "b")]` : tronque à la plus courte (aucune erreur).
- `dezip (zip [1; 2; 3] [4; 5])` → `([1; 2], [4; 5])` : le `3` est perdu.
- `List.combine [1] [2]` → `[(1, 2)]` ; mais `List.combine` lève `Invalid_argument` si les longueurs diffèrent.
- `[1, 2, 3]` → `[(1, 2, 3)]` : une liste d'**un** triplet, pas une liste de trois entiers (séparateur de liste : `;`).
- `(1, 2, 3) = (1, (2, 3))` ne compile pas : un triplet et une paire sont de types différents.

---

## 18. Type somme énuméré

**Énoncé** : un feu de circulation qui avance d'état en état.

```ocaml
type feu = Vert | Jaune | Rouge

let suivant (f : feu) : feu =
  match f with Vert -> Jaune | Jaune -> Rouge | Rouge -> Vert

let rec avancer (n : int) (f : feu) : feu =
  if n = 0 then f else avancer (n - 1) (suivant f)
```

**Trace** `avancer 4 Vert` : `Vert` → (3) `Jaune` → (2) `Rouge` → (1) `Vert` → (0) `Jaune`.

**Pièges**
- `avancer 4 Vert` → `Jaune` ; `avancer 3 Jaune` → `Jaune` (un cycle complet de 3 revient au départ).
- `List.map suivant [Vert; Rouge]` → `[Jaune; Vert]`.
- `Vert < Rouge` → `true` et `compare Rouge Jaune` → `1` : la comparaison suit l'**ordre de déclaration** des constructeurs.

---

## 19. Composition de fonctions

**Énoncé** : composer deux fonctions, et lire `@@` et `|>`.

```ocaml
let compose (f : 'b -> 'c) (g : 'a -> 'b) : 'a -> 'c = fun x -> f (g x)
let double (n : int) : int = n * 2
let incr1 (n : int) : int = n + 1
```

**Trace** `compose double incr1 5` = `double (incr1 5)` = `double 6` = `12`.

**Pièges**
- `compose double incr1 5` → `12`, mais `compose incr1 double 5` → `11` : `compose f g` applique **g d'abord**.
- `(compose string_of_int double) 4` → `"8"`.
- `List.map (compose double incr1) [1; 2]` → `[4; 6]`.
- `double @@ incr1 3` → `8` et `3 |> incr1 |> double` → `8` : `@@` applique à droite, `|>` passe la valeur de gauche à droite (même résultat ici, ordre de lecture inverse).

---

## 20. Recherche avec `option`

**Énoncé** : premier élément qui satisfait un prédicat.

```ocaml
let rec trouver (p : 'a -> bool) (l : 'a list) : 'a option =
  match l with
  | [] -> None
  | x :: r -> if p x then Some x else trouver p r
```

**Trace** `trouver (fun x -> x > 2) [1; 5; 3]` : `1 > 2` non ; `5 > 2` oui → `Some 5` (le `3` n'est jamais examiné).

**Pièges**
- `trouver (fun x -> x > 2) [1; 5; 3]` → `Some 5` (le **premier**, pas le plus grand) ; avec `x > 9` → `None`.
- `List.find_opt (fun x -> x > 2) [1; 5; 3]` → `Some 5` ; `List.mem 3 [1; 2; 3]` → `true`.
- `trouver (fun s -> String.length s = 2) ["abc"; "de"; "fg"]` → `Some "de"`.

---

## 21. Hauteur et pli sur un arbre

**Énoncé** : calculer la hauteur et la somme d'un arbre avec une fonction de pli générique (`arbre` de l'exemple 3).

```ocaml
let rec hauteur (t : 'a abr) : int =
  match t with
  | Feuille -> 0
  | Noeud (g, _, d) -> 1 + max (hauteur g) (hauteur d)

let rec plier (f : 'b -> 'a -> 'b -> 'b) (vide : 'b) (t : 'a abr) : 'b =
  match t with
  | Feuille -> vide
  | Noeud (g, v, d) -> f (plier f vide g) v (plier f vide d)

let somme_arbre (t : int abr) : int = plier (fun g v d -> g + v + d) 0 t
```

**Trace** `somme_arbre arbre` (racine 5, gauche : 2 avec 1, droite : 8) : sous-arbre `1` : `0 + 1 + 0 = 1` ;
sous-arbre `2` : `1 + 2 + 0 = 3` ; sous-arbre `8` : `8` ; racine : `3 + 5 + 8 = 16`.

**Pièges**
- `hauteur arbre` → `3` ; `hauteur (Feuille : int abr)` → `0` (un arbre vide, pas `1`).
- `somme_arbre arbre` → `16`.
- `plier (fun g _ d -> 1 + max g d) 0 arbre` → `3` : `hauteur` est un cas particulier de `plier`.
- Un ABR formé de `[1; 2; 3; 4]` insérés dans cet ordre a pour hauteur `4`.

---

## 22. Évaluateur avec variables et `let`

**Énoncé** : évaluer des expressions avec liaisons locales ; `None` si une variable est inconnue.

```ocaml
type expr2 =
  | N of int
  | V of string
  | Plus of expr2 * expr2
  | Soit of string * expr2 * expr2

let rec eval2 (env : (string * int) list) (e : expr2) : int option =
  match e with
  | N n -> Some n
  | V x -> List.assoc_opt x env
  | Plus (a, b) ->
    (match eval2 env a, eval2 env b with
     | Some x, Some y -> Some (x + y)
     | _ -> None)
  | Soit (x, a, b) ->
    Option.bind (eval2 env a) (fun v -> eval2 ((x, v) :: env) b)
```

**Trace** `eval2 [] (Soit ("x", N 2, Plus (V "x", V "x")))` : `eval2 [] (N 2) = Some 2` ; on évalue le corps dans `[("x", 2)]` :
`Plus (V "x", V "x")` → `Some 2` et `Some 2` → `Some 4`.

**Pièges**
- Le `Soit` ci-dessus → `Some 4` ; `eval2 [] (Plus (V "y", N 1))` → `None`.
- `Soit ("x", N 1, Soit ("x", Plus (V "x", N 10), V "x"))` → `Some 11` : le `x` intérieur masque l'extérieur, et son initialisation voit l'ancien `x`.
- `Plus (Soit ("x", N 1, V "x"), V "x")` → `None` : le `x` du `Soit` n'existe pas à droite du `Plus`.

---

## 23. Prendre, laisser, découper en blocs

**Énoncé** : découper une liste en blocs de taille `n` (le dernier peut être plus court).

```ocaml
let rec prendre (n : int) (l : 'a list) : 'a list =
  match l with
  | x :: r when n > 0 -> x :: prendre (n - 1) r
  | _ -> []

let rec laisser (n : int) (l : 'a list) : 'a list =
  match l with
  | _ :: r when n > 0 -> laisser (n - 1) r
  | _ -> l

let rec blocs (n : int) (l : 'a list) : 'a list list =
  match l with
  | [] -> []
  | _ -> prendre n l :: blocs n (laisser n l)
```

**Trace** `blocs 2 [1; 2; 3]` : `prendre 2 [1;2;3] = [1; 2]` ; `laisser 2 [1;2;3] = [3]` ; `blocs 2 [3] = [3] :: blocs 2 []` = `[[3]]`.
Résultat `[[1; 2]; [3]]`.

**Pièges**
- `blocs 2 [1; 2; 3; 4; 5]` → `[[1; 2]; [3; 4]; [5]]` ; `blocs 3 []` → `[]`.
- `prendre 5 [1; 2]` → `[1; 2]` (pas d'erreur) ; `laisser (-1) [1; 2]` → `[1; 2]`.
- Attention : `blocs 0 [1]` ne termine pas (`laisser 0 l = l`, la liste ne diminue jamais).

---

## 24. Chaînes et caractères

**Énoncé** : tester si une phrase est un palindrome (insensible à la casse, espaces ignorés).

```ocaml
let eclater (s : string) : char list = List.of_seq (String.to_seq s)

let est_palindrome (s : string) : bool =
  let l = List.filter (fun c -> c <> ' ') (eclater (String.lowercase_ascii s)) in
  l = List.rev l
```

**Trace** `est_palindrome "Ab a"` : minuscules `"ab a"` → `['a'; 'b'; ' '; 'a']` → sans espaces `['a'; 'b'; 'a']` ; `List.rev` donne la même liste → `true`.

**Pièges**
- `est_palindrome "Esope reste ici et se repose"` → `true` ; `est_palindrome "ab"` → `false` ; `est_palindrome ""` → `true`.
- `String.length "hé"` → `3` et `eclater "hé"` → `['h'; '\195'; '\169']` : les chaînes OCaml sont des **octets** (le `é` en UTF-8 en prend deux).
- `"ab" ^ "c" = "abc"` → `true` (`^` concatène, `=` compare le contenu) ; `'a' < 'b'` → `true` ; `String.make 3 'x'` → `"xxx"`.

---

## 25. Triangle de Pascal

**Énoncé** : produire les `n` premières lignes du triangle de Pascal.

```ocaml
let rec somme_listes (a : int list) (b : int list) : int list =
  match a, b with
  | [], l | l, [] -> l
  | x :: ra, y :: rb -> (x + y) :: somme_listes ra rb

let ligne_suivante (l : int list) : int list = somme_listes (0 :: l) (l @ [0])

let rec pascal (n : int) : int list list =
  if n = 0 then []
  else
    let precedent = pascal (n - 1) in
    precedent @ [match List.rev precedent with
                 | [] -> [1]
                 | derniere :: _ -> ligne_suivante derniere]
```

**Trace** `ligne_suivante [1; 2; 1]` : `0 :: l = [0; 1; 2; 1]` et `l @ [0] = [1; 2; 1; 0]` ; somme terme à terme : `[1; 3; 3; 1]`.

**Pièges**
- `somme_listes [1; 2; 3] [10]` → `[11; 2; 3]` : la liste la plus longue garde sa queue (cas `l, []`).
- `ligne_suivante [1]` → `[1; 1]`.
- `pascal 4` → `[[1]; [1; 1]; [1; 2; 1]; [1; 3; 3; 1]]` ; `pascal 0` → `[]`.

---

### Rappels rapides pour le QCM

- `=` compare la **structure** (jamais `==` en classe) ; `<>` est son contraire.
- `@` est en temps linéaire dans la liste de gauche ; `::` est en temps constant.
- `fold_left` : accumulateur à **gauche** (`f (f (f init a) b) c`) ; `fold_right` : `f a (f b (f c init))`.
- Un `match` imbriqué sans parenthèses « avale » les cas suivants : mets des parenthèses.
- Une fonction à `n` arguments appliquée à moins de `n` arguments est une fonction, pas une erreur.
