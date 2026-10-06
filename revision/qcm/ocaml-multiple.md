# Banque de QCM — OCaml à réponses multiples

44 questions au format de l'examen : « cochez la ou les réponses qui s'appliquent », de 0 à 4 bonnes.
Les types et valeurs ont été vérifiés dans le toplevel OCaml 5.5.1.

---

**1.** Soit `let compose f g x = f (g x)`. Lesquelles de ces affirmations sont vraies ?

- **A)** `compose : ('a -> 'b) -> ('c -> 'a) -> 'c -> 'b`
- **B)** `compose (fun n -> n + 1) String.length "abc"` s'évalue à `4`
- **C)** `f` et `g` doivent avoir exactement le même type
- **D)** `compose succ succ 0` s'évalue à `2`

<details>
<summary>Réponse</summary>

**Bonnes : A, B, D** *Concept : Dérivation du type d'une composition.*

- **A.** Vrai : `g` produit un `'a` que `f` consomme, et `x : 'c`.
- **B.** Vrai : `String.length "abc"` vaut 3, puis `+ 1` donne 4.
- **C.** Faux : seul le résultat de `g` doit correspondre à l'argument de `f`. Ici `g` va de `string` à `int`.
- **D.** Vrai : `succ (succ 0)` vaut 2.

</details>

---

**2.** Soit `let flip f x y = f y x`. Lesquelles sont vraies ?

- **A)** `flip : ('a -> 'b -> 'c) -> 'b -> 'a -> 'c`
- **B)** `flip (-) 1 10` s'évalue à `9`
- **C)** `flip (^) "x" "y"` s'évalue à `"yx"`
- **D)** `flip` prend un couple en argument

<details>
<summary>Réponse</summary>

**Bonnes : A, B, C** *Concept : Fonctions curryfiées et arguments inversés.*

- **A.** Vrai : `f` attend d'abord un `'a`, puis un `'b` ; `flip` les reçoit dans l'ordre inverse.
- **B.** Vrai : `flip (-) 1 10` calcule `(-) 10 1`.
- **C.** Vrai : `flip (^) "x" "y"` calcule `"y" ^ "x"`.
- **D.** Faux : `flip` est curryfiée, comme la plupart des fonctions OCaml : aucun `(x, y)` dans sa définition.

</details>

---

**3.** Lesquelles de ces expressions ont le type `'a -> 'a` ?

- **A)** `fun x -> x`
- **B)** `fun x -> x + 0`
- **C)** `let rec f x = f x in f`
- **D)** `fun x -> let y = x in y`

<details>
<summary>Réponse</summary>

**Bonnes : A, D** *Concept : Types polymorphes ; `'a -> 'b` n'est pas `'a -> 'a`.*

- **A.** Vrai : la fonction identité.
- **B.** Faux : `+` impose `int -> int`.
- **C.** Faux : le type est `'a -> 'b` : la fonction ne retourne jamais, donc rien ne lie son résultat à son argument.
- **D.** Vrai : `y` a le type de `x`, qui est retourné tel quel.

</details>

---

**4.** Lesquelles de ces expressions ont le type `'a -> 'b -> 'a` ?

- **A)** `fun x _ -> x`
- **B)** `fun x y -> (x, y)`
- **C)** `fun x y -> if true then x else y`
- **D)** `fun x y -> fst (x, y)`

<details>
<summary>Réponse</summary>

**Bonnes : A, D** *Concept : Les deux branches d'un `if` doivent s'accorder.*

- **A.** Vrai : retourne le premier argument, ignore le second.
- **B.** Faux : le type est `'a -> 'b -> 'a * 'b`.
- **C.** Faux : les deux branches d'un `if` ont le même type : `'a -> 'a -> 'a`.
- **D.** Vrai : `fst (x, y)` est `x`, et `y` reste de type libre.

</details>

---

**5.** Lesquelles de ces définitions de premier niveau donnent un type avec une variable faible (`'_weak1`) ?

- **A)** `let r = ref []`
- **B)** `let l = []`
- **C)** `let f = List.map (fun x -> x)`
- **D)** `let g = fun x -> x`

