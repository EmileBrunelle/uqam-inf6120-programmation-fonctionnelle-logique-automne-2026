# Types, attribution et inférence

> Recueil, chapitre 2, pages 85 à 103 ; chapitre 3, pages 104 à 169 et 286 à 290

Cette fiche couvre le socle sur lequel repose tout le reste du cours : ce que
sont une expression, une liaison, un type, et comment OCaml décide, sans
qu'on le lui dise, du type de chaque expression. C'est la matière la plus
mécanique du cours — donc la plus rentable en QCM, parce qu'il existe une
procédure qui donne toujours la bonne réponse, et que les distracteurs
recyclent presque toujours la réponse d'un autre langage ou d'une règle
appliquée à moitié.

## Ce qu'il faut savoir dire

| Terme | Définition attendue |
|---|---|
| Liaison globale | `let ID = EXP` : une déclaration (pas une expression, pas de valeur) qui rend `ID` visible dans la suite du programme. |
| Liaison locale | `let ID = EXP1 in EXP2` : une expression, de valeur celle de `EXP2` où les occurrences libres de `ID` sont remplacées par la valeur de `EXP1`. |
| Ombrage de nom | Une nouvelle liaison du même identificateur masque l'ancienne pour la suite de sa portée ; l'ancienne liaison n'est pas modifiée, seulement rendue inaccessible. |
| Vérification des types (statique / dynamique) | Statique : vérifiée à la compilation. Dynamique : vérifiée à l'exécution. OCaml est à vérification statique. |
| Attribution des types (explicite / implicite / hybride) | Explicite (Church-style) : les types sont écrits dans le programme. Implicite (Curry-style) : ils sont devinés par le système d'inférence. OCaml est hybride : les annotations sont facultatives. |
| Inférence des types | Le mécanisme, statique et implicite, qui déduit le type le plus général compatible avec l'usage de chaque identificateur, sans qu'il soit déclaré. |
| Polymorphisme paramétrique | Un paramètre de type est soit un type précis, soit entièrement quelconque (`'a`) — jamais restreint à une sous-collection de types. |
| Restriction aux valeurs | OCaml ne généralise (ne rend polymorphe) que le résultat d'une *valeur syntaxique* — un `fun`, une constante — jamais le résultat d'une application de fonction. |

## Syntaxe et sémantique

### Liaisons

```ocaml
# let n = 5;;
val n : int = 5
# let n = 5 in n + 1;;
- : int = 6
# let n = 3;;
val n : int = 3
# let n = 4 in 2 * n;;
- : int = 8
# n;;
- : int = 3
```

La liaison locale du bloc `let n = 4 in ...` n'a aucun effet sur le `n` global :
elle n'existe que dans la portée de son `in`.

Liaisons simultanées (`and`) : toutes les expressions de droite sont évaluées
dans le contexte qui précède le `let`, pas les unes par rapport aux autres.

```ocaml
# let x = 1 in let x = 2 and y = x + 3 in x + y;;
- : int = 6
# let x = 1 in let x = 2 in let y = x + 3 in x + y;;
Warning 26 [unused-var]: unused variable x.
- : int = 7
```

Dans la première phrase, le `x` qui sert à calculer `y` est celui de la ligne
1 (valeur 1), parce que `and` définit `y` *avant* que le nouveau `x` prenne
effet. En remplaçant `and` par un `in`, les liaisons deviennent séquentielles :
`y` voit le nouveau `x` (valeur 2).

### Types de base

| Type | Contenu |
|---|---|
| `int` | entiers signés (63 bits utiles sur système 64 bits : un bit sert à la gestion mémoire) |
| `float` | flottants signés, s'écrivent toujours avec un point (`0.`, `4.52`) |
| `char` | caractères ASCII, entre apostrophes ou par code (`'\101'`) |
| `string` | chaînes, concaténées par `^` |
| `bool` | `true` / `false` |
| `unit` | type singleton, unique valeur `()` |

