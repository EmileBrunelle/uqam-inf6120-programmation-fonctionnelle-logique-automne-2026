# Banque de QCM — OCaml à réponses multiples (suite)

84 questions au format de l'examen : « cochez la ou les réponses qui s'appliquent », de 0 à 4 bonnes.
Les types et valeurs ont été vérifiés dans le toplevel OCaml 5.5.1.

---

**1.** Soit `let apply f x = f x`. Lesquelles sont vraies ?

- **A)** `apply : ('a -> 'b) -> 'a -> 'b`
- **B)** `apply succ 1` s'évalue à `2`
- **C)** `f` doit être de type `int -> int`
- **D)** `apply (+) 1` a le type `int -> int`

<details>
<summary>Réponse</summary>

**Bonnes : A, B, D** *Concept : Inférence pour une fonction d'ordre supérieur.*

- **A.** Vrai : `f` est appliquée à `x`, donc son argument et celui d'`apply` ont le même type.
- **B.** Vrai : `succ 1` vaut 2.
- **C.** Faux : rien dans la définition n'impose `int`.
- **D.** Vrai : `(+) 1` est l'application partielle de `(+) : int -> int -> int`.

</details>

---

**2.** Soit `let pair x y = (x, y)`. Lesquelles sont vraies ?

- **A)** `pair : 'a -> 'b -> 'a * 'b`
- **B)** `let p = pair 1` donne un type avec une variable faible
- **C)** `pair 1 2` s'évalue à `(1, 2)`
- **D)** `pair 1 "a"` a le type `int * int`

<details>
<summary>Réponse</summary>

**Bonnes : A, B, C** *Concept : Type d'une fonction à deux arguments et variable faible.*

- **A.** Vrai : les deux arguments sont indépendants.
- **B.** Vrai : `pair 1` est une application, pas une valeur, donc non généralisée : `'_weak1 -> int * '_weak1`.
- **C.** Vrai.
- **D.** Faux : le type est `int * string`.

</details>

---

**3.** Lesquelles de ces expressions ont le type `'a * 'b -> 'b * 'a` ?

- **A)** `fun (a, b) -> (b, a)`
- **B)** `fun a b -> (b, a)`
- **C)** `fun p -> (snd p, fst p)`
- **D)** `fun (a, b) -> (a, b)`

<details>
<summary>Réponse</summary>

**Bonnes : A, C** *Concept : Fonction sur un couple versus fonction curryfiée.*

- **A.** Vrai : on échange les composantes.
- **B.** Faux : deux paramètres, donc `'a -> 'b -> 'b * 'a`.
- **C.** Vrai : `snd` et `fst` produisent le même échange.
- **D.** Faux : le couple reste dans le même ordre, `'a * 'b -> 'a * 'b`.

</details>

---

**4.** Soit `let k = fun _ -> 0`. Lesquelles sont vraies ?

- **A)** `k : 'a -> int`
- **B)** `k 'c'` s'évalue à `0`
- **C)** `k` a un type avec une variable faible
- **D)** `k` n'accepte que des `int`

<details>
<summary>Réponse</summary>

**Bonnes : A, B** *Concept : Le motif `_` ignore l'argument sans le contraindre.*

- **A.** Vrai : l'argument n'est jamais utilisé, il reste polymorphe.
- **B.** Vrai : n'importe quel argument donne 0.
- **C.** Faux : `fun` est une valeur, le type est généralisé.
- **D.** Faux : `'a` peut être n'importe quel type.

</details>

---

**5.** Soit `let f x = x +. 1.`. Lesquelles sont vraies ?

- **A)** `f : float -> float`
- **B)** `f 1` est une erreur de typage
- **C)** `f 1.` s'évalue à `2.`
- **D)** `f 1. +. 1.` s'évalue à `2.`

<details>
<summary>Réponse</summary>

**Bonnes : A, B, C** *Concept : Opérateurs flottants et entiers distincts.*

- **A.** Vrai : `+.` travaille sur des `float`.
- **B.** Vrai : `1` est un `int`.
- **C.** Vrai.
- **D.** Faux : `f 1.` vaut `2.`, puis `+. 1.` donne `3.`.

</details>

---

**6.** Soit `let rev l = List.fold_left (fun acc x -> x :: acc) [] l`. Lesquelles sont vraies ?

- **A)** `rev : 'a list -> 'a list`
- **B)** `rev [1; 2; 3]` s'évalue à `[3; 2; 1]`
- **C)** `rev ["a"; "b"]` s'évalue à `["a"; "b"]`
- **D)** `rev []` a le type `int list`

<details>
<summary>Réponse</summary>

**Bonnes : A, B** *Concept : `fold_left` avec accumulateur de liste.*

- **A.** Vrai : la fonction est polymorphe en `'a`.
- **B.** Vrai : chaque élément est ajouté en tête de l'accumulateur.
- **C.** Faux : on obtient `["b"; "a"]`.
- **D.** Faux : `rev []` a le type `'a list`, rien ne fixe le type des éléments.

</details>

---

**7.** Soit `let add3 a b c = a + b + c`. Lesquelles sont vraies ?

- **A)** `add3 : int -> int -> int -> int`
- **B)** `add3 1 2` a le type `int -> int`
- **C)** `add3 (1, 2, 3)` est bien typé
- **D)** `let f = add3 1 in f 2 3` s'évalue à `6`

<details>
<summary>Réponse</summary>

**Bonnes : A, B, D** *Concept : Application partielle d'une fonction curryfiée.*

- **A.** Vrai.
- **B.** Vrai : il manque encore le dernier argument.
- **C.** Faux : la fonction attend trois arguments séparés, pas un triplet.
- **D.** Vrai : `add3 1 2 3` vaut 6.

</details>

---

**8.** Soit `let curry f a b = f (a, b)`. Lesquelles sont vraies ?

- **A)** `curry : ('a * 'b -> 'c) -> 'a -> 'b -> 'c`
- **B)** `curry (fun (a, b) -> a + b) 1` a le type `int -> int`
- **C)** `curry (+)` est bien typé
- **D)** `curry fst 1 2` s'évalue à `2`

<details>
<summary>Réponse</summary>

**Bonnes : A, B** *Concept : Curryfication d'une fonction sur un couple.*

- **A.** Vrai.
- **B.** Vrai : on a fourni `f` et `a`, il manque `b`.
- **C.** Faux : `(+)` est déjà curryfiée, elle n'attend pas un couple.
- **D.** Faux : `fst (1, 2)` vaut 1.

</details>

---

**9.** Que vaut `List.map (fun f -> f 2) [succ; pred; (+) 10]` ?

- **A)** `[3; 1; 12]`
- **B)** Une liste de type `(int -> int) list`
- **C)** Une liste de type `int list`
- **D)** `[3; 1; 20]`

<details>
<summary>Réponse</summary>

**Bonnes : A, C** *Concept : Liste de fonctions et application partielle.*

- **A.** Vrai : `succ 2`, `pred 2` et `(+) 10 2`.
- **B.** Faux : chaque fonction est appliquée à 2, le résultat contient des entiers.
- **C.** Vrai.
- **D.** Faux : `10 + 2` vaut 12.

</details>

---

**10.** Soit `let twice f x = f (f x)`. Lesquelles sont vraies ?

- **A)** `twice : ('a -> 'a) -> 'a -> 'a`
- **B)** `twice twice succ 0` s'évalue à `4`
- **C)** `twice List.length` est mal typé
- **D)** `twice (fun s -> s ^ "!") "a"` s'évalue à `"a!"`

<details>
<summary>Réponse</summary>

**Bonnes : A, B, C** *Concept : Fonction appliquée deux fois, type de `f` forcé à `'a -> 'a`.*

- **A.** Vrai : le résultat de `f` est repassé à `f`.
- **B.** Vrai : `twice succ` ajoute 2, puis `twice` de cela ajoute 4.
- **C.** Vrai : `List.length` va de `'a list` à `int`, ce qui n'est pas de la forme `'a -> 'a`.
- **D.** Faux : `f` s'applique deux fois, on obtient `"a!!"`.

</details>

---

