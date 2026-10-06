# Devoir 2 — générateur de polyominos (OCaml + Prolog)

Devoir **d'entraînement non noté** d'INF6120 (automne 2025, S. Giraudo).
Énoncé : <https://www.giraudo.uqam.ca/Teaching/INF6120/2025-09/Devoir2.pdf>.
Solution rédigée à partir de l'énoncé seulement, comme matériel de révision.

## L'énoncé en bref

Un **polyomino** est un ensemble fini de cases du plan Z × Z. Deux parties :

1. **OCaml** : représenter cases et polyominos, en générer un au hasard par
   marche aléatoire, et écrire un fichier Prolog `Prolog/Polyomino.pl` qui le
   décrit par des faits `filled(square(X, Y)).`
2. **Prolog** : poser des questions sur ce polyomino : voisinage, occurrences
   de motifs, aire, chemins élémentaires, puis un résumé `print_information`.

| Partie | Fichier | Contenu |
|---|---|---|
| 3 | `lib/Squares.ml` | `make`, `origin`, `x_coordinate`, `y_coordinate` |
| 4 | `lib/Polyominos.ml` | `make`, `origin`, `squares`, `is_filled_square`, `area`, `add_square`, `bounding_box`, `to_string`, `to_prolog` |
| 5 | `lib/RandomGenerations.ml` | `adjacent_square`, `build_random` |
| 6 | `bin/Main.ml` | arguments `AIRE [GRAINE]`, écriture de `Prolog/Polyomino.pl` |
| 7 | `Prolog/Analysis.pl` | `add_squares/3`, `neighbor/2`, `filled_neighbor/2`, `filled_list/1`, `pattern_position/2`, `area/1`, `elementary_path/3,4`, `print_information/0` |
| 8 | `Run.sh` | génère puis analyse |

En plus de l'énoncé : `test/Tests.ml` (les exemples utop en assertions) et
`test/Requetes.pl` (les requêtes Prolog de l'énoncé). `Prolog/Polyomino.pl`
contient le « polyomino 10 » (`24 10`), celui des exemples de l'énoncé.

## Concepts à retenir

**OCaml**
- *Type somme à un seul constructeur* (`Square of (int * int)`) : on filtre
  directement dans le paramètre, `let x_coordinate (Square (x, _) : squares)`.
- *Invariant de représentation* : la liste d'un polyomino est triée et sans
  doublon ; seul `Polyominos.make` (`List.sort_uniq compare`) le construit.
- *Fonctions d'ordre supérieur* au lieu de boucles : `List.init` + `List.map`
  + `String.concat` pour le dessin, `List.fold_left` pour le rectangle englobant.
- *Boucle « tant que » → récursion terminale* : l'état (case marquée,
  polyomino) devient les paramètres de `walk` dans `build_random`.
- *Retardateur* `random_direction ()` : sans `()`, une seule valeur tirée.
- *Option* pour le cas vide (`bounding_box`), `int_of_string_opt` pour
  valider les arguments sans exception.

**Prolog**
- *CLP(FD)* : `#=` fonctionne dans les deux sens, `is/2` non ; c'est ce qui
  permet `add_squares(square(2,1), S, square(-4,5))`.
- *Générer puis tester* et *backtracking* : `member/2` énumère les décalages,
  `filled/1` énumère les positions, la suite filtre.
- *Application partielle* : `maplist(add_squares(S), Pat, Moved)`.
- *Compter les solutions* : `findall/3` + `length/2`, ou
  `aggregate_all(count, …)` sans stocker les solutions.
- *Chemins élémentaires* : `select/3` retire la case visitée de la liste
  `Open`, ce qui interdit d'y revenir et garantit la terminaison.

## Lancer

Depuis `PolyominoGenerator/` (un `dune-workspace` en fait une racine dune
indépendante du reste du dépôt) :

```sh
dune build                  # aucun warning
dune test                   # exemples OCaml de l'énoncé
./Run.sh 5 0                # génère (aire 5, graine 0) puis analyse
dune exec PolyominoGenerator 24 10      # remet le polyomino 10
swipl -q -s Prolog/Analysis.pl -s test/Requetes.pl -g run10 -g halt
dune clean                  # avant de zipper, comme l'exige l'énoncé
```

Pour une requête à la main : `swipl Prolog/Analysis.pl`, puis par exemple
`?- pattern_position([square(0, 0), square(-1, 1)], S).` et `;` pour la suite.

## Sorties réelles

`dune test` :

```
OK : tous les exemples de l'énoncé passent.
```