```ocaml
# max_int;;
- : int = 4611686018427387903
# 2 +. 3.5;;
Error: The constant 2 has type int but an expression was expected of type
         float
Hint: Did you mean 2.?
# 1 / 0;;
Exception: Division_by_zero.
```

Aucune conversion numérique implicite : `int` et `float` ne se mélangent
jamais sans passer par `float_of_int` ou `int_of_float`.

### Expressions conditionnelles

```ocaml
# if (3 >= 2) || ("aab" <= "aa") then "ABC" else "CDE";;
- : string = "ABC"
```

Les deux branches doivent avoir le même type. Une demi-conditionnelle
`if COND then EXP` est sucre syntaxique pour `if COND then EXP else ()`, donc
`EXP` doit être de type `unit`.

### La procédure d'inférence

1. Une variable de type fraîche par paramètre.
2. Une contrainte par usage dans le corps (`x + 1` force `int`, `x ^ "a"` force
   `string`).
3. Un `if` ou un `match` force ses branches au même type.
4. Aucune contrainte trouvée : le paramètre reste polymorphe (`'a`, `'b`, ...).
5. On assemble de gauche à droite : `t1 -> t2 -> ... -> t`, où `->` associe à
   **droite**.

```ocaml
# let mystere x y z = if x && (y 1) then z;;
val mystere : bool -> (int -> bool) -> unit -> unit = <fun>
# let etrange x y = "a" ^ ((y 1) ((x 'a') + 1)) ^ "b";;
val etrange : (char -> int) -> (int -> int -> string) -> string = <fun>
# let bizarre y = ((fun x -> x + 1) 2) + (y (string_of_int 3));;
val bizarre : (string -> int) -> int = <fun>
```

Pour `mystere` : `z` n'est contraint par rien d'autre que d'être la valeur de
retour d'un `if` dont l'autre branche est implicite (`()`), donc `z : unit`
et le retour est `unit`. Pour `bizarre` : `y` est appelée avec un `string`
(argument de `y`) et son résultat est additionné à un `int`, donc
`y : string -> int`.

### Annotations de types

```ocaml
# let pair x y = (x, y);;
val pair : 'a -> 'b -> 'a * 'b = <fun>
# let pair (x : string) y = (x, y);;
val pair : string -> 'a -> string * 'a = <fun>
# let pair x y : (int * int) = (x, y);;
val pair : int -> int -> int * int = <fun>
```

Annoter un paramètre ou le retour ajoute une contrainte que l'inférence doit
respecter — cela restreint le type le plus général, ça ne l'étend jamais.

### Polymorphisme

```ocaml
# let vrai x = true;;
val vrai : 'a -> bool = <fun>
# type 'e liste = Vide | Cellule of 'e * 'e liste;;
type 'a liste = Vide | Cellule of 'a * 'a liste
# Vide;;
- : 'a liste = Vide
```

Trois notions distinctes à savoir nommer : une **fonction polymorphe** a un
paramètre dont le type est quelconque (`vrai`) ; un **type polymorphe** est un
type paramétré (`'a liste`) ; une **valeur polymorphe** est une valeur d'un
type paramétré non encore spécialisé (`Vide`, `[]`).

`(=)`, `(<>)`, `compare`, `fst`, `snd` sont polymorphes dans la bibliothèque
standard :

```ocaml
# (=);;
- : 'a -> 'a -> bool = <fun>
# compare;;
- : 'a -> 'a -> int = <fun>
```

### Restriction aux valeurs

```ocaml
# let id x = x;;
val id : 'a -> 'a = <fun>
# (fun x -> x) (fun x -> x);;
- : '_weak1 -> '_weak1 = <fun>
```

`id`, défini directement comme un `fun`, est généralisé : `'a -> 'a`.
`(fun x -> x) (fun x -> x)` est le résultat d'une *application* — pas une
valeur syntaxique — donc OCaml refuse de le généraliser et produit une
variable de type **faible** `'_weak1`, qui sera fixée définitivement au
premier usage concret.

## Ce qui diffère de l'impératif