**11.** Lesquelles de ces égalités sont vraies (Ordre d'association de `fold_left` et `fold_right`) ?

- **A)** `List.fold_left (-) 10 [1; 2; 3] = 4`
- **B)** `List.fold_right (-) [1; 2; 3] 10 = -8`
- **C)** `List.fold_left (-) 10 [1; 2; 3] = -8`
- **D)** `List.fold_left (fun acc x -> x - acc) 0 [1; 2; 3] = 2`

<details>
<summary>Réponse</summary>

**Bonnes : A, B, D** *Concept : Ordre d'association de `fold_left` et `fold_right`.*

- **A.** Vrai : `((10 - 1) - 2) - 3`.
- **B.** Vrai : `1 - (2 - (3 - 10))`.
- **C.** Faux : `-8` est le résultat de `fold_right`.
- **D.** Vrai : 1 - 0 = 1, puis 2 - 1 = 1, puis 3 - 1 = 2.

</details>

---

**12.** Lesquelles de ces égalités sont vraies (Concaténation avec `fold_left` et `fold_right`) ?

- **A)** `List.fold_left (fun acc x -> acc ^ x) "" ["a"; "b"; "c"] = "abc"`
- **B)** `List.fold_right (fun x acc -> acc ^ x) ["a"; "b"; "c"] "" = "abc"`
- **C)** `List.fold_right (fun x acc -> x ^ acc) ["a"; "b"; "c"] "" = "abc"`
- **D)** `List.fold_left (fun acc x -> x ^ acc) "" ["a"; "b"; "c"] = "cba"`

<details>
<summary>Réponse</summary>

**Bonnes : A, C, D** *Concept : Concaténation avec `fold_left` et `fold_right`.*

- **A.** Vrai : on colle chaque élément à droite, de gauche à droite.
- **B.** Faux : `fold_right` commence par `"c"` et colle à droite, ce qui donne `"cba"`.
- **C.** Vrai : `"a" ^ ("b" ^ ("c" ^ ""))`.
- **D.** Vrai : chaque élément est collé à gauche, le dernier passe en tête.

</details>

---

**13.** Lesquelles de ces signatures de la bibliothèque standard sont correctes ?

- **A)** `List.fold_left : ('a -> 'b -> 'a) -> 'a -> 'b list -> 'a`
- **B)** `List.fold_right : ('a -> 'b -> 'b) -> 'a list -> 'b -> 'b`
- **C)** `List.filter : ('a -> bool) -> 'a list -> 'a list`
- **D)** `List.exists : 'a list -> ('a -> bool) -> bool`

<details>
<summary>Réponse</summary>

**Bonnes : A, B, C** *Concept : Signatures des fonctions d'ordre supérieur sur les listes.*

- **A.** Vrai : l'accumulateur est le premier paramètre de la fonction.
- **B.** Vrai : l'accumulateur est le deuxième paramètre de la fonction.
- **C.** Vrai.
- **D.** Faux : le prédicat vient avant la liste.

</details>

---

**14.** Lesquelles de ces affirmations sont vraies (Cas de la liste vide pour `for_all` et `exists`) ?

- **A)** `List.for_all (fun x -> x > 0) []` vaut `true`
- **B)** `List.exists (fun x -> x > 0) []` vaut `false`
- **C)** `List.exists (fun _ -> true) []` vaut `true`
- **D)** `List.exists ((=) 3) [1; 2; 3]` vaut `true`

<details>
<summary>Réponse</summary>

**Bonnes : A, B, D** *Concept : Cas de la liste vide pour `for_all` et `exists`.*

- **A.** Vrai : aucun élément ne contredit le prédicat.
- **B.** Vrai : aucun élément ne le satisfait.
- **C.** Faux : il n'existe aucun élément, même avec un prédicat toujours vrai.
- **D.** Vrai : `(=) 3 3` vaut `true`.

</details>

---

**15.** Soit `let t = [(1, "a"); (2, "b")]`. Lesquelles sont vraies ?

- **A)** `List.assoc 2 t` s'évalue à `"b"`
- **B)** `List.assoc 3 t` s'évalue à `None`
- **C)** `List.assoc_opt 3 t` s'évalue à `None`
- **D)** `List.find_opt (fun (k, _) -> k > 1) t` s'évalue à `Some (2, "b")`

<details>
<summary>Réponse</summary>

**Bonnes : A, C, D** *Concept : Recherche dans une liste d'association.*

- **A.** Vrai.
- **B.** Faux : `List.assoc` lève `Not_found` quand la clé est absente.
- **C.** Vrai : la variante `_opt` retourne une option.
- **D.** Vrai : `find_opt` retourne le premier élément qui satisfait le prédicat.

</details>

---

**16.** Lesquelles de ces affirmations sur la recherche dans les listes sont vraies ?

- **A)** `List.assoc : 'a -> ('a * 'b) list -> 'b`
- **B)** `List.assoc_opt : 'a -> ('a * 'b) list -> 'b option`
- **C)** `List.find_opt : ('a -> bool) -> 'a list -> 'a`
- **D)** `List.find` lève `Not_found` si aucun élément ne satisfait le prédicat

<details>
<summary>Réponse</summary>

**Bonnes : A, B, D** *Concept : Variantes avec et sans `_opt`.*

- **A.** Vrai.
- **B.** Vrai.
- **C.** Faux : `find_opt` retourne un `'a option`.
- **D.** Vrai : c'est la raison d'être de `find_opt`.

</details>

---

**17.** Lesquelles de ces égalités sont vraies (Application partielle d'un opérateur comparatif) ?

- **A)** `List.filter (fun x -> x mod 2 = 0) [1; 2; 3; 4] = [2; 4]`
- **B)** `List.filter ((<) 2) [1; 2; 3; 4] = [1]`
- **C)** `List.filter ((>) 2) [1; 2; 3] = [1]`
- **D)** `List.filter` peut changer le type des éléments

<details>
<summary>Réponse</summary>

**Bonnes : A, C** *Concept : Application partielle d'un opérateur comparatif.*

- **A.** Vrai.
- **B.** Faux : `(<) 2 x` signifie `2 < x`, on garde `[3; 4]`.
- **C.** Vrai : `(>) 2 x` signifie `2 > x`, seul 1 passe.
- **D.** Faux : `filter` garde ou jette des éléments, sans les transformer.

</details>

---

**18.** Lesquelles de ces propriétés sont vraies pour toute fonction pure `f`, `g` et tout prédicat `p` ?

- **A)** `List.length (List.map f l) = List.length l`
- **B)** `List.map f (List.map g l) = List.map (fun x -> f (g x)) l`
- **C)** `List.map f (List.filter p l) = List.filter p (List.map f l)`
- **D)** `List.rev (List.map f l) = List.map f (List.rev l)`

<details>
<summary>Réponse</summary>

**Bonnes : A, B, D** *Concept : Propriétés algébriques de `map` et `filter`.*

- **A.** Vrai : `map` conserve la longueur.
- **B.** Vrai : fusion de deux `map`.
- **C.** Faux : `p` s'applique à des valeurs différentes avant et après `f`.
- **D.** Vrai : `map` ne dépend pas de l'ordre de la liste.

</details>

---

**19.** Que sait-on de `List.fold_left (fun (s, n) x -> (s + x, n + 1)) (0, 0) [1; 2; 3]` ?

- **A)** Il s'évalue à `(6, 3)`
- **B)** Il s'évalue à `(3, 6)`
- **C)** Son type est `int * int`
- **D)** L'accumulateur doit avoir le même type que les éléments de la liste

<details>
<summary>Réponse</summary>

**Bonnes : A, C** *Concept : Accumulateur composé (somme et compte).*

- **A.** Vrai : somme 6, compte 3.
- **B.** Faux : la somme est en première composante.
- **C.** Vrai.
- **D.** Faux : l'accumulateur et les éléments sont indépendants, c'est `'a` et `'b`.

</details>

---

**20.** Lesquelles de ces affirmations sur `List.iter` et `List.map` sont vraies ?

- **A)** `List.iter : ('a -> unit) -> 'a list -> unit`
- **B)** `List.map print_int [1; 2]` a le type `unit list` et affiche `12`
- **C)** `List.iter (fun x -> x + 1) [1]` est accepté
- **D)** `List.iter` retourne la liste d'origine

<details>
<summary>Réponse</summary>

**Bonnes : A, B** *Concept : `iter` pour les effets secondaires, `map` pour les valeurs.*