<details>
<summary>Réponse</summary>

**Bonnes : A, C** *Concept : Restriction de la valeur.*

- **A.** Vrai : `ref []` est une application, pas une valeur : `'_weak1 list ref`.
- **B.** Faux : `[]` est une valeur, donc généralisée : `'a list`.
- **C.** Vrai : application partielle : `'_weak1 list -> '_weak1 list`.
- **D.** Faux : `fun x -> x` est une valeur (une fonction) : `'a -> 'a`.

</details>

---

**6.** Lesquelles de ces expressions sont mal typées ?

- **A)** `[1; "a"]`
- **B)** `[1, "a"]`
- **C)** `if true then 1 else 2.0`
- **D)** `1 + 2.0`

<details>
<summary>Réponse</summary>

**Bonnes : A, C, D** *Concept : Listes homogènes, virgule contre point-virgule.*

- **A.** Vrai : mal typée : liste hétérogène.
- **B.** Faux : bien typée : la virgule fait un couple : `(int * string) list` à un élément.
- **C.** Vrai : mal typée : les deux branches d'un `if` doivent avoir le même type.
- **D.** Vrai : mal typée : `+` est entier ; il faut `+.` pour les flottants.

</details>

---

**7.** Lesquelles de ces expressions ont le type `int list` ?

- **A)** `[1; 2; 3]`
- **B)** `1 :: 2 :: []`
- **C)** `[1] @ [2; 3]`
- **D)** `List.map succ [0]`

<details>
<summary>Réponse</summary>

**Bonnes : A, B, C, D** *Concept : Quatre façons de produire une liste.*

- **A.** Vrai : liste littérale.
- **B.** Vrai : `::` est associatif à droite : `1 :: (2 :: [])`.
- **C.** Vrai : `@` concatène deux `int list`.
- **D.** Vrai : `succ : int -> int`, donc `map` retourne une `int list`.

</details>

---

**8.** À propos de `[1, 2, 3]`, lesquelles sont vraies ?

- **A)** Son type est `(int * int * int) list`
- **B)** Son type est `int list`
- **C)** Elle ne contient qu'un seul élément
- **D)** Elle est égale à `[1; 2; 3]`

<details>
<summary>Réponse</summary>

**Bonnes : A, C** *Concept : Virgule contre point-virgule.*

- **A.** Vrai : c'est une liste d'un triplet.
- **B.** Faux : c'est ce que donnerait `[1; 2; 3]`.
- **C.** Vrai : le triplet `(1, 2, 3)`.
- **D.** Faux : les types diffèrent : la comparaison est même rejetée par le typeur.

</details>

---

**9.** Lesquelles de ces égalités sont vraies ?

- **A)** `List.fold_left (fun a x -> x :: a) [] [1; 2; 3] = [3; 2; 1]`
- **B)** `List.fold_right (fun x a -> x :: a) [1; 2; 3] [] = [1; 2; 3]`
- **C)** `List.fold_left (-) 10 [1; 2; 3] = 4`
- **D)** `List.fold_right (-) [1; 2; 3] 10 = 8`

<details>
<summary>Réponse</summary>

**Bonnes : A, B, C** *Concept : `fold_left` contre `fold_right`.*

- **A.** Vrai : `fold_left` consomme de gauche à droite et empile devant : inversion.
- **B.** Vrai : `fold_right` traite le dernier élément en premier et reconstruit la liste.
- **C.** Vrai : `((10 - 1) - 2) - 3 = 4`.
- **D.** Faux : c'est `1 - (2 - (3 - 10))`, soit `-8`.

</details>

---

**10.** Lesquelles de ces fonctions sont récursives terminales ?

- **A)** `let rec sum acc = function [] -> acc | h :: t -> sum (acc + h) t`
- **B)** `let rec len = function [] -> 0 | _ :: t -> 1 + len t`
- **C)** `let rec fact n = if n = 0 then 1 else n * fact (n - 1)`
- **D)** `let rec last = function [x] -> x | _ :: t -> last t | [] -> failwith "vide"`