| Réflexe impératif | Ce que fait OCaml |
|---|---|
| Le type est déclaré, le compilateur le vérifie contre l'annotation. | Le type est déduit de l'usage ; l'annotation, quand elle existe, n'est qu'une contrainte de plus. |
| Une variable peut être réaffectée (`x = 10`). | Il n'y a pas d'affectation. `let x = 10` dans une portée existante crée une *nouvelle* liaison qui masque l'ancienne. |
| `==` est l'égalité (à vérifier). | `=` est l'égalité structurelle (l'équivalent d'`equals`) ; `==` est l'identité physique, quasi jamais utilisée et proscrite par le guide de style du cours. |
| Une fonction générique (`<T>`) peut être spécialisée dynamiquement, avec `instanceof`. | Le polymorphisme est paramétrique : un paramètre est soit d'un type fixe, soit totalement quelconque. Rien ne permet de distinguer les cas à l'intérieur de la fonction. |
| Un type inféré (`var` en Java, `auto` en C++) est celui de l'expression concrète assignée. | Le type inféré est le plus général compatible avec *tous* les usages, sauf lorsque la restriction aux valeurs l'en empêche. |

## Pièges de QCM

**1. `'a -> 'a` pour `(fun x -> x) (fun x -> x)`.**
Plausible parce que c'est le type de la fonction identité elle-même, et que la
lecture rapide de l'expression y voit deux identités qui s'annulent. Faux :
c'est le résultat d'une *application*, pas un `fun` ni une constante, donc la
restriction aux valeurs interdit la généralisation ; la bonne réponse est
`'_weak1 -> '_weak1`.

**2. `int * int -> int` pour le type de `add` défini par `let add x y = x + y`.**
Plausible parce que c'est effectivement le type d'une fonction à deux
paramètres dans beaucoup de langages, et que c'est un type OCaml valide.
Faux : c'est le type d'une *autre* fonction, `let add (x, y) = x + y`, qui
prend un seul argument (un couple). `add` telle que définie est curryfiée :
`int -> int -> int`.

**3. `30` pour `let x = 2 in let f y = x * y in let x = 10 in f 3`.**
Plausible en portée dynamique, où `f` verrait la valeur de `x` au moment de
son *appel*. Faux en OCaml : la portée est statique, `f` capture le `x`
visible à sa *définition* (2), et le `let x = 10` qui suit crée une liaison
distincte qui ne modifie rien à celle capturée. Résultat : `6`.

**4. Erreur de compilation pour `1 = 1.0`.**
Le message d'erreur cité (« expression has type int but an expression was
expected of type float ») est réel, mais certains QCM proposent plutôt
« `false` » comme piège, en présumant une comparaison structurelle entre deux
valeurs numériquement égales. Faux dans les deux sens : ce n'est ni `true` ni
`false`, l'expression ne type-check pas du tout — `int` et `float` ne se
comparent jamais sans conversion explicite.

**5. `'a -> 'a -> unit` pour `mystere` (`let mystere x y z = if x && (y 1) then z`) en oubliant un paramètre.**
Plausible si on compte seulement les usages contraignants (`x` dans `&&`,
`y` appliquée) et qu'on perd `z` en chemin. Faux : `mystere` a trois
paramètres et son type complet est
`bool -> (int -> bool) -> unit -> unit`, avec `z : unit` parce que l'autre
branche implicite du `if` est `()`.

## À retenir par cœur

- `let ID = EXP` est une déclaration sans valeur ; `let ID = EXP1 in EXP2` est
  une expression dont la valeur est celle de `EXP2`.
- L'ombrage masque, il ne modifie jamais une liaison existante.
- `->` associe à droite, l'application associe à gauche.
- OCaml : vérification statique, attribution hybride (annotations facultatives).
- `=` compare le contenu, `==` compare l'adresse ; `==` est proscrit par le
  style du cours.
- Un paramètre de type est soit fixe, soit `'a` — jamais une union de types.
- Seule une valeur syntaxique (`fun`, constante) est généralisée ; le résultat
  d'une application reste à type faible (`'_weak1`) jusqu'à son premier usage.