- **A.** Vrai.
- **B.** Vrai : `map` collecte les `()` retournés par `print_int`.
- **C.** Faux : la fonction doit retourner `unit`, or `x + 1` est un `int`.
- **D.** Faux : `iter` retourne `unit`.

</details>

---

**21.** Lesquelles de ces affirmations sont vraies (Fonctions partielles de `List` (proscrites par le style)) ?

- **A)** `List.hd []` lève `Failure "hd"`
- **B)** `List.tl [1]` s'évalue à `[]`
- **C)** `List.hd : 'a list -> 'a option`
- **D)** `List.nth [1; 2] 5` lève `Failure "nth"`

<details>
<summary>Réponse</summary>

**Bonnes : A, B, D** *Concept : Fonctions partielles de `List` (proscrites par le style).*

- **A.** Vrai : c'est ce qui les rend partielles.
- **B.** Vrai : la queue d'un singleton est vide.
- **C.** Faux : `hd` retourne un `'a` ou lève une exception.
- **D.** Vrai.

</details>

---

**22.** Lesquelles de ces égalités sont vraies (Fonctions utilitaires de `List`) ?

- **A)** `List.init 4 (fun i -> i * i) = [0; 1; 4; 9]`
- **B)** `List.rev_append [1; 2] [3] = [2; 1; 3]`
- **C)** `List.partition (fun x -> x > 1) [1; 2; 3] = ([1], [2; 3])`
- **D)** `List.mapi (fun i x -> i + x) [10; 20] = [10; 21]`

<details>
<summary>Réponse</summary>

**Bonnes : A, B, D** *Concept : Fonctions utilitaires de `List`.*

- **A.** Vrai.
- **B.** Vrai : on renverse la première liste sur la seconde.
- **C.** Faux : on obtient `([2; 3], [1])`, les éléments qui satisfont le prédicat d'abord.
- **D.** Vrai : 0 + 10 et 1 + 20.

</details>

---

**23.** Lesquelles de ces affirmations sont vraies (Listes parallèles : `map2`, `combine`, `split`) ?

- **A)** `List.map2 (+) [1; 2] [10; 20] = [11; 22]`
- **B)** `List.map2 (+) [1] [1; 2]` s'évalue à `[2]`
- **C)** `List.combine [1; 2] [3]` lève `Invalid_argument`
- **D)** `List.split [(1, 'a'); (2, 'b')] = ([1; 2], ['a'; 'b'])`

<details>
<summary>Réponse</summary>

**Bonnes : A, C, D** *Concept : Listes parallèles : `map2`, `combine`, `split`.*

- **A.** Vrai.
- **B.** Faux : les longueurs diffèrent, `map2` lève `Invalid_argument`.
- **C.** Vrai : même raison.
- **D.** Vrai : `split` est l'inverse de `combine`.

</details>

---

**24.** Lesquelles de ces affirmations sont vraies (`concat_map`, `filter_map` et `flatten`) ?

- **A)** `List.concat_map (fun x -> [x; x]) [1; 2] = [1; 1; 2; 2]`
- **B)** `List.map (fun x -> [x; x]) [1; 2]` a le type `int list`
- **C)** `List.filter_map (fun x -> if x > 1 then Some (x * 2) else None) [1; 2; 3] = [4; 6]`
- **D)** `List.flatten (List.map (fun x -> [x; x]) [1; 2]) = [1; 1; 2; 2]`

<details>
<summary>Réponse</summary>

**Bonnes : A, C, D** *Concept : `concat_map`, `filter_map` et `flatten`.*

- **A.** Vrai.
- **B.** Faux : le résultat est `int list list`, soit `[[1; 1]; [2; 2]]`.
- **C.** Vrai : on garde et transforme en un seul passage.
- **D.** Vrai : `concat_map f` équivaut à `flatten (map f)`.

</details>

---

**25.** Lesquelles de ces affirmations sur le tri sont vraies ?

- **A)** `List.sort compare ["b"; "a"; "C"] = ["C"; "a"; "b"]`
- **B)** `List.sort (<) [3; 1; 2]` est bien typé
- **C)** `List.sort_uniq compare [2; 1; 2] = [1; 2]`
- **D)** `List.sort (fun a b -> compare b a) [1; 3; 2] = [3; 2; 1]`

<details>
<summary>Réponse</summary>

**Bonnes : A, C, D** *Concept : Le comparateur de `sort` retourne un entier.*

- **A.** Vrai : les majuscules précèdent les minuscules dans l'ordre des caractères.
- **B.** Faux : `(<)` retourne un `bool`, `sort` attend un `int`.
- **C.** Vrai : tri et élimination des doublons.
- **D.** Vrai : comparer à l'envers donne l'ordre décroissant.

</details>

---

**26.** Lesquelles de ces affirmations sont vraies (`mem` utilise l'égalité structurelle) ?

- **A)** `List.mem [1] [[1]; [2]]` vaut `true`
- **B)** `List.mem_assoc 1 [(1, 2)]` vaut `true`
- **C)** `List.mem` compare avec `==`
- **D)** `List.mem x l` parcourt la liste, donc en O(n)

<details>
<summary>Réponse</summary>

**Bonnes : A, B, D** *Concept : `mem` utilise l'égalité structurelle.*

- **A.** Vrai : `[1] = [1]` structurellement.
- **B.** Vrai : `mem_assoc` teste la présence de la clé.
- **C.** Faux : c'est `=`, la version `==` s'appelle `List.memq`.
- **D.** Vrai.

</details>

---

**27.** À propos du coût des opérations sur les listes, lesquelles sont vraies ?

- **A)** `x :: l` s'exécute en temps constant
- **B)** `l @ [x]` s'exécute en temps constant
- **C)** `List.length l` est en O(n)
- **D)** `List.nth l k` est en O(k)

<details>
<summary>Réponse</summary>

**Bonnes : A, C, D** *Concept : Listes simplement chaînées.*

- **A.** Vrai : on ajoute une cellule en tête.
- **B.** Faux : `@` copie toute la liste de gauche.
- **C.** Vrai : il faut compter les cellules.
- **D.** Vrai : on avance de `k` cellules.

</details>

---

**28.** Lesquelles de ces affirmations sur `@` et le test de liste vide sont vraies ?

- **A)** Le coût de `l1 @ l2` est proportionnel à la longueur de `l1`
- **B)** Le coût de `l1 @ l2` est proportionnel à la longueur de `l2`
- **C)** `List.rev l` est en O(n)
- **D)** Tester `l = []` parcourt toute la liste

<details>
<summary>Réponse</summary>

**Bonnes : A, C** *Concept : Coût de `@`, `rev` et de la comparaison à `[]`.*

- **A.** Vrai : `l2` est partagée, seule `l1` est copiée.
- **B.** Faux : `l2` n'est pas recopiée.
- **C.** Vrai.
- **D.** Faux : la comparaison s'arrête dès que les constructeurs diffèrent.

</details>

---

**29.** Lesquelles de ces affirmations sur la complexité sont vraies ?

- **A)** `let rec rev = function [] -> [] | h :: t -> rev t @ [h]` est quadratique
- **B)** `List.rev` est linéaire
- **C)** Tester `l = []` demande de parcourir la liste
- **D)** Appeler `List.length l` à chaque appel récursif sur la queue rend la fonction quadratique

<details>
<summary>Réponse</summary>

**Bonnes : A, B, D** *Concept : Choisir un algorithme linéaire plutôt que quadratique.*

- **A.** Vrai : chaque `@ [h]` parcourt la liste déjà construite.
- **B.** Vrai : un accumulateur suffit.
- **C.** Faux : la comparaison s'arrête dès que les constructeurs diffèrent.
- **D.** Vrai : n + (n - 1) + ... + 1 opérations.

</details>

---

**30.** Lesquelles de ces fonctions sont récursives terminales ?

- **A)** `let rec mem x = function [] -> false | h :: t -> h = x || mem x t`
- **B)** `let rec dbl = function [] -> [] | h :: t -> (2 * h) :: dbl t`
- **C)** `let rec loop n = if n = 0 then 0 else loop (n - 1)`
- **D)** `let rec g n = try g (n - 1) with _ -> 0`

<details>
<summary>Réponse</summary>

**Bonnes : A, C** *Concept : Position terminale : `||`, construction de liste, `try`.*