<details>
<summary>Réponse</summary>

**Bonnes : A, D** *Concept : Position terminale.*

- **A.** Vrai : l'appel récursif est la dernière opération.
- **B.** Faux : après l'appel, il reste le `1 + ...`.
- **C.** Faux : après l'appel, il reste la multiplication par `n`.
- **D.** Vrai : l'appel `last t` est la valeur retournée telle quelle.

</details>

---

**11.** À propos de la récursion terminale, lesquelles sont vraies ?

- **A)** Dans `1 + len t`, l'appel à `len` est en position terminale
- **B)** `List.fold_left` est récursive terminale
- **C)** `List.fold_right` n'est pas récursive terminale (pile qui déborde sur une très longue liste)
- **D)** Un accumulateur est la technique usuelle pour rendre une récursion terminale

<details>
<summary>Réponse</summary>

**Bonnes : B, C, D** *Concept : Récursion terminale et pile.*

- **A.** Faux : l'addition est effectuée après le retour de l'appel.
- **B.** Vrai : l'accumulateur est passé à l'appel suivant.
- **C.** Vrai : vérifié : avec une pile réduite, `fold_right` déborde sur 3 millions d'éléments, pas `fold_left`.
- **D.** Vrai : on porte le résultat partiel en argument.

</details>

---

**12.** Lesquelles de ces fonctions provoquent l'avertissement 8 (filtrage non exhaustif) ?

- **A)** `function [x] -> x | _ :: t -> 0`
- **B)** `function [] -> 0 | h :: _ -> h`
- **C)** `function Some x -> x`
- **D)** `function 0 -> "z" | n when n > 0 -> "p"`

<details>
<summary>Réponse</summary>

**Bonnes : A, C, D** *Concept : Exhaustivité du filtrage.*

- **A.** Vrai : la liste vide n'est pas couverte.
- **B.** Faux : `[]` et `h :: _` couvrent toutes les listes.
- **C.** Vrai : `None` n'est pas couvert.
- **D.** Vrai : une garde ne compte pas pour l'exhaustivité : les négatifs ne sont pas couverts.

</details>

---

**13.** Soit `let f = function (0, _) -> 0 | (_, 0) -> 1 | _ -> 2`. Lesquelles sont vraies ?

- **A)** `f (0, 0) = 0`
- **B)** `f (0, 0) = 1`
- **C)** `f (3, 0) = 1`
- **D)** `f (0, 3) = 2`

<details>
<summary>Réponse</summary>

**Bonnes : A, C** *Concept : Les cas d'un filtrage sont essayés dans l'ordre.*

- **A.** Vrai : le premier cas qui convient gagne.
- **B.** Faux : le premier cas gagne.
- **C.** Vrai : le premier cas échoue (3 n'est pas 0), le deuxième réussit.
- **D.** Faux : le premier cas réussit : résultat 0.

</details>

---

**14.** Que se passe-t-il avec `let f x = if x > 0 then "pos"` ?

- **A)** Type `int -> string`
- **B)** Type `int -> string option`
- **C)** Retourne `()` quand `x <= 0`
- **D)** Erreur de typage : sans `else`, la branche `then` doit être de type `unit`

<details>
<summary>Réponse</summary>

**Bonnes : D** *Concept : `if` sans `else`.*

- **A.** Faux : sans `else`, le résultat implicite est `()`, de type `unit`, incompatible avec `string`.
- **B.** Faux : OCaml ne fabrique jamais d'option de lui-même.
- **C.** Faux : vrai seulement si la branche `then` est elle-même `unit`, ce qui n'est pas le cas ici.
- **D.** Vrai : vérifié au toplevel.

</details>

---

**15.** Lesquelles de ces égalités sont vraies ?

- **A)** `List.assoc_opt 3 [(1, "a")] = None`
- **B)** `List.assoc 3 [(1, "a")]` retourne `None`
- **C)** `List.find_opt (fun x -> x > 5) [1; 2] = None`
- **D)** `Option.value ~default:0 None = 0`