(Ceci inclut les trois dessins de `build_random` après `Random.init 0` et
`Random.init 1`, identiques à l'énoncé.)

`./Run.sh 5 0` (identique à l'énoncé, comme `10 1` et `12 17`) :

```
/*
Area: 5
Seed: 0
*/

/*
·O
OO
OX
*/

filled(square(-1, 0)).
filled(square(-1, 1)).
filled(square(0, 0)).
filled(square(0, 1)).
filled(square(0, 2)).
Area: 5
Domino patterns: 2
Anti-domino patterns: 3
Diagonal patterns: 2
Anti-diagonal patterns: 1
Paths from the origin: 9
```

Arguments invalides :

```
$ dune exec PolyominoGenerator
Usage : PolyominoGenerator AIRE [GRAINE]
$ dune exec PolyominoGenerator -- 0
Erreur : l'aire doit être un entier >= 1.
$ dune exec PolyominoGenerator -- 3 x
Erreur : aire (entier >= 1) puis graine (entier).
```

Requêtes de l'énoncé sur le polyomino 10 (`-g run10`, toutes les solutions
listées d'un coup ; `[]` = échec, `[ok]` = succès) :

```
?- add_squares(square(2,1),square(-4,5),_4118).
   [square(-2,6)]
?- add_squares(square(2,1),_4118,square(-4,5)).
   [square(-6,4)]
?- neighbor(_4118,square(0,0)).
   [square(0,-1),square(0,1),square(-1,0),square(1,0)]
?- neighbor(square(2,3),_4118).
   [square(2,4),square(2,2),square(3,3),square(1,3)]
?- filled_neighbor(square(0,0),_4118).
   [square(0,-1),square(1,0)]
?- filled_neighbor(square(7,-2),_4118).
   [square(7,-1),square(7,-3),square(8,-2)]
?- filled_list([]).
   [ok]
?- filled_list([square(1,0),square(5,0),square(7,1)]).
   [ok]
?- filled_list([square(1,0),square(5,0),square(-2,2),square(7,1)]).
   []
?- pattern_position([square(0,0),square(-1,1)],_4118).
   [square(1,-1),square(5,0),square(6,0),square(7,-1),square(7,0),square(8,-3),square(8,-2),square(8,-1),square(8,0),square(9,-3),square(9,-2)]
?- pattern_position([square(0,0),square(0,1),square(0,2)],_4118).
   [square(7,-3),square(7,-2),square(7,-1),square(8,-3),square(8,-2),square(8,-1)]
?- area(_6562).
   [24]
?- elementary_path(square(0,0),square(1,0),_6628).
   [[square(0,0),square(0,-1),square(1,-1),square(1,0)],[square(0,0),square(1,0)]]
?- elementary_path(square(0,-1),square(4,0),_6628).
   [[square(0,-1),square(0,0),square(1,0),square(2,0),square(3,0),square(4,0)],[square(0,-1),square(1,-1),square(1,0),square(2,0),square(3,0),square(4,0)]]
Area: 24
Domino patterns: 18
Anti-domino patterns: 14
Diagonal patterns: 11
Anti-diagonal patterns: 11
Paths from the origin: 2619
```

Polyomino 131 (`dune exec PolyominoGenerator 24 131`, puis `-g run131`) :

```
?- filled_neighbor(square(0,0),_4116).
   [square(0,1),square(0,-1),square(-1,0)]
?- pattern_position([square(0,0),square(-1,1)],_4116).
   [square(-4,2),square(-3,1),square(-3,2),square(-2,-1),square(-2,0),square(-2,1),square(-2,2),square(-1,-1),square(-1,0),square(-1,2),square(0,-1),square(0,1),square(1,1),square(1,2)]
?- pattern_position([square(0,0),square(0,1),square(0,2)],_4116).
   [square(-3,0),square(-3,1),square(-2,-1),square(-2,0),square(-2,1),square(0,-1),square(0,0),square(0,1)]
?- area(_5808).
   [24]
Area: 24
Domino patterns: 17
Anti-domino patterns: 14
Diagonal patterns: 12
Anti-diagonal patterns: 14
Paths from the origin: 1109
```

Toutes ces réponses, dans le même ordre, sont celles de l'énoncé.

## Limite connue

Le nombre de chemins élémentaires croît exponentiellement avec l'aire :
`./Run.sh 64 0` génère bien le polyomino de l'énoncé, mais `print_information`
ne termine pas en 60 s (mesuré ; l'énoncé ne donne d'ailleurs ses
statistiques que pour des aires ≤ 24).
