# Récursion et filtrage de motifs

> Recueil, chapitre 3, sections 3.6 « Récursivité » et 3.7 « Filtrage de
> motifs », pages 226–262. Les démonstrations d'équivalence par induction
> structurelle sont en section 3.13, pages 357–367.

C'est la matière la plus dense en questions « écrire une fonction » et en
QCM combinés : le style noté du cours interdit `for`, `while`, `ref` et
`:=`, donc toute boucle impérative doit être retraduite en récursion, et
distinguer une fonction récursive terminale d'une qui ne l'est pas est un
réflexe attendu, pas une nuance théorique. Le filtrage de motifs, de son
côté, est le mécanisme qui remplace le `switch` et le déballage manuel d'un
type somme — et c'est là que se nichent la plupart des avertissements du
compilateur qu'un QCM peut citer mot pour mot.

## Ce qu'il faut savoir dire

| Terme | Définition attendue |
|---|---|
| Filtrage de motifs | `match EXP with \| MOTIF1 -> EXP1 \| ... \| MOTIFn -> EXPn` : évalue `EXP`, essaie les motifs de haut en bas, retourne l'expression du premier qui filtre. |
| Motif constant / à paramètre / composé | Constante littérale (`0`, `"abc"`) ; nom ou joker `_` qui filtre tout et lie (ou ignore) ; constructeur ou enregistrement qui déconstruit. |
| Garde | `MOTIF when TEST -> EXP` : le motif ne filtre que si `TEST` (de type `bool`) vaut `true`. |
| Exhaustivité | Un filtrage est exhaustif si tout élément possible du type peut être filtré par au moins un motif ; sinon le compilateur avertit (avertissement 8), et une valeur non couverte provoque une erreur à l'exécution. |
| Motif redondant | Un motif qu'aucune valeur ne peut plus atteindre parce qu'un motif antérieur couvre déjà tous les cas qu'il visait (avertissement 11). |
| Récursivité mutuelle | Deux ou plusieurs fonctions définies simultanément avec `let rec ... and ...`, chacune pouvant appeler les autres. |
| Récursivité terminale | L'appel récursif est la *dernière* opération : rien ne reste à faire au retour. Le compilateur la transforme en boucle, à mémoire constante. |
| Accumulateur | Paramètre supplémentaire qui porte le résultat en cours de construction, permettant de rendre une fonction récursive terminale. |
| Fonction locale auxiliaire | Fonction `let rec aux ... = ... in` définie à l'intérieur d'une autre, généralement pour porter un accumulateur sans l'exposer dans la signature publique. |
| Induction structurelle | Pour prouver une propriété `P` sur tout élément d'un type somme : montrer `P` pour chaque constructeur d'arité 0 (cas de base) et montrer que `P` sur les sous-éléments implique `P` sur le constructeur qui les combine (cas d'hérédité). |

## Syntaxe et sémantique

Filtrage non exhaustif — l'avertissement 8, reproduit tel qu'émis :

```ocaml
# let g = function [] -> 0 | [x] -> x;;
Line 1, characters 8-35:
1 | let g = function [] -> 0 | [x] -> x;;
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^
Warning 8 [partial-match]: this pattern-matching is not exhaustive.
  Here is an example of a case that is not matched: x::_::_

val g : int list -> int = <fun>
```

`x::_::_` se lit « au moins deux éléments » : les trois formes d'une liste
sont `[]`, `[x]` (soit `x :: []`) et `x :: y :: reste`.

Motif redondant — l'avertissement 11 : un joker placé avant absorbe tout,
rendant inaccessible le motif qui suit.

```ocaml
# let h n = match n with | _ -> 1 | 0 -> 2;;
Line 1, characters 34-35:
1 | let h n = match n with | _ -> 1 | 0 -> 2;;
                                      ^
Warning 11 [redundant-case]: this match case is unused.

val h : int -> int = <fun>
```

Garde :

```ocaml
let est_positif p =
  match p with
  | (x, y) when x >= 0 && y >= 0 -> true
  | (_, _) -> false
```

Récursivité mutuelle avec `let rec ... and ...` :

```ocaml
# let rec pair n = n = 0 || impair (n - 1)
  and impair n = n <> 0 && pair (n - 1);;
val pair : int -> bool = <fun>
val impair : int -> bool = <fun>
# pair 10;;
- : bool = true
# impair 10;;
- : bool = false
```

Récursivité terminale contre non terminale — le test à appliquer : *que
reste-t-il à faire après l'appel récursif ?*

```ocaml
(* non terminale : au retour, il reste le + à faire *)
# let rec somme l = match l with [] -> 0 | x :: r -> x + somme r;;
val somme : int list -> int = <fun>

(* terminale : l'appel est la dernière chose qui arrive *)
# let rec somme_t acc l = match l with [] -> acc | x :: r -> somme_t (acc + x) r;;
val somme_t : int -> int list -> int = <fun>
# somme_t 0 [1; 2; 3];;
- : int = 6
```

Transformation en accumulateur : ajouter un paramètre qui porte le résultat
partiel, faire disparaître l'opération qui suivait l'appel, puis enrober
dans une fonction publique qui fournit la valeur initiale de
l'accumulateur (en général celle du cas de base).

Induction structurelle : pour un type somme, chaque constructeur d'arité 0
est un cas de base à vérifier directement ; chaque constructeur d'arité
`n ⩾ 1` est un cas d'hérédité, où l'on suppose la propriété déjà vraie sur
ses `n` sous-éléments et où l'on montre qu'elle tient encore une fois
combinés par ce constructeur.

## Ce qui diffère de l'impératif

| Réflexe impératif | Ce que fait OCaml |
|---|---|
| Un `switch` sans `default` compile ; un cas oublié se découvre au mieux en test, au pire en production. | Un `match` non exhaustif déclenche un avertissement à la *compilation* (avertissement 8), avec un contre-exemple concret du cas manquant. |
| Une boucle `for`/`while` accumule dans une variable mutable modifiée à chaque tour. | Une fonction récursive terminale accumule dans un *paramètre*, réécrit à chaque appel — jamais modifié, seulement transmis avec une nouvelle valeur. |
| Deux fonctions mutuellement dépendantes se déclarent l'une après l'autre ; la seconde référence la première sans problème d'ordre. | `let rec f ... and g ... = ...` doit lier les deux *simultanément* : sans `and`, la définition de `f` ne voit pas encore `g`. |

## Pièges de QCM

1. **« `x :: aux r` est terminal, puisque `aux r` est bien le dernier appel
   de la ligne. »** Plausible parce que l'appel récursif est visuellement en
   fin d'expression. C'est faux : après le retour de `aux r`, il reste
   encore la construction de la cellule `x :: ...` à effectuer — c'est
   exactement la même situation que `x + somme r` ci-dessus, seul
   l'opérateur change.

2. **« Le `rec` ne fait que rendre la récursion possible ; sans lui, le nom
   n'est simplement pas lié. »** Plausible, et c'est bien ce qui arrive dans le
   cas courant — mais la formulation du recueil est plus précise : **`rec`
   change la portée du nom**. La différence se voit sans aucune récursion :

   ```ocaml
   # let x = 10 in let x = 20 in x + x;;
   - : int = 40
   # let rec x = let x = 20 in x + x;;
   val x : int = 40
   # let rec x = (let x = 20 in x) + x;;
   Error: This kind of expression is not allowed as right-hand side of let rec
   ```

   Dans la troisième expression, le `x` de droite désigne le `x` en cours de
   définition, et non un `x` extérieur : la liaison est circulaire, et le
   compilateur refuse cette forme de membre droit. Le distracteur à repérer est
   celui qui présente `rec` comme une simple autorisation d'appel récursif.

3. **« Dans `match n with | _ -> 1 | 0 -> 2`, le cas `0 -> 2` est prioritaire
   parce qu'il est plus spécifique que le joker. »** Plausible par analogie
   avec une résolution de surcharge qui préfère le cas le plus précis.
   C'est faux : le filtrage essaie les motifs strictement dans l'ordre
   d'écriture, et `_` en premier capture déjà tout — d'où l'avertissement 11
   « this match case is unused » sur la ligne `0 -> 2`.

4. **« Le motif manquant d'un filtrage sur `int list` limité à `[]` et
   `[x]` est la liste vide générique, notée `_`. »** Plausible si on
   cherche un contre-exemple générique plutôt que structurel. C'est faux :
   l'avertissement du compilateur donne un contre-exemple *précis*,
   `x::_::_`, qui décrit « au moins deux éléments » — la forme réellement
   non couverte, ni `[]` ni `[x]` n'étant concernée puisqu'ils sont déjà
   traités.

5. **« Prouver qu'une fonction sur un type somme est correcte pour tous ses
   cas revient à tester chaque constructeur un par un, comme un test
   unitaire par branche. »** Plausible parce que « couvrir tous les cas »
   évoque une couverture de tests. C'est faux : l'induction structurelle
   exige un cas d'hérédité qui suppose la propriété *déjà vraie* sur les
   sous-éléments (l'hypothèse d'induction) et la démontre pour l'élément
   combiné — un test isolé par constructeur ne fait la preuve d'aucun cas
   récursif, seulement des cas de base.

## À retenir par cœur

- Filtrage non exhaustif : `Warning 8 [partial-match]: this pattern-matching
  is not exhaustive.`, avec un contre-exemple concret.
- Motif inatteignable : `Warning 11 [redundant-case]: this match case is
  unused.`
- Test de terminalité : que reste-t-il à faire après l'appel récursif ? Rien
  ⇒ terminal ; un `+`, un `::`, un appel englobant ⇒ non terminal.
- Un accumulateur porte le résultat partiel en paramètre ; on l'initialise à
  la valeur du cas de base au moment d'enrober la fonction.
- `let rec f ... and g ... = ...` : sans `and`, `g` n'est pas visible dans le
  corps de `f`.
- Une garde (`when`) doit être vraie en plus du filtrage du motif pour que la
  clause s'applique.
- L'ordre des clauses d'un `match` fait foi : la première qui filtre gagne,
  peu importe la spécificité apparente des suivantes.
- Induction structurelle : cas de base (constructeurs d'arité 0) + cas
  d'hérédité (la propriété sur les sous-éléments implique la propriété sur le
  tout).
