# Fonctions, curryfication et ordre supérieur

> Recueil, chapitre 3, pages 143 à 169, 262 à 268 et 298 à 320

Cette fiche couvre la façon dont OCaml conçoit les fonctions : toujours à un
seul paramètre, ce qui rend la curryfication et l'application partielle
gratuites plutôt qu'un cas spécial. Elle couvre aussi les fonctions d'ordre
supérieur qui en découlent — au premier chef les quatre opérations sur les
listes que tout QCM du cours interroge sur leur type exact :
`List.map`, `List.filter`, `List.fold_left`, `List.fold_right`.

## Ce qu'il faut savoir dire

| Terme | Définition attendue |
|---|---|
| Curryfication | Une fonction à `n` paramètres est conceptualisée comme une fonction à un paramètre qui renvoie une fonction à `n - 1` paramètres. |
| Application partielle | Appliquer une fonction à `k < n` arguments ; le résultat est une nouvelle fonction, de type `t_(k+1) -> ... -> t_n -> t`. |
| Fonction anonyme | Une fonction sans nom, introduite par `fun P1 ... Pn -> EXP` (sucre syntaxique pour des `function` imbriqués). |
| Fonction d'ordre supérieur | Une fonction qui a un paramètre de type fonction, ou qui renvoie une fonction. Toute fonction curryfiée à ≥ 2 paramètres en est déjà une. |
| Composition | `compose f1 f2 = fun x -> f1 (f2 x)`, de type `('a -> 'b) -> ('c -> 'a) -> 'c -> 'b`. |
| Pliage à gauche / à droite | Les deux façons de réduire une liste avec un élément initial (la graine) : `fold_left` construit `(...(e • e1) • e2...) • en`, associatif depuis la gauche et récursif terminal ; `fold_right` construit `e1 • (e2 • (... • (en • e)))`, associatif depuis la droite et non terminal. |
| Fermeture (portée statique) | Une fonction locale capture la valeur des identificateurs visibles à sa *définition*, pas à son appel. |

## Syntaxe et sémantique

### Curryfication et applications partielles

```ocaml
# let sum_squares x1 x2 = x1 * x1 + x2 * x2;;
val sum_squares : int -> int -> int = <fun>
# sum_squares 5 (2 + 1);;
- : int = 34
# sum_squares 0;;
- : int -> int = <fun>
```

`int -> int -> int` se lit `int -> (int -> int)` : `sum_squares` prend un
argument et renvoie une fonction. Une fonction à trois paramètres,
`surround pref suff fact = pref ^ fact ^ suff`, se comporte pareil pour
n'importe quel nombre d'arguments fournis (de 0 à 3) :

```ocaml
# let surround pref suff fact = pref ^ fact ^ suff;;
val surround : string -> string -> string -> string = <fun>
# surround "((" "))";;
- : string -> string = <fun>
# let surround' fact = surround "((" "))" fact;;
val surround' : string -> string = <fun>
# surround' "abc";;
- : string = "((abc))"
```

Pour spécialiser un paramètre autre que le premier sans toucher aux autres,
`Fun.flip` inverse les deux premiers arguments :

```ocaml
# Fun.flip;;
- : ('a -> 'b -> 'c) -> 'b -> 'a -> 'c = <fun>
# let f' = Fun.flip (-) 1;;
val f' : int -> int = <fun>
# f' 2;;
- : int = 1
```

### Fonctions anonymes

```ocaml
# (fun a b -> (a + b) * a) 4 3;;
- : int = 28
# let produit k = fun x -> x * k;;
val produit : int -> int -> int = <fun>
```

`fun P1 ... Pn -> EXP` est du sucre pour
`function P1 -> function P2 -> ... -> function Pn -> EXP`, et
`let F P1 ... Pn = EXP` est du sucre pour `let F = fun P1 ... Pn -> EXP`.
Ce ne sont pas trois manières indépendantes de définir une fonction : c'est
une seule construction (`function`, un paramètre) déclinée par sucre
syntaxique successif.

### Composition et opérateur d'application inversée