<details>
<summary>Réponse</summary>

**Bonnes : A, C, D** *Concept : Fonctions partielles contre options.*

- **A.** Vrai : la clé 3 est absente.
- **B.** Faux : `List.assoc` lève `Not_found`, il ne retourne pas d'option.
- **C.** Vrai : aucun élément ne convient.
- **D.** Vrai : `None` est remplacé par la valeur par défaut.

</details>

---

**16.** Soit `let f x = match x with Some y -> y | None -> 0`. Lesquelles sont vraies ?

- **A)** `f : int option -> int`
- **B)** `f None = 0`
- **C)** `f (Some None)` est mal typé
- **D)** `f 3` est bien typé

<details>
<summary>Réponse</summary>

**Bonnes : A, B, C** *Concept : Type option.*

- **A.** Vrai : `y` est retourné, et l'autre branche retourne `0`.
- **B.** Vrai : deuxième cas.
- **C.** Vrai : `Some None` est un `'a option option`.
- **D.** Faux : `3` n'est pas une option.

</details>

---

**17.** Soit `let f = function Some (Some x) -> x | _ -> 0`. Quels appels sont bien typés ?

- **A)** `f (Some (Some 1))`
- **B)** `f (Some 1)`
- **C)** `f None`
- **D)** `f (Some None)`

<details>
<summary>Réponse</summary>

**Bonnes : A, C, D** *Concept : Options imbriquées.*

- **A.** Vrai : `int option option`.
- **B.** Faux : un seul niveau de `Some` : `int option`.
- **C.** Vrai : `None : 'a option option`.
- **D.** Vrai : `Some None : 'a option option`.

</details>

---

**18.** Lesquelles de ces expressions valent `true` ?

- **A)** `[1; 2; 3] = [1; 2; 3]`
- **B)** `[1; 2; 3] == [1; 2; 3]`
- **C)** `1 == 1`
- **D)** `[] == []`

<details>
<summary>Réponse</summary>

**Bonnes : A, C, D** *Concept : Égalité structurelle contre physique.*

- **A.** Vrai : égalité structurelle.
- **B.** Faux : deux listes allouées séparément ne sont pas physiquement identiques (vérifié : `false`).
- **C.** Vrai : les entiers sont des valeurs immédiates.
- **D.** Vrai : `[]` est une valeur immédiate.

</details>

---

**19.** Pourquoi le guide de style proscrit-il `==` ?

- **A)** Il compare l'identité en mémoire pour les valeurs allouées
- **B)** Sur des entiers, il se comporte comme `=`
- **C)** Sur deux listes égales construites séparément, il retourne `true`
- **D)** Il fait partie des constructions proscrites du guide de style

<details>
<summary>Réponse</summary>

**Bonnes : A, B, D** *Concept : Égalité physique.*

- **A.** Vrai : identité, pas contenu.
- **B.** Vrai : d'où le piège : ça semble marcher sur les petits exemples.
- **C.** Faux : c'est `false`.
- **D.** Vrai : avec `for`, `while`, `ref`, `:=`, `array` et `!=`.

</details>

---

**20.** Lesquelles de ces affirmations sont vraies ?

- **A)** `7 / (-2)` vaut `-3`
- **B)** `(-7) mod 3` vaut `-1`
- **C)** `7 / 2` vaut `3.5`
- **D)** `1.5 +. 2.` vaut `3.5`

<details>
<summary>Réponse</summary>

**Bonnes : A, B, D** *Concept : Arithmétique entière et flottante.*

- **A.** Vrai : division entière tronquée vers zéro.
- **B.** Vrai : le signe suit le dividende.
- **C.** Faux : `/` est entière : `3`, et `3.5` est de type `float`.
- **D.** Vrai : opérateur flottant.

</details>

---

**21.** Lesquelles de ces expressions ont le type `unit` ?

- **A)** `print_string "a"`
- **B)** `List.iter print_int [1; 2]`
- **C)** `ref 0`
- **D)** `()`