- **A.** Vrai : l'opérande de droite de `||` est en position terminale.
- **B.** Faux : le `::` s'applique après le retour de `dbl t`.
- **C.** Vrai : l'appel est la dernière chose faite.
- **D.** Faux : le gestionnaire du `try` reste actif pendant l'appel.

</details>

---

**31.** Soit `let rec f acc = function [] -> acc | h :: t -> f (acc * 10 + h) t`. Lesquelles sont vraies ?

- **A)** `f : int -> int list -> int`
- **B)** `f 0 [1; 2; 3]` s'évalue à `123`
- **C)** `f` est récursive terminale
- **D)** `f 0 [3; 2; 1]` s'évalue à `123`

<details>
<summary>Réponse</summary>

**Bonnes : A, B, C** *Concept : Accumulateur positionnel.*

- **A.** Vrai.
- **B.** Vrai : 0, puis 1, puis 12, puis 123.
- **C.** Vrai : l'appel récursif est en dernier.
- **D.** Faux : on obtient 321.

</details>

---

**32.** Soit `let g = function (Some x, _) when x > 0 -> 1 | (_, Some y) -> 2 | _ -> 3`. Lesquelles sont vraies ?

- **A)** `g (Some 1, None)` vaut `1`
- **B)** `g (Some 0, Some 5)` vaut `1`
- **C)** `g (Some (-3), None)` vaut `3`
- **D)** `g : int option * 'a option -> int`

<details>
<summary>Réponse</summary>

**Bonnes : A, C, D** *Concept : Garde `when` et motifs de couples.*

- **A.** Vrai : la garde `1 > 0` passe.
- **B.** Faux : la garde échoue, on tombe sur le deuxième cas, qui donne 2.
- **C.** Vrai : aucun des deux premiers cas ne s'applique.
- **D.** Vrai : `y` n'est pas contraint, donc `'a option`.

</details>

---

**33.** Lesquelles de ces fonctions provoquent l'avertissement 8 (filtrage non exhaustif) ?

- **A)** `function n when n >= 0 -> 1 | n when n < 0 -> 2`
- **B)** `function [] -> 0 | [_] -> 1 | _ :: _ :: _ -> 2`
- **C)** `function (true, _) -> 1 | (_, true) -> 2`
- **D)** `function Ok x -> x | Error _ -> 0`

<details>
<summary>Réponse</summary>

**Bonnes : A, C** *Concept : Gardes ignorées par l'analyse d'exhaustivité.*

- **A.** Oui : le compilateur ne raisonne pas sur les gardes, il exige un cas sans garde.
- **B.** Non : les trois formes de listes sont couvertes.
- **C.** Oui : `(false, false)` n'est pas couvert.
- **D.** Non : `Ok` et `Error` sont les deux constructeurs de `result`.

</details>

---

**34.** Lesquelles de ces fonctions provoquent l'avertissement 11 (cas inutile) ?

- **A)** `function _ -> 0 | 1 -> 1`
- **B)** `function [] -> 0 | _ -> 1 | [x] -> x`
- **C)** `function Some _ -> 1 | None -> 0`
- **D)** `function (0, _) -> 0 | (_, 0) -> 1 | _ -> 2`

<details>
<summary>Réponse</summary>

**Bonnes : A, B** *Concept : Un cas déjà couvert par un cas précédent.*

- **A.** Oui : `_` capture tout, `1` n'est jamais atteint.
- **B.** Oui : `[x]` est déjà couvert par `_`.
- **C.** Non : les deux constructeurs sont distincts.
- **D.** Non : chaque cas attrape au moins une valeur nouvelle.

</details>

---

**35.** Lesquelles de ces expressions s'évaluent comme indiqué (Motifs de listes : `::` et `[a; b]`) ?

- **A)** `match [1; 2; 3] with x :: y :: _ -> x + y | _ -> 0` vaut `3`
- **B)** `match [1; 2; 3] with [x; y] -> x + y | _ -> 0` vaut `0`
- **C)** `match [4] with x :: y :: _ -> x | _ -> 0` vaut `4`
- **D)** `match [4; 5] with [x; _] -> x | _ -> 0` vaut `4`

<details>
<summary>Réponse</summary>

**Bonnes : A, B, D** *Concept : Motifs de listes : `::` et `[a; b]`.*

- **A.** Vrai : 1 + 2.
- **B.** Vrai : `[x; y]` ne correspond qu'aux listes de deux éléments exactement.
- **C.** Faux : la liste n'a qu'un élément, on tombe sur `_` et on obtient 0.
- **D.** Vrai.

</details>

---

**36.** Lesquelles de ces affirmations sont vraies (Motifs-ou et alias `as`) ?

- **A)** `function 1 | 2 -> "a" | _ -> "b"` est accepté et a le type `int -> string`
- **B)** `function Some x | None -> x` est accepté
- **C)** `match [1; 2] with (h :: _) as l -> List.length l + h | [] -> 0` vaut `3`
- **D)** Dans `(h :: _) as l`, `l` désigne la queue de la liste

<details>
<summary>Réponse</summary>

**Bonnes : A, C** *Concept : Motifs-ou et alias `as`.*

- **A.** Vrai : un motif-ou peut porter sur des constantes.
- **B.** Faux : une variable doit apparaître dans les deux côtés du `|`.
- **C.** Vrai : `l` vaut `[1; 2]`, de longueur 2, et `h` vaut 1.
- **D.** Faux : `as` nomme le motif entier, donc la liste complète.

</details>

---

**37.** Soit `let nest a b = match a with 0 -> match b with 0 -> "x" | _ -> "y" | _ -> "z"`. Lesquelles sont vraies ?

- **A)** Le compilateur signale un cas inutile
- **B)** `nest 0 1` s'évalue à `"y"`
- **C)** `nest 1 1` s'évalue à `"z"`
- **D)** Mettre le `match` interne entre parenthèses corrige le problème

<details>
<summary>Réponse</summary>

**Bonnes : A, B, D** *Concept : Un `match` imbriqué avale les cas suivants.*

- **A.** Vrai : le dernier `| _ -> "z"` est rattaché au `match` interne, déjà exhaustif.
- **B.** Vrai.
- **C.** Faux : `nest 1 1` lève `Match_failure`, le `match` externe n'a que le cas `0`.
- **D.** Vrai : le dernier cas revient alors au `match` externe.

</details>

---

**38.** Soit `type pt = {x : int; y : int}` et `let p = {x = 1; y = 2}`. Lesquelles sont vraies ?

- **A)** `{p with y = 5}` crée un nouvel enregistrement et laisse `p` inchangé
- **B)** `{x = 1}` est accepté
- **C)** `p.x <- 3` est accepté
- **D)** `let {x; y} = p in x + y` s'évalue à `3`

<details>
<summary>Réponse</summary>

**Bonnes : A, D** *Concept : Enregistrements immuables, copie et filtrage.*

- **A.** Vrai : `with` copie en remplaçant le champ donné.
- **B.** Faux : tous les champs doivent être fournis.
- **C.** Faux : le champ n'est pas déclaré `mutable`.
- **D.** Vrai : le motif lie `x` et `y` aux champs.

</details>

---

**39.** Soit `type 'a arbre = F | N of 'a arbre * 'a * 'a arbre`. Lesquelles sont vraies ?

- **A)** `N (F, 1, F)` a le type `int arbre`
- **B)** `N (F, 1, N (F, "a", F))` est mal typé
- **C)** `F` a le type `int arbre`
- **D)** `let rec taille = function F -> 0 | N (g, _, d) -> 1 + taille g + taille d` a le type `'a arbre -> int`

<details>
<summary>Réponse</summary>

**Bonnes : A, B, D** *Concept : Type somme récursif et paramétré.*

- **A.** Vrai.
- **B.** Vrai : un arbre ne peut contenir qu'un seul type d'étiquettes.
- **C.** Faux : `F` a le type `'a arbre`, polymorphe.
- **D.** Vrai : l'étiquette n'est jamais examinée.

</details>

---

**40.** Lesquelles de ces affirmations sur `option` sont vraies ?

- **A)** `Some 1 = Some 1` vaut `true`
- **B)** `None < Some 0` vaut `true`
- **C)** `Option.get None` retourne `0`
- **D)** `Option.value None ~default:5` vaut `5`