```ocaml
# let compose f1 f2 = fun x -> f1 (f2 x);;
val compose : ('a -> 'b) -> ('c -> 'a) -> 'c -> 'b = <fun>
# let f = compose succ succ;;
val f : int -> int = <fun>
# f 0;;
- : int = 2
# (|>);;
- : 'a -> ('a -> 'b) -> 'b = <fun>
```

`e |> f` est équivalent à `f e` ; enchaîné, `e |> f1 |> f2 |> ... |> fn`
remplace `fn (... (f2 (f1 e)) ...)`. C'est pour cette raison que les fonctions
de la bibliothèque standard sur les listes prennent la liste en *dernier*
argument : ça les rend chaînables avec `|>`.

### Fermetures et portée statique

```ocaml
# let x = 2 in let f y = x * y in let x = 10 in f 3;;
Warning 26 [unused-var]: unused variable x.
- : int = 6
```

`f` capture le `x` visible à sa définition (2). Le `let x = 10` qui suit crée
une liaison distincte, jamais lue par `f` — d'où l'avertissement du
compilateur : ce second `x` est réellement inutilisé.

Une fonction locale suit les mêmes règles d'ombrage qu'une liaison locale, et
peut être définie simultanément à une autre avec `and` :

```ocaml
# let f x = let g y = y - 2 = x and h x = 2 * x in g (h x);;
val f : int -> bool = <fun>
# f 1;;
- : bool = false
# f 2;;
- : bool = true
```

### Opérateurs d'ordre supérieur sur les listes

Types exacts, vérifiés sur le toplevel OCaml **5.5.1** du cours — les noms de
variables de type diffèrent de ceux imprimés dans le recueil (`'a`/`'b`) et
utilisent `'acc` là où une valeur joue le rôle d'accumulateur :

```ocaml
# List.map;;
- : ('a -> 'b) -> 'a list -> 'b list = <fun>
# List.filter;;
- : ('a -> bool) -> 'a list -> 'a list = <fun>
# List.fold_left;;
- : ('acc -> 'a -> 'acc) -> 'acc -> 'a list -> 'acc = <fun>
# List.fold_right;;
- : ('a -> 'acc -> 'acc) -> 'a list -> 'acc -> 'acc = <fun>
```

| Fonction | Rôle | Récursion |
|---|---|---|
| `List.map f lst` | transforme chaque élément par `f` | — |
| `List.filter f lst` | garde les éléments où `f` (prédicat) est vrai | — |
| `List.fold_left f acc lst` | plie depuis la gauche, `acc` est le paramètre *avant* l'élément courant | terminale |
| `List.fold_right f lst acc` | plie depuis la droite, `acc` est le paramètre *après* l'élément courant | non terminale |

L'ordre des paramètres de `f` distingue les deux pliages, et ce n'est pas un
détail cosmétique : quand l'opération n'est ni commutative ni associative au
sens strict, les deux donnent des résultats différents.

```ocaml
# List.fold_left (fun acc x -> acc - x) 0 [1; 2; 3];;
- : int = -6
# List.fold_right (fun x acc -> x - acc) [1; 2; 3] 0;;
- : int = 2
```

`fold_left` calcule `((0 - 1) - 2) - 3 = -6` ; `fold_right` calcule
`1 - (2 - (3 - 0)) = 2`. Même opérateur `-`, même liste, même graine, deux
résultats.

`List.fold_left` est la bonne alternative dès que l'ordre des opérations
n'importe pas et que la liste peut être grande : elle est récursive terminale,
`List.fold_right` ne l'est pas. `List.fold_right` reste nécessaire quand
l'ordre du calcul doit respecter celui de la liste (par exemple pour
réimplanter `List.map` en préservant l'ordre des éléments).

Exemples d'enchaînement avec `|>`, dans le style que la bibliothèque
standard encourage :

```ocaml
# [1; 2; 3] |> List.map (fun x -> x * (-2)) |> List.fold_left (+) 0;;
- : int = -12
# let fact n = List.init n succ |> List.fold_left ( * ) 1;;
val fact : int -> int = <fun>
# List.init 8 fact;;
- : int list = [1; 1; 2; 6; 24; 120; 720; 5040]
```

### Opérateurs comme fonctions

`(+)`, `(-)`, `(^)`, `(=)` sont des valeurs de type fonction comme les autres,
utilisables partout où une fonction est attendue une fois entre parenthèses :