<details>
<summary>Réponse</summary>

**Bonnes : A, B, D** *Concept : Effets secondaires et `unit`.*

- **A.** Vrai : une fonction d'affichage retourne `unit`.
- **B.** Vrai : `List.iter` retourne `unit`.
- **C.** Faux : c'est un `int ref`.
- **D.** Vrai : la seule valeur de `unit`.

</details>

---

**22.** Lesquelles de ces constructions sont proscrites dans le style du cours ?

- **A)** `for`
- **B)** `List.map`
- **C)** `while`
- **D)** `ref`

<details>
<summary>Réponse</summary>

**Bonnes : A, C, D** *Concept : Style proscrit.*

- **A.** Vrai : boucle impérative.
- **B.** Faux : fonction d'ordre supérieur, encouragée.
- **C.** Vrai : boucle impérative.
- **D.** Vrai : état mutable (avec `:=`).

</details>

---

**23.** Lesquelles de ces affirmations sur les fonctions partielles sont vraies ?

- **A)** `List.hd` est une fonction partielle
- **B)** `List.hd []` lève `Failure "hd"`
- **C)** `List.map` est une fonction partielle
- **D)** Un filtrage qui traite `[]` explicitement évite le besoin de `List.hd`

<details>
<summary>Réponse</summary>

**Bonnes : A, B, D** *Concept : Fonctions partielles proscrites.*

- **A.** Vrai : elle n'est pas définie sur la liste vide.
- **B.** Vrai : vérifié au toplevel.
- **C.** Faux : elle est définie sur toutes les listes.
- **D.** Vrai : `[] -> ...` et `h :: _ -> ...` couvrent tous les cas.

</details>

---

**24.** Lesquelles de ces expressions sont bien typées ?

- **A)** `1 + 2.0`
- **B)** `"a" + "b"`
- **C)** `[1; 2.0]`
- **D)** `1 :: ["a"]`

<details>
<summary>Réponse</summary>

**Bonnes : aucune** *Concept : Erreurs de typage courantes.*

- **A.** Faux : `+` est entier.
- **B.** Faux : la concaténation est `^`.
- **C.** Faux : liste hétérogène.
- **D.** Faux : `::` exige que la queue soit une `int list`.

</details>

---

**25.** Lesquelles de ces fonctions ont le type `int -> int` ?

- **A)** `fun x -> x +. 1.`
- **B)** `fun x -> x ^ "a"`
- **C)** `fun (x, y) -> x + y`
- **D)** `fun x -> [x]`

<details>
<summary>Réponse</summary>

**Bonnes : aucune** *Concept : Types des fonctions.*

- **A.** Faux : `float -> float`.
- **B.** Faux : `string -> string`.
- **C.** Faux : `int * int -> int`.
- **D.** Faux : `'a -> 'a list`.

</details>

---

**26.** Lesquelles de ces expressions s'évaluent à `[1; 2; 3]` ?

- **A)** `[1; 2] :: [3]`
- **B)** `[1] :: [2; 3]`
- **C)** `1 :: 2 :: 3`
- **D)** `[1, 2, 3]`

<details>
<summary>Réponse</summary>

**Bonnes : aucune** *Concept : `::` contre `@` contre `,`.*

- **A.** Faux : mal typée : `::` attend une liste d'`int list` à droite.
- **B.** Faux : mal typée : `[2; 3]` n'est pas une liste de listes.
- **C.** Faux : mal typée : `3` n'est pas une liste.
- **D.** Faux : c'est une liste d'un triplet.

</details>

---

**27.** Soit `let add x y = x + y` et `let inc = add 1`. Lesquelles sont vraies ?

- **A)** `inc : int -> int`
- **B)** `inc 2 = 3`
- **C)** `add 1` est une erreur car il manque un argument
- **D)** `List.map (add 10) [1; 2] = [11; 12]`

<details>
<summary>Réponse</summary>

**Bonnes : A, B, D** *Concept : Application partielle.*