<details>
<summary>Réponse</summary>

**Bonnes : A, B, D** *Concept : Valeurs optionnelles.*

- **A.** Vrai : égalité structurelle.
- **B.** Vrai : `None` est plus petit que tout `Some`.
- **C.** Faux : `Option.get None` lève `Invalid_argument` (fonction partielle).
- **D.** Vrai.

</details>

---

**41.** Lesquelles de ces affirmations sur `result` sont vraies ?

- **A)** `Result.map succ (Ok 1)` vaut `Ok 2`
- **B)** `Result.map succ (Error "e")` vaut `Error "e"`
- **C)** `Ok 1 = Error 1` est mal typé
- **D)** `Ok 1` a le type `(int, 'a) result`

<details>
<summary>Réponse</summary>

**Bonnes : A, B, D** *Concept : Appliquer une fonction sur le cas `Ok` seulement.*

- **A.** Vrai.
- **B.** Vrai : une erreur traverse `map` sans changement.
- **C.** Faux : les deux ont le type `(int, int) result`, le résultat est `false`.
- **D.** Vrai : le type d'erreur reste libre.

</details>

---

**42.** Soit `type t = A of int * int | B of (int * int)` et `let p = (1, 2)`. Lesquelles sont vraies ?

- **A)** `A p` est rejeté
- **B)** `B p` est accepté
- **C)** `A` et `B` sont deux écritures équivalentes
- **D)** Avec `type c = Pique | Coeur`, `Pique < Coeur` vaut `true`

<details>
<summary>Réponse</summary>

**Bonnes : A, B, D** *Concept : Constructeur à deux arguments versus constructeur à un couple.*

- **A.** Vrai : `A` attend deux arguments, pas un couple.
- **B.** Vrai : `B` prend un couple.
- **C.** Faux : seul `B` accepte une valeur de type couple.
- **D.** Vrai : les constructeurs se comparent selon l'ordre de déclaration.

</details>

---

**43.** Lesquelles de ces affirmations sur les n-uplets sont vraies ?

- **A)** `fst (1, 2, 3)` est mal typé
- **B)** `(1, (2, 3)) = ((1, 2), 3)` est mal typé
- **C)** `let (a, _, c) = (1, 2, 3) in a + c` vaut `4`
- **D)** `snd (1, 2) = 1` est mal typé

<details>
<summary>Réponse</summary>

**Bonnes : A, B, C** *Concept : Un triplet n'est pas un couple de couples.*

- **A.** Vrai : `fst` attend un couple.
- **B.** Vrai : `int * (int * int)` et `(int * int) * int` sont différents.
- **C.** Vrai.
- **D.** Faux : l'expression est bien typée et vaut `false`.

</details>

---

**44.** Lesquelles de ces expressions s'évaluent comme indiqué (Masquage et `let ... and ...`) ?

- **A)** `let x = 1 in let x = x + 1 in let x = x * 10 in x` vaut `20`
- **B)** `let x = 5 in let f y = x + y in let x = 100 in f 1` vaut `101`
- **C)** `let x = 1 in (let x = 2 in x) + x` vaut `3`
- **D)** `let x = 2 in let x = 3 and y = x in y` vaut `2`

<details>
<summary>Réponse</summary>

**Bonnes : A, C, D** *Concept : Masquage et `let ... and ...`.*

- **A.** Vrai : 1, puis 2, puis 20.
- **B.** Faux : `f` voit le `x` de sa définition, donc 6.
- **C.** Vrai : 2 + 1.
- **D.** Vrai : dans `let ... and ...`, `y = x` voit le `x` extérieur.

</details>

---

**45.** Lesquelles de ces affirmations sur la portée sont vraies ?

- **A)** `let a = (let b = 3 in b * 2) in b` est rejeté (`Unbound value b`)
- **B)** `let fact n = if n = 0 then 1 else n * fact (n - 1)` est rejeté (`Unbound value fact`)
- **C)** `let x = 3 in let f () = x in let x = 10 in f ()` vaut `3`
- **D)** Un nouveau `let x` modifie la liaison existante de `x`

<details>
<summary>Réponse</summary>

**Bonnes : A, B, C** *Concept : Portée lexicale, `rec` et masquage.*

- **A.** Vrai : `b` n'existe que dans le `let ... in` interne.
- **B.** Vrai : sans `rec`, `fact` n'est pas visible dans son corps.
- **C.** Vrai : la fermeture capture le `x` visible à sa définition.
- **D.** Faux : la nouvelle liaison masque l'ancienne, elle ne la modifie pas.

</details>

---

**46.** Soit `let l = lazy (print_endline "a"; 1)`. Lesquelles sont vraies ?

- **A)** `l` a le type `int lazy_t`
- **B)** La définition de `l` affiche `a`
- **C)** `Lazy.force l + Lazy.force l` vaut `2` et affiche `a` une seule fois
- **D)** Chaque `Lazy.force l` réévalue l'expression

<details>
<summary>Réponse</summary>

**Bonnes : A, C** *Concept : `lazy` retarde et mémorise.*

- **A.** Vrai.
- **B.** Faux : rien n'est évalué avant le premier `force`.
- **C.** Vrai : le résultat est mémorisé après le premier calcul.
- **D.** Faux : la valeur est calculée une seule fois.

</details>

---

**47.** Soit `let lz = lazy (1 / 0)`. Lesquelles sont vraies ?

- **A)** La définition de `lz` ne lève aucune exception
- **B)** `Lazy.force lz` lève `Division_by_zero`
- **C)** Un second `Lazy.force lz` retourne un résultat mémorisé
- **D)** Un second `Lazy.force lz` lève de nouveau `Division_by_zero`

<details>
<summary>Réponse</summary>

**Bonnes : A, B, D** *Concept : Une exception se mémorise elle aussi.*

- **A.** Vrai : le calcul est différé.
- **B.** Vrai.
- **C.** Faux : aucun résultat n'existe, le calcul a échoué.
- **D.** Vrai : l'exception est conservée et relancée.

</details>

---

**48.** Soit `let f x y = x` et `let ou a b = a || b`. Lesquelles sont vraies ?

- **A)** `f 1 (print_endline "z"; 2)` affiche `z`
- **B)** `true || (print_endline "z"; true)` affiche `z`
- **C)** `if true then 1 else (print_endline "z"; 2)` n'affiche rien
- **D)** `ou true (print_endline "z"; true)` affiche `z`

<details>
<summary>Réponse</summary>

**Bonnes : A, C, D** *Concept : Arguments évalués avant l'appel, sauf pour les opérateurs spéciaux.*

- **A.** Vrai : l'évaluation est stricte, même pour un argument inutilisé.
- **B.** Faux : `||` n'évalue pas son opérande de droite si la gauche est vraie.
- **C.** Vrai : seule la branche choisie est évaluée.
- **D.** Vrai : `ou` est une fonction ordinaire, donc ses arguments sont évalués d'abord.

</details>

---

**49.** À propos de `Seq`, lesquelles sont vraies ?

- **A)** `Seq.ints 0 |> Seq.take 3 |> List.of_seq` vaut `[0; 1; 2]`
- **B)** `Seq.map (fun x -> print_endline "m"; x) (List.to_seq [1; 2])` affiche `m` dès sa création
- **C)** `Seq.ints 0` se définit sans boucler, malgré sa taille infinie
- **D)** `List.of_seq (Seq.ints 0)` se termine rapidement

<details>
<summary>Réponse</summary>

**Bonnes : A, C** *Concept : Séquences paresseuses, potentiellement infinies.*

- **A.** Vrai : `take 3` borne la consommation.
- **B.** Faux : rien n'est calculé tant que la séquence n'est pas consommée.
- **C.** Vrai : seul le premier élément est produit à la demande.
- **D.** Faux : on tenterait de bâtir une liste infinie.

</details>

---

**50.** Lesquelles de ces affirmations sur `Seq` sont vraies ?

- **A)** `Seq.take 2 (Seq.map succ (List.to_seq [1; 2; 3])) |> List.of_seq` vaut `[2; 3]`
- **B)** `Seq.unfold (fun n -> if n > 3 then None else Some (n, n + 1)) 1 |> List.of_seq` vaut `[1; 2; 3]`
- **C)** `Seq.fold_left (+) 0 (List.to_seq [1; 2; 3])` vaut `6`
- **D)** Une valeur de type `int Seq.t` est une liste déjà construite en mémoire

