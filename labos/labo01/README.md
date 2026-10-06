# Labo 01 : premiers pas avec OCaml

Labo non noté, résolu pour réviser. Énoncé : <https://inf6120.uqam.ca/labos/labo01/>.

## Lancer

```
cd labos/labo01
dune build --root .     # aucun warning attendu
dune test --root . --force
```

Le code est dans `labo1.ml` (sections 3, 5, 6), les tests dans `test/test_labo1.ml`.
Les sections 1 et 7 (installation, `ocaml hello.ml`, `ocamlc`) sont de l'outillage.
Les sections 2 et 4 se répondent au toplevel : réponses vérifiées ci-dessous (OCaml 5.5).

## Section 2 : types des expressions

| Expression | Résultat |
|---|---|
| `2` | `int` |
| `2.0` | `float` |
| `2,0` | `int * int` : la virgule fabrique un couple, pas une décimale |
| `2;0` | `0 : int` (avertissement : `2` jeté, il devrait être `unit`) |
| `(2, 0)` | `int * int` |
| `(2; 0)` | `0 : int`, même avertissement |
| `a` | erreur : `Unbound value a` (identificateur, pas une chaîne) |
| `'a'` | `char` |
| `"a"` | `string` |
| `true` | `bool` |
| `()` | `unit` |
| `[]` | `'a list` (polymorphe) |
| `[1]` | `int list` |
| `[1, true]` | `(int * bool) list` : liste d'UN couple (virgule) |
| `[1; true]` | erreur : les éléments d'une liste ont tous le même type |

Exemples de types : `int * float` : `(1, 2.5)` ; `string list` : `["a"; "b"]` ;
`bool list * string` : `([true], "x")` ; `int list list` : `[[1]; [2; 3]]`.

## Section 2 : calculs

| Expression | Résultat |
|---|---|
| `1 + 2` | `3` |
| `1.1 + 2.2` | erreur : `+` est pour les `int`, il faut `+.` |
| `1.1 + 2` | erreur, même raison (pas de conversion implicite) |
| `2 / 3` | `0` : division entière |
| `7 mod 2` | `1` |
| `7. mod 3.` | erreur : `mod` est entier, pour les flottants `mod_float` |
| `int_of_float (2. ** 3.)` | `8` |
| `2 = 3` | `false` |
| `'a' = 'b'` | `false` |
| `"a" = 'a'` | erreur : `string` contre `char` |
| `not 1 = 0` | erreur : s'analyse `(not 1) = 0`, et `1` n'est pas un `bool` |
| `not (1 = 0)` | `true` |

`&&` et `||` sont séquentiels. Tests : `false && (print_string "D"; true)` renvoie
`false` sans rien afficher ; `true || (print_string "D"; true)` renvoie `true` sans rien
afficher ; `(print_string "G"; true) && (print_string "D"; false)` affiche `GD`
(la droite n'est évaluée que si la gauche est vraie), et
`(print_string "G"; false) || (print_string "D"; true)` affiche `GD` (la droite n'est
évaluée que si la gauche est fausse).

## Section 4 : liaisons

| Code | Résultat |
|---|---|
| `let a = 1 in a + 2;;` puis `a + 3;;` | `3`, puis erreur : le `a` local n'existe plus |
| `let b = 5;; let b = 5.5;;` | permis : la 2e liaison MASQUE la 1re (nouveau nom, autre type) |
| `let c = 1;; let d = c;; c + d;;` | `2` |
| `let e = 1 let f = e;;` | permis dans un fichier : deux définitions de suite |
| `let g = 1 and h = g;;` | erreur : avec `and`, `h` ne voit pas `g` (liaisons simultanées) |
| `let a = 1 in let b = a;;` | erreur de syntaxe : un `let ... in` local exige une expression finale |
| `let a = 1 in let b = a in b;;` | `1` |

```
let a = 1;;                      (* val a : int = 1 *)
let a = 1.2 in a;;               (* 1.2, le a global reste 1 *)
a;;                              (* 1 *)
let a = 1 in
let a = 2 and b = a in           (* b voit le a précédent : 1 *)
a + b;;                          (* 3 *)
```

## Section 5 : pièges

- `if a mod 2 = 0 then a else "odd"` : les deux branches doivent avoir le même type.
- `if a < 10 then let b = "small" else let b = "large"` : un `let` sans `in` n'est pas
  une expression. Correct : `let b = if a < 10 then "small" else "large"`
  (voir `etiquette`).
- `plafond_moitie` : la division entière tronque vers 0, attention aux négatifs.

## Section 6 : réponses courtes

- `average` fonctionne sur `int` seulement (`+`, `/` entiers) ; version flottante
  `average_float` avec `+.` et `/.`.
- `inv_fst_snd` et `inv` : type `'a * 'b -> 'b * 'a` ; `inv_int` : `int * int -> int * int`.
- `f_one : unit -> int`.
- Le bloc `m`, `f`, `g` : `f 4` = `4` ; `g 4` = `7` ; après `let m = 5`, `g 4` reste `7`
  (la fermeture garde le `m` qui existait à la définition : liaison, pas affectation) ;
  `f m` = `5`.

## Concepts à retenir

`let ... in` est une expression ; `and` lie en parallèle ; une liaison masque, ne modifie
pas ; `if` est une expression (branches du même type) ; opérateurs distincts pour `int`
(`+`) et `float` (`+.`) ; `&&`/`||` sont paresseux.