- **A.** Vrai : application partielle.
- **B.** Vrai : `add 1 2`.
- **C.** Faux : c'est une application partielle, parfaitement valide.
- **D.** Vrai : `add 10` est une fonction de `int` vers `int`.

</details>

---

**28.** Soit `let f (x, y) = x + y` et `let g x y = x + y`. Lesquelles sont vraies ?

- **A)** `f : int * int -> int`
- **B)** `g : int -> int -> int`
- **C)** `f 1 2` est valide
- **D)** `g 1` est valide

<details>
<summary>Réponse</summary>

**Bonnes : A, B, D** *Concept : Couple contre curryfication.*

- **A.** Vrai : `f` prend un couple.
- **B.** Vrai : `g` est curryfiée.
- **C.** Faux : `f` attend un couple : `f (1, 2)`.
- **D.** Vrai : retourne `int -> int`.

</details>

---

**29.** Soit `let dup f = fun x -> f x x`. Lesquelles sont vraies ?

- **A)** `dup : ('a -> 'a -> 'b) -> 'a -> 'b`
- **B)** `dup (+) 3 = 6`
- **C)** `dup (^) "ab" = "abab"`
- **D)** `dup (+) "x"` est bien typé

<details>
<summary>Réponse</summary>

**Bonnes : A, B, C** *Concept : Types d'ordre supérieur.*

- **A.** Vrai : `f` reçoit deux fois `x`.
- **B.** Vrai : `3 + 3`.
- **C.** Vrai : `"ab" ^ "ab"`.
- **D.** Faux : `(+)` attend des `int`.

</details>

---

**30.** Soit `let seq f g = fun x -> g (f x)`. Lesquelles sont vraies ?

- **A)** `seq : ('a -> 'b) -> ('b -> 'c) -> 'a -> 'c`
- **B)** `seq f g` équivaut à `compose f g`, avec `compose f g x = f (g x)`
- **C)** `seq (fun x -> x + 1) string_of_int 4 = "5"`
- **D)** `seq string_of_int succ 4` est bien typé

<details>
<summary>Réponse</summary>

**Bonnes : A, C** *Concept : Ordre d'application.*

- **A.** Vrai : `f` d'abord, puis `g`.
- **B.** Faux : `seq f g` équivaut à `compose g f` : l'ordre est inversé.
- **C.** Vrai : `4 + 1` puis conversion.
- **D.** Faux : `succ` ne prend pas de `string`.

</details>

---

**31.** À propos de `List.map`, lesquelles sont vraies ?

- **A)** `List.map (fun x -> x * 2) [1; 2; 3] = [2; 4; 6]`
- **B)** `List.map : ('a -> 'b) -> 'a list -> 'b list`
- **C)** `List.map List.length [[1; 2]; [3]] = [3]`
- **D)** `List.map` modifie la liste en place

<details>
<summary>Réponse</summary>

**Bonnes : A, B** *Concept : `List.map`.*

- **A.** Vrai : doublement de chaque élément.
- **B.** Vrai : signature standard.
- **C.** Faux : c'est `[2; 1]`.
- **D.** Faux : les listes sont immuables : `map` en construit une nouvelle.

</details>

---

**32.** Lesquelles de ces égalités sont vraies ?

- **A)** `List.filter (fun x -> x mod 2 = 0) [1; 2; 3; 4] = [2; 4]`
- **B)** `List.for_all (fun x -> x > 0) [] = true`
- **C)** `List.exists (fun x -> x > 0) [] = false`
- **D)** `List.partition (fun x -> x > 1) [1; 2; 3] = ([1], [2; 3])`

<details>
<summary>Réponse</summary>

**Bonnes : A, B, C** *Concept : Fonctions d'ordre supérieur sur les listes.*

- **A.** Vrai : les pairs.
- **B.** Vrai : un `for_all` sur le vide est vrai.
- **C.** Vrai : aucun élément, donc aucun témoin.
- **D.** Faux : `partition` retourne d'abord ceux qui satisfont le prédicat : `([2; 3], [1])`.

</details>

---

**33.** À propos de `::` et `@`, lesquelles sont vraies ?