<details>
<summary>Réponse</summary>

**Bonnes : A, B, C** *Concept : Construire et consommer une séquence.*

- **A.** Vrai.
- **B.** Vrai : `None` arrête la production.
- **C.** Vrai.
- **D.** Faux : c'est une fonction qui produit les éléments à la demande.

</details>

---

**51.** Lesquelles de ces expressions ont des effets secondaires ?

- **A)** `print_string "x"`
- **B)** `String.uppercase_ascii "a"`
- **C)** `Random.int 10`
- **D)** `List.rev [1; 2]`

<details>
<summary>Réponse</summary>

**Bonnes : A, C** *Concept : Distinguer calcul pur et effet.*

- **A.** Oui : écrit sur la sortie standard.
- **B.** Non : retourne une nouvelle chaîne sans rien modifier.
- **C.** Oui : fait évoluer l'état du générateur aléatoire.
- **D.** Non : retourne une nouvelle liste.

</details>

---

**52.** Soit `let f () = print_string "a"; 1`. Lesquelles sont vraies ?

- **A)** `f : unit -> int`
- **B)** `f () + f ()` affiche `aa` et vaut `2`
- **C)** `let x = f () in x + x` affiche `a` une seule fois
- **D)** `f () + f ()` et `let x = f () in x + x` produisent les mêmes effets

<details>
<summary>Réponse</summary>

**Bonnes : A, B, C** *Concept : Une expression à effet n'est pas remplaçable par sa valeur.*

- **A.** Vrai.
- **B.** Vrai : deux appels, deux affichages.
- **C.** Vrai : un seul appel, la valeur est réutilisée.
- **D.** Faux : le premier affiche deux fois, le second une fois.

</details>

---

**53.** Lesquelles de ces affirmations sur `;` et `unit` sont vraies ?

- **A)** `(print_string "a"; 3)` a le type `int`
- **B)** `let x = (print_string "a"; 1) in x + x` affiche `a` une seule fois
- **C)** `(print_string "a"; 3)` a le type `unit`
- **D)** `print_string : string -> unit`

<details>
<summary>Réponse</summary>

**Bonnes : A, B, D** *Concept : Séquence d'expressions.*

- **A.** Vrai : la valeur d'une séquence est celle de sa dernière expression.
- **B.** Vrai : l'expression liée à `x` est évaluée une fois.
- **C.** Faux : seule la dernière expression compte pour le type.
- **D.** Vrai.

</details>

---

**54.** Lesquelles de ces affirmations sur l'égalité sont vraies ?

- **A)** `(fun x -> x) = (fun x -> x)` lève `Invalid_argument`
- **B)** `nan = nan` vaut `true`
- **C)** `0.1 +. 0.2 = 0.3` vaut `false`
- **D)** `List.map succ [0] == List.map succ [0]` vaut `true`

<details>
<summary>Réponse</summary>

**Bonnes : A, C** *Concept : Cas limites de `=` et `==`.*

- **A.** Vrai : on ne peut pas comparer des fonctions.
- **B.** Faux : `nan` est différent de lui-même.
- **C.** Vrai : 0.1 + 0.2 diffère de 0.3 en virgule flottante.
- **D.** Faux : deux listes fraîchement construites sont deux blocs distincts.

</details>

---

**55.** Lesquelles de ces expressions valent `true` ?

- **A)** `1 == 1`
- **B)** `'a' == 'a'`
- **C)** `let l = [1; 2] in l == l`
- **D)** `List.map succ [0] == List.map succ [0]`

<details>
<summary>Réponse</summary>

**Bonnes : A, B, C** *Concept : `==` compare l'identité en mémoire.*

- **A.** Oui : les entiers sont stockés directement.
- **B.** Oui : les caractères aussi.
- **C.** Oui : c'est exactement le même bloc.
- **D.** Non : deux blocs distincts, malgré le même contenu.

</details>

---

**56.** Lesquelles de ces égalités sont vraies (Signe de `compare`) ?

- **A)** `compare 1 2 = -1`
- **B)** `compare "b" "a" = 1`
- **C)** `compare [1; 2] [1; 3] = 1`
- **D)** `compare (Some 1) None = 1`

<details>
<summary>Réponse</summary>

**Bonnes : A, B, D** *Concept : Signe de `compare`.*

- **A.** Vrai : 1 est plus petit que 2.
- **B.** Vrai : "b" suit "a".
- **C.** Faux : `[1; 2]` précède `[1; 3]`, donc -1.
- **D.** Vrai : `None` est plus petit que `Some _`.

</details>

---

**57.** Lesquelles de ces expressions ont le type indiqué ?

- **A)** `( < ) : 'a -> 'a -> bool`
- **B)** `( ^ ) "a" : string -> string`
- **C)** `(+) 1. : float -> float`
- **D)** `( = ) : int -> int -> bool`

<details>
<summary>Réponse</summary>

**Bonnes : A, B** *Concept : Opérateurs comme fonctions.*

- **A.** Vrai : la comparaison est polymorphe.
- **B.** Vrai : application partielle de `^`.
- **C.** Faux : `(+)` travaille sur des `int`, `1.` est rejeté.
- **D.** Faux : `( = )` est polymorphe, `'a -> 'a -> bool`.

</details>

---

**58.** Lesquelles de ces affirmations sur le polymorphisme sont vraies ?

- **A)** `let id x = x in (id 1, id "a")` est accepté
- **B)** `(fun f -> (f 1, f "a")) id` est rejeté
- **C)** `let m2 a b = if a > b then a else b` a le type `'a -> 'a -> 'a`
- **D)** `m2 1 2.` est accepté

<details>
<summary>Réponse</summary>

**Bonnes : A, B, C** *Concept : Paramètre lié par `fun` versus définition liée par `let`.*

- **A.** Vrai : `id` est généralisée, donc réutilisable à deux types.
- **B.** Vrai : un paramètre de `fun` reçoit un seul type monomorphe.
- **C.** Vrai : les deux branches du `if` ont le type de `a` et `b`.
- **D.** Faux : `int` et `float` ne s'unifient pas.

</details>

---

**59.** Lesquelles de ces définitions sont acceptées par le compilateur ?

- **A)** `let rec f x = f`
- **B)** `let f x = x x`
- **C)** `let rec f x = f x`, de type `'a -> 'b`
- **D)** `let f x = (x, x)`

<details>
<summary>Réponse</summary>

**Bonnes : C, D** *Concept : Vérification d'occurrence (type infini).*

- **A.** Rejeté : le type de `f` devrait contenir `f` lui-même.
- **B.** Rejeté : `x` devrait avoir un type qui se contient.
- **C.** Accepté : la fonction boucle sans fin, mais son type est valide.
- **D.** Accepté : `'a -> 'a * 'a`.

</details>

---

**60.** Lesquelles de ces expressions sont bien typées avec le type indiqué ?

- **A)** `[] :: []` : `'a list list`
- **B)** `[[]; [1]]` : `int list list`
- **C)** `[[1]; 2]`
- **D)** `[1] :: [[2]]` : `int list list`

<details>
<summary>Réponse</summary>

**Bonnes : A, B, D** *Concept : Listes de listes.*

- **A.** Vrai : une liste contenant une liste vide.
- **B.** Vrai : `[]` s'adapte à `int list`.
- **C.** Faux : le deuxième élément est un `int`, pas un `int list`.
- **D.** Vrai.

</details>

---

**61.** Soit `let s f g x = f x (g x)`. Lesquelles sont vraies ?

- **A)** `s : ('a -> 'b -> 'c) -> ('a -> 'b) -> 'a -> 'c`
- **B)** `s (+) succ 1` vaut `3`
- **C)** `s (fun x _ -> x) succ 5` vaut `5`
- **D)** `s` prend exactement quatre arguments

<details>
<summary>Réponse</summary>

**Bonnes : A, B, C** *Concept : Combinateur S.*

- **A.** Vrai : `x` va à `f` et à `g`, `g x` est le second argument de `f`.
- **B.** Vrai : `1 + succ 1`.
- **C.** Vrai : la fonction ignore son second argument.
- **D.** Faux : `s` en prend trois, le résultat est un `'c`, éventuellement une fonction.

</details>