```ocaml
# (+) 1;;
- : int -> int = <fun>
```

## Ce qui diffère de l'impératif

| Réflexe impératif | Ce que fait OCaml |
|---|---|
| Une méthode a une arité fixe ; l'appeler avec moins d'arguments est une erreur de compilation. | Toute fonction est unaire ; l'appliquer à moins d'arguments que son arité apparente produit une fonction valide (application partielle). |
| Une lambda capture les variables par référence ou par valeur selon des règles explicites du langage. | La capture suit simplement la portée statique : la valeur visible à la définition, point final — aucune notion de capture par référence. |
| `reduce`/`foldl`/`foldr` d'une bibliothèque tierce ont souvent un ordre de paramètres qui varie d'un langage à l'autre. | `List.fold_left` et `List.fold_right` ont chacun un ordre de paramètres fixe et distinct (`acc` avant ou après l'élément), qui reflète directement le sens du pliage. |
| Composer deux fonctions demande une bibliothèque ou une syntaxe dédiée. | `compose f1 f2 = fun x -> f1 (f2 x)` s'écrit directement, et `|>` sert le même besoin pour enchaîner des appels sans les composer explicitement. |

## Pièges de QCM

**1. `int * int -> int` pour le type de `sum_squares`.**
Plausible parce que c'est un type OCaml valide et que « deux paramètres »
évoque un couple pour qui vient d'un langage non curryfié. Faux : c'est le
type d'une fonction prenant un unique argument, un couple ; `sum_squares`
telle que définie est `int -> int -> int`.

**2. `('a -> 'b) -> 'a list -> 'b list` comme type de `List.fold_left`.**
Plausible : c'est bien le type de `List.map`, une fonction voisine qui prend
aussi une fonction et une liste. Faux pour `fold_left`, dont le type est
`('acc -> 'a -> 'acc) -> 'acc -> 'a list -> 'acc` — il prend en plus une
graine et renvoie une valeur, pas une liste.

**3. Résultat identique pour `List.fold_left` et `List.fold_right` avec le
même opérateur et la même graine.**
Plausible quand l'opérateur semble « juste combiner des nombres ». Faux dès
que l'opérateur n'est pas associatif-commutatif au sens qui rend les deux
pliages équivalents : `List.fold_left (fun acc x -> acc - x) 0 [1;2;3]` vaut
`-6`, `List.fold_right (fun x acc -> x - acc) [1;2;3] 0` vaut `2`.

**4. `30` pour `let x = 2 in let f y = x * y in let x = 10 in f 3`.**
Plausible en portée dynamique (`f` verrait le `x` du contexte d'appel). Faux
en OCaml, à portée statique : `f` capture le `x = 2` visible à sa définition ;
résultat `6`.

**5. `f (a, b)` équivalent à `f a b` pour une fonction OCaml curryfiée.**
Plausible en venant d'un langage où l'appel `f(a, b)` est la seule syntaxe
disponible. Faux : `f (a, b)` applique `f` à un unique argument, un couple —
ce n'est bien typé que si `f` a été définie avec un paramètre couple
(`let f (x, y) = ...`), une fonction différente de `let f x y = ...`.

## À retenir par cœur

- Toute fonction OCaml est unaire ; `t1 -> t2 -> t` se lit `t1 -> (t2 -> t)`.
- Une application partielle (`k < n` arguments) renvoie une fonction, jamais
  une erreur.
- Une fermeture capture la valeur au moment de la *définition*, pas de
  l'appel.
- `List.fold_left f acc lst` : récursif terminal, `acc` avant l'élément.
- `List.fold_right f lst acc` : non terminal, `acc` après l'élément, préserve
  l'ordre pour reconstruire une liste.
- Sur OCaml 5.5.1, `List.fold_left` affiche `('acc -> 'a -> 'acc) -> 'acc -> 'a list -> 'acc`,
  pas `('a -> 'b -> 'a) -> ...`.
- `compose f1 f2 = fun x -> f1 (f2 x)` ; `e |> f` est un simple sucre pour
  `f e`, pas une composition.
- Un opérateur entre parenthèses, `(+)`, `(^)`, est une fonction ordinaire.