- **A)** `1 :: [2; 3] = [1; 2; 3]`
- **B)** `[1] @ [2; 3] = [1; 2; 3]`
- **C)** `::` s'exécute en temps constant
- **D)** Le coût de `@` ne dépend pas de la longueur du premier argument

<details>
<summary>Réponse</summary>

**Bonnes : A, B, C** *Concept : Coût des opérations sur les listes.*

- **A.** Vrai : ajout en tête.
- **B.** Vrai : concaténation.
- **C.** Vrai : un seul bloc est alloué.
- **D.** Faux : `@` recopie son premier argument : coût linéaire en sa longueur.

</details>

---

**34.** Soit `type forme = Cercle of float | Rect of float * float`. Lesquelles de ces expressions sont acceptées ?

- **A)** `Cercle 1.0`
- **B)** `Rect (1., 2.)`
- **C)** `Rect 1. 2.`
- **D)** `Cercle (1, 2)`

<details>
<summary>Réponse</summary>

**Bonnes : A, B** *Concept : Constructeurs de types somme.*

- **A.** Vrai : de type `forme`.
- **B.** Vrai : le constructeur prend un couple.
- **C.** Faux : erreur de syntaxe au toplevel : les arguments sont un couple.
- **D.** Faux : un couple n'est pas un `float`.

</details>

---

**35.** Soit `type forme = Cercle of float | Rect of float * float` et `let aire = function Cercle r -> 3.14 *. r *. r`. Lesquelles sont vraies ?

- **A)** Le compilateur émet l'avertissement 8
- **B)** `aire : forme -> float`
- **C)** `aire (Rect (1., 2.))` lève `Match_failure`
- **D)** Le compilateur refuse la définition

<details>
<summary>Réponse</summary>

**Bonnes : A, B, C** *Concept : Filtrage non exhaustif.*

- **A.** Vrai : `Rect` n'est pas couvert.
- **B.** Vrai : le type est correct.
- **C.** Vrai : vérifié au toplevel.
- **D.** Faux : c'est un avertissement, pas une erreur.

</details>

---

**36.** Lesquelles de ces affirmations sont vraies ?

- **A)** `let x = 5 in let x = x + 1 in x * 2` vaut `12`
- **B)** Le second `x` modifie la valeur du premier
- **C)** Le second `x` masque le premier dans sa portée
- **D)** `let x = 1 in (let x = 2 in x) + x` vaut `3`

<details>
<summary>Réponse</summary>

**Bonnes : A, C, D** *Concept : Liaison `let` et masquage.*

- **A.** Vrai : `x` vaut 6 dans le corps, puis `6 * 2`.
- **B.** Faux : rien n'est modifié : il y a deux liaisons distinctes.
- **C.** Vrai : le masquage ne dure que dans la portée du second `let`.
- **D.** Vrai : `2 + 1`.

</details>

---

**37.** Soit `let rec map f = function [] -> [] | h :: t -> f h :: map f t`. Lesquelles sont vraies ?

- **A)** `map : ('a -> 'b) -> 'a list -> 'b list`
- **B)** `map` est récursive terminale
- **C)** L'appel `map f t` n'est pas terminal, car `::` s'applique ensuite
- **D)** `map` a le même type que `List.map`

<details>
<summary>Réponse</summary>

**Bonnes : A, C, D** *Concept : Récursion naïve sur les listes.*

- **A.** Vrai : type général.
- **B.** Faux : après l'appel, il faut construire la cellule.
- **C.** Vrai : le résultat doit encore être consommé par `::`.
- **D.** Vrai : `List.map` a ce type.

</details>

---

**38.** Lesquelles de ces expressions ont le type `'a -> 'a list` ?

- **A)** `fun x -> [x]`
- **B)** `fun x -> x :: []`
- **C)** `fun x -> [x; x + 1]`
- **D)** `fun x -> [x; "a"]`

<details>
<summary>Réponse</summary>

**Bonnes : A, B** *Concept : Types polymorphes de listes.*