---

**62.** Lesquelles de ces expressions ont le type `'a list -> bool` ?

- **A)** `fun l -> l = []`
- **B)** `fun l -> List.length l`
- **C)** `List.exists (fun x -> x)`
- **D)** `fun l -> match l with [] -> true | _ -> false`

<details>
<summary>Réponse</summary>

**Bonnes : A, D** *Concept : Fonctions sur listes polymorphes.*

- **A.** Vrai.
- **B.** Faux : retourne un `int`.
- **C.** Faux : le prédicat impose `bool list -> bool`.
- **D.** Vrai.

</details>

---

**63.** Lesquelles de ces affirmations sont vraies (La virgule construit un couple, le point-virgule sépare les éléments) ?

- **A)** `fun x -> [x, x]` a le type `'a -> ('a * 'a) list`
- **B)** `fun x -> [x; x]` a le type `'a -> ('a * 'a) list`
- **C)** `List.concat : 'a list list -> 'a list`
- **D)** `fun x -> [x, x]` retourne une liste de deux éléments

<details>
<summary>Réponse</summary>

**Bonnes : A, C** *Concept : La virgule construit un couple, le point-virgule sépare les éléments.*

- **A.** Vrai : `[x, x]` est la liste d'un seul couple.
- **B.** Faux : `[x; x]` est de type `'a -> 'a list`.
- **C.** Vrai.
- **D.** Faux : la liste contient un seul élément, un couple.

</details>

---

**64.** Lesquelles de ces affirmations sur les priorités sont vraies ?

- **A)** `succ -1` est mal typé
- **B)** `not true && false` vaut `false`
- **C)** `1 :: [2] @ [3]` vaut `[1; 2; 3]`
- **D)** `10 - 2 - 3` vaut `11`

<details>
<summary>Réponse</summary>

**Bonnes : A, B, C** *Concept : Priorités et associativité.*

- **A.** Vrai : lu comme `succ - 1`, soustraction d'une fonction et d'un entier.
- **B.** Vrai : `(not true) && false`.
- **C.** Vrai : `::` et `@` associent à droite.
- **D.** Faux : `-` associe à gauche, `(10 - 2) - 3 = 5`.

</details>

---

**65.** Lesquelles de ces affirmations sur les entiers sont vraies ?

- **A)** `-7 / 2` vaut `-3`
- **B)** `(-7) mod 2` vaut `-1`
- **C)** `7 / 2.` est mal typé
- **D)** `2 ** 3` vaut `8`

<details>
<summary>Réponse</summary>

**Bonnes : A, B, C** *Concept : Division entière tronquée vers zéro.*

- **A.** Vrai : la division entière tronque vers zéro.
- **B.** Vrai : le reste prend le signe du dividende.
- **C.** Vrai : `/` ne travaille que sur des `int`.
- **D.** Faux : `**` est réservé aux `float`, l'expression est mal typée.

</details>

---

**66.** Lesquelles de ces affirmations sur les flottants sont vraies ?

- **A)** `7. /. 2.` vaut `3.5`
- **B)** `int_of_float 3.9` vaut `3`
- **C)** `2. ** 3.` vaut `8.`
- **D)** `1 +. 2` est accepté

<details>
<summary>Réponse</summary>

**Bonnes : A, B, C** *Concept : Opérateurs flottants et conversions.*

- **A.** Vrai.
- **B.** Vrai : la conversion tronque.
- **C.** Vrai.
- **D.** Faux : `1` est un `int`.

</details>

---

**67.** Soit `let f = fun x -> fun y -> x - y`. Lesquelles sont vraies ?

- **A)** `List.map (f 10) [1; 2]` vaut `[9; 8]`
- **B)** `List.map (fun x -> f x 10) [1; 2]` vaut `[-9; -8]`
- **C)** `f 10` a le type `int`
- **D)** `f` a le même type que `let f x y = x - y`

<details>
<summary>Réponse</summary>

**Bonnes : A, B, D** *Concept : Curryfication et ordre des arguments.*

- **A.** Vrai : `10 - 1` et `10 - 2`.
- **B.** Vrai : `1 - 10` et `2 - 10`.
- **C.** Faux : il manque un argument, c'est `int -> int`.
- **D.** Vrai : la seconde forme est du sucre pour la première.

</details>

---

**68.** Soit `let g (x, y) = x - y`. Lesquelles sont vraies ?

- **A)** `List.map g [(1, 2); (3, 1)]` vaut `[-1; 2]`
- **B)** `List.map (g 1)` est bien typé
- **C)** `g : int * int -> int`
- **D)** `g` est curryfiée

<details>
<summary>Réponse</summary>

**Bonnes : A, C** *Concept : Un couple n'est pas une application partielle.*

- **A.** Vrai.
- **B.** Faux : `g` attend un couple, pas un entier.
- **C.** Vrai.
- **D.** Faux : `g` prend un seul argument, un couple.

</details>

---

**69.** Soit `let rec pow b n = if n = 0 then 1 else b * pow b (n - 1)` et `let deux = pow 2`. Lesquelles sont vraies ?

- **A)** `deux : int -> int`
- **B)** `deux 5` vaut `32`
- **C)** `deux 5` vaut `25`
- **D)** `deux` a un type avec une variable faible

<details>
<summary>Réponse</summary>

**Bonnes : A, B** *Concept : Application partielle d'une fonction récursive.*

- **A.** Vrai.
- **B.** Vrai : 2 à la puissance 5.
- **C.** Faux : la base est fixée à 2, pas l'exposant.
- **D.** Faux : aucune variable de type libre, tout est `int`.

</details>

---

**70.** Lesquelles de ces affirmations sur `|>` et `@@` sont vraies ?

- **A)** `[1; 2; 3] |> List.map succ |> List.filter (fun x -> x > 2)` vaut `[3; 4]`
- **B)** `succ @@ 1` vaut `2`
- **C)** `( |> ) : 'a -> ('a -> 'b) -> 'b`
- **D)** `[1; 2] |> List.length |> List.map succ` est bien typé

<details>
<summary>Réponse</summary>

**Bonnes : A, B, C** *Concept : Opérateurs de redirection.*

- **A.** Vrai : la liste devient `[2; 3; 4]`, puis on garde les éléments plus grands que 2.
- **B.** Vrai : `f @@ x` équivaut à `f x`.
- **C.** Vrai.
- **D.** Faux : `List.length` produit un `int`, et `List.map` attend une liste.

</details>

---

**71.** Lesquelles de ces définitions donnent un type avec une variable faible ?

- **A)** `let q = List.fold_left (fun acc x -> x :: acc) []`
- **B)** `let h = List.filter (fun _ -> true)`
- **C)** `let c = fun x -> x`
- **D)** `let rev l = List.fold_left (fun acc x -> x :: acc) [] l`

<details>
<summary>Réponse</summary>

**Bonnes : A, B** *Concept : Application partielle non généralisable.*

- **A.** Oui : application partielle, donc `'_weak1 list -> '_weak1 list`.
- **B.** Oui : même raison.
- **C.** Non : une fonction anonyme est une valeur, donc généralisée.
- **D.** Non : en nommant le paramètre `l`, on définit une fonction, donc généralisée.

</details>

---

**72.** Lesquelles de ces affirmations sur `Fun` sont vraies ?

- **A)** `Fun.id : 'a -> 'a`
- **B)** `Fun.const 1 "x"` vaut `1`
- **C)** `Fun.flip (-) 1 10` vaut `9`
- **D)** `Fun.const : 'a -> 'a -> 'a`

<details>
<summary>Réponse</summary>

**Bonnes : A, B, C** *Concept : Combinateurs de la bibliothèque standard.*

- **A.** Vrai.
- **B.** Vrai : `const` ignore son second argument.
- **C.** Vrai : `flip (-) 1 10` calcule `10 - 1`.
- **D.** Faux : le second argument est libre, `'a -> 'b -> 'a`.

</details>

---

**73.** Lesquelles de ces extraits contiennent une construction proscrite par le style du cours ?

- **A)** `let r = ref 0`
- **B)** `List.hd l`
- **C)** `List.fold_left (+) 0 l`
- **D)** `if a != b then 0 else 1`

<details>
<summary>Réponse</summary>

**Bonnes : A, B, D** *Concept : Constructions proscrites.*