- **A.** Vrai : liste singleton.
- **B.** Vrai : équivalent.
- **C.** Faux : `x + 1` force `int -> int list`.
- **D.** Faux : `string -> string list`.

</details>

---

**39.** Soit `let eq x y = x = y`. Lesquelles sont vraies ?

- **A)** `eq : 'a -> 'a -> bool`
- **B)** `eq 1 "a"` est mal typé
- **C)** `eq [1] [1] = true`
- **D)** `eq` compare l'identité en mémoire

<details>
<summary>Réponse</summary>

**Bonnes : A, B, C** *Concept : Égalité structurelle polymorphe.*

- **A.** Vrai : les deux arguments ont le même type.
- **B.** Vrai : types différents.
- **C.** Vrai : égalité structurelle.
- **D.** Faux : c'est `=`, non `==`.

</details>

---

**40.** Soit `let comptes l = List.map List.length l`. Lesquelles sont vraies ?

- **A)** `comptes : 'a list list -> int list`
- **B)** `comptes [[1; 2]; [3]] = [2; 1]`
- **C)** `comptes [] = []`
- **D)** `comptes [["a"]] = [1]`

<details>
<summary>Réponse</summary>

**Bonnes : A, B, C, D** *Concept : Polymorphisme.*

- **A.** Vrai : `'a` quelconque, résultat toujours `int list`.
- **B.** Vrai : longueur de chaque sous-liste.
- **C.** Vrai : aucune sous-liste.
- **D.** Vrai : `'a` instancié à `string`.

</details>

---

**41.** Soit `let h x = x`. Lesquelles sont vraies ?

- **A)** `h : 'a -> 'a`
- **B)** `(h 1, h "a")` est bien typé
- **C)** `h h 3 = 3`
- **D)** `let g = fun x -> x` est aussi polymorphe

<details>
<summary>Réponse</summary>

**Bonnes : A, B, C, D** *Concept : Polymorphisme de `let`.*

- **A.** Vrai : identité.
- **B.** Vrai : `h` est généralisée ; type `int * string`.
- **C.** Vrai : `h h` est l'identité appliquée à elle-même.
- **D.** Vrai : c'est une valeur, donc généralisée.

</details>

---

**42.** Quel est le type de `let rec f x = f x` ?

- **A)** `'a -> 'a`
- **B)** `'a -> 'b`
- **C)** `unit`
- **D)** Ne type pas

<details>
<summary>Réponse</summary>

**Bonnes : B** *Concept : Fonction qui ne termine pas.*

- **A.** Faux : rien ne lie le résultat à l'argument.
- **B.** Vrai : le résultat n'est jamais construit : variable libre.
- **C.** Faux : c'est une fonction.
- **D.** Faux : elle type parfaitement.

</details>

---

**43.** Quel est le type de `List.combine [1; 2] ["a"; "b"]` ?

- **A)** `(int * string) list`
- **B)** `int list * string list`
- **C)** `(int * string) list list`
- **D)** `(int, string) list`

<details>
<summary>Réponse</summary>

**Bonnes : A** *Concept : Couples et listes.*

- **A.** Vrai : liste de couples.
- **B.** Faux : c'est le type de deux listes séparées.
- **C.** Faux : un niveau de trop.
- **D.** Faux : ce n'est pas une syntaxe de type OCaml.

</details>

---

**44.** Quel est le type de `let total f l = List.fold_left (fun a x -> a + f x) 0 l` ?

- **A)** `('a -> int) -> 'a list -> int`
- **B)** `(int -> int) -> int list -> int`
- **C)** `('a -> 'b) -> 'a list -> 'b`
- **D)** `('a -> int) -> 'a list -> 'a`

<details>
<summary>Réponse</summary>

**Bonnes : A** *Concept : Type de `fold_left`.*

- **A.** Vrai : `f` retourne un `int` (à cause de `+`), l'élément est quelconque.
- **B.** Faux : rien ne force `'a = int`.
- **C.** Faux : `+` fige `'b = int`.
- **D.** Faux : le résultat est l'accumulateur.

</details>

---