- **A.** Oui : `ref` est proscrit.
- **B.** Oui : fonction partielle.
- **C.** Non : récursion sur liste exprimée par une fonction d'ordre supérieur.
- **D.** Oui : `!=` est proscrit, on écrit `<>`.

</details>

---

**74.** Lesquelles de ces affirmations sur les tableaux sont vraies ?

- **A)** `[|1; 2|]` a le type `int array`
- **B)** `[|1; 2|].(5)` lève `Invalid_argument`
- **C)** `[|1; 2|] == [|1; 2|]` vaut `true`
- **D)** `[|1; 2|] = [|1; 2|]` vaut `true`

<details>
<summary>Réponse</summary>

**Bonnes : A, B, D** *Concept : Les tableaux sont mutables et proscrits dans le cours.*

- **A.** Vrai.
- **B.** Vrai : accès hors bornes.
- **C.** Faux : deux blocs distincts.
- **D.** Vrai : `=` compare le contenu.

</details>

---

**75.** Lesquelles de ces affirmations sur `ref` sont vraies ?

- **A)** `ref 0` a le type `int ref`
- **B)** `!r` est la négation booléenne de `r`
- **C)** `let r = ref 0 in r := !r + 2; !r` vaut `2`
- **D)** `r := 1` a le type `bool`

<details>
<summary>Réponse</summary>

**Bonnes : A, C** *Concept : Références : lecture avec `!`, affectation avec `:=`.*

- **A.** Vrai.
- **B.** Faux : `!` lit le contenu de la référence, `not` est la négation.
- **C.** Vrai : 0 + 2.
- **D.** Faux : `:=` retourne `unit`.

</details>

---

**76.** Lesquelles de ces affirmations sur `for` et `while` sont vraies ?

- **A)** `for i = 1 to 3 do print_int i done` a le type `unit`
- **B)** `for i = 3 to 1 do print_int i done` n'affiche rien
- **C)** `while false do () done` a le type `bool`
- **D)** Le corps d'une boucle ne sert qu'à produire des effets secondaires

<details>
<summary>Réponse</summary>

**Bonnes : A, B, D** *Concept : Boucles impératives (proscrites par le style).*

- **A.** Vrai.
- **B.** Vrai : la borne de départ dépasse la borne de fin.
- **C.** Faux : une boucle a toujours le type `unit`.
- **D.** Vrai : le corps est évalué pour ses effets, sa valeur est ignorée.

</details>

---

**77.** Lesquelles de ces expressions s'évaluent comme indiqué (`try` n'attrape que les exceptions nommées) ?

- **A)** `try 1 / 0 with Division_by_zero -> -1` vaut `-1`
- **B)** `try List.assoc 3 [(1, "a")] with Not_found -> "?"` vaut `"?"`
- **C)** `try failwith "x" with Not_found -> 0` vaut `0`
- **D)** `int_of_string "x"` lève `Failure "int_of_string"`

<details>
<summary>Réponse</summary>

**Bonnes : A, B, D** *Concept : `try` n'attrape que les exceptions nommées.*

- **A.** Vrai.
- **B.** Vrai : `List.assoc` lève `Not_found`.
- **C.** Faux : `Failure` n'est pas `Not_found`, l'exception se propage.
- **D.** Vrai.

</details>

---

**78.** Soit `exception Neg of int` et `let f n = if n < 0 then raise (Neg n) else n`. Lesquelles sont vraies ?

- **A)** `Neg 3` a le type `exn`
- **B)** `try f (-3) with Neg k -> k` vaut `-3`
- **C)** `raise (Neg 1)` a le type `exn`
- **D)** `f 2` lève `Neg`

<details>
<summary>Réponse</summary>

**Bonnes : A, B** *Concept : Exceptions personnalisées.*

- **A.** Vrai : `Neg` est un constructeur de type `exn`.
- **B.** Vrai : le gestionnaire récupère l'argument.
- **C.** Faux : `raise` retourne `'a`, pas `exn`.
- **D.** Faux : `f 2` retourne 2.

</details>

---

**79.** Lesquelles de ces affirmations sur le typage des exceptions sont vraies ?

- **A)** `try 1 with _ -> "a"` est rejeté
- **B)** `raise Exit` a le type `'a`
- **C)** `try raise Exit with Not_found -> 0` retourne `0`
- **D)** `let f x = if x then 1 else raise Exit` a le type `bool -> int`

<details>
<summary>Réponse</summary>

**Bonnes : A, B, D** *Concept : Les branches du `try` ont le même type.*

- **A.** Vrai : le corps et le gestionnaire doivent avoir le même type.
- **B.** Vrai : `raise` s'adapte à tout contexte.
- **C.** Faux : `Exit` n'est pas `Not_found`, l'exception se propage.
- **D.** Vrai : `raise Exit` prend le type `int`.

</details>

---

**80.** Lesquelles de ces affirmations sont vraies (`match ... with exception` et fonctions qui lèvent) ?

- **A)** `match int_of_string "x" with n -> n | exception Failure _ -> 0` vaut `0`
- **B)** `assert false` a le type `'a`
- **C)** `failwith : string -> 'a`
- **D)** `invalid_arg "m"` lève `Failure "m"`

<details>
<summary>Réponse</summary>

**Bonnes : A, B, C** *Concept : `match ... with exception` et fonctions qui lèvent.*

- **A.** Vrai : le cas `exception` attrape l'échec de la conversion.
- **B.** Vrai.
- **C.** Vrai.
- **D.** Faux : `invalid_arg` lève `Invalid_argument`.

</details>

---

**81.** Lesquelles de ces affirmations sur les exceptions sont vraies ?

- **A)** `List.assoc` retourne `None` si la clé est absente
- **B)** `int_of_string "x"` retourne `0`
- **C)** `List.hd []` retourne `[]`
- **D)** `try e with _ -> ...` n'attrape que `Failure`

<details>
<summary>Réponse</summary>

**Bonnes : aucune** *Concept : Fonctions partielles et gestionnaires.*

- **A.** Faux : elle lève `Not_found`, c'est `assoc_opt` qui retourne `None`.
- **B.** Faux : elle lève `Failure "int_of_string"`.
- **C.** Faux : elle lève `Failure "hd"`.
- **D.** Faux : `_` attrape toute exception.

</details>

---

**82.** Lesquelles de ces expressions sont bien typées ?

- **A)** `let x : int = "a"`
- **B)** `List.map succ 1`
- **C)** `"n=" ^ 3`
- **D)** `fst [1; 2]`

<details>
<summary>Réponse</summary>

**Bonnes : aucune** *Concept : Erreurs de typage courantes.*

- **A.** Non : annotation `int` contredite par une chaîne.
- **B.** Non : `List.map` attend une liste, pas un entier.
- **C.** Non : `^` ne concatène que des chaînes, `string_of_int` est nécessaire.
- **D.** Non : `fst` attend un couple, pas une liste.

</details>

---

**83.** Lesquelles de ces constructions sont acceptées par le style du cours ?

- **A)** `if a == b then 1 else 0`
- **B)** `let t = Array.make 3 0 in ...`
- **C)** `for i = 0 to 9 do print_int i done`
- **D)** `List.hd l`

<details>
<summary>Réponse</summary>

**Bonnes : aucune** *Concept : Constructions proscrites.*

- **A.** Non : `==` est proscrit, on écrit `=`.
- **B.** Non : les tableaux sont proscrits.
- **C.** Non : `for` est proscrit, on écrit une récursion.
- **D.** Non : fonction partielle proscrite.

</details>

---

**84.** Lesquelles de ces affirmations sur l'évaluation sont vraies ?

- **A)** `lazy e` évalue `e` immédiatement
- **B)** `Lazy.force` réévalue l'expression à chaque appel
- **C)** Les arguments d'une fonction sont évalués paresseusement par défaut
- **D)** `Seq.ints 0` construit d'avance toute la liste des entiers

<details>
<summary>Réponse</summary>

**Bonnes : aucune** *Concept : OCaml est strict sauf demande explicite.*

- **A.** Faux : `lazy` retarde l'évaluation jusqu'au premier `force`.
- **B.** Faux : le résultat est mémorisé.
- **C.** Faux : l'évaluation est stricte.
- **D.** Faux : la séquence produit ses éléments à la demande.

</details>

---
