# Théorie et paradigmes

> Recueil, chapitres 1 et 2, pages 1–103

Cette matière ne touche ni la syntaxe OCaml ni Prolog : c'est le socle
théorique commun aux deux — machines de Turing, calculabilité, paradigmes,
typage, portée. Environ 20 % des notes de cours et une part disproportionnée
du QCM, parce que ce sont des questions de définition, bon marché à fabriquer
et faciles à corriger.

## Ce qu'il faut savoir dire

| Notion | Formulation attendue |
|---|---|
| Paradigme de programmation | Manière de conceptualiser la représentation des objets informatiques et la formulation des algorithmes qui les manipulent. |
| Paradigme impératif | Résout un problème en décrivant étape par étape les actions à réaliser : instructions d'affectation, de branchement, de boucle, structures de données mutables. Se base sur la machine de Turing. |
| Paradigme fonctionnel | Un programme est une expression ; l'exécuter, c'est l'évaluer en utilisant les définitions de fonctions pour la simplifier. Liaison d'un nom à une valeur, récursivité, structures non mutables. Se base sur le λ-calcul. |
| Paradigme logique | Objets de base : faits, règles, requêtes. Pas de notion de fonction ni de notion de sortie aussi claire que dans les deux autres : un prédicat s'interroge dans n'importe quel sens. |
| Machine de Turing | Machine théorique servant d'abstraction de référence pour le calcul : un quadruplet (états, état initial, état terminal, programme de transitions). |
| Thèse de Church-Turing | Tout ce qui est intuitivement calculable est calculable par une machine de Turing. |
| Turing-complet | Un langage L est Turing-complet s'il permet de simuler n'importe quelle machine de Turing. |
| Problème de l'arrêt | Le problème de décision qui demande, pour un programme et une entrée donnés, si l'exécution termine. |
| Décidable / indécidable | Un problème de décision P est décidable s'il existe une machine de Turing qui le résout pour toute entrée, en un temps fini. Sinon, P est indécidable. |
| λ-calcul | Modèle de calcul où la notion première est l'expression : une variable, une application `f g`, ou une abstraction `λx. f`. |
| Vérification des types (statique / dynamique / hybride) | *Quand* l'absence d'incohérence de type est vérifiée : à la compilation, à l'exécution, ou un mélange des deux. |
| Attribution des types (explicite / implicite / hybride) | *Comment* un type est associé à une expression : annoté à la main (Church-style), déduit par inférence (Curry-style), ou un mélange. |
| Typage fort / faible | Axe orthogonal au précédent : y a-t-il des conversions implicites entre types incompatibles (faible) ou aucune (fort) ? |
| Portée statique / dynamique | La portée d'un identificateur dépend de sa *position dans le texte* du programme (statique) ou de la *façon dont il s'exécute* (dynamique). |

## Syntaxe et sémantique

### Instructions contre expressions

Le même problème — garder un élément sur deux d'une liste — illustre la
différence de fond entre les deux paradigmes.

En Python (impératif), le calcul utilise de la mémoire externe à la valeur
produite : une variable accumulatrice `res`, un compteur `i`, et un état
d'avancement (l'adresse de l'instruction courante). `res` et `i` sont lues et
modifiées dans le temps.

En OCaml (fonctionnel), le calcul se fait par réécriture de l'expression :

```
one_of_two [0; 1; 2; 3; 4]
  → 0 :: one_of_two [2; 3; 4]
  → 0 :: 2 :: one_of_two [4]
  → 0 :: 2 :: [4]
  ; [0; 2; 4]
```

Il n'y a ni mémoire externe à l'expression, ni état qui dépend du temps :
seule compte l'expression en cours de réécriture. C'est la distinction que le
QCM appelle « instructions contre expressions ».

### Chronologie à retenir

- 1920 — M. Schönfinkel introduit la logique combinatoire.
- 1936 — A. Turing invente la machine de Turing.
- 1950–1960 — premiers vrais langages : FORTRAN (1957), Lisp (1958), COBOL.
- 1960–1970 — apparition des paradigmes impératif, fonctionnel, orienté objet,
  logique. 1969, Planner (Hewitt) ; 1972, Prolog (Colmerauer, Roussel).

### Les deux axes du typage sont indépendants

Un langage se situe sur **deux** axes distincts, et les croiser donne quatre
combinaisons, toutes habitées :

| | Fortement typé | Faiblement typé |
|---|---|---|
| Statique | OCaml, Java | C (conversions implicites de pointeurs) |
| Dynamique | Python | PHP, JavaScript |

### Portée : ce qui distingue statique de dynamique

```
let x = 5
let f1 () = print_int x
let f2 () = let x = 10 in f1 ()
let () = f1 (); f2 ()
```

En OCaml (portée statique), ce programme affiche `5` puis `5` : le `x` que
`f1` lit est celui visible à l'endroit où `f1` est *définie*, jamais celui du
contexte d'où elle est *appelée*. Le programme Bash équivalent (portée
dynamique, via `local`) affiche `5` puis `10`.

## Ce qui diffère de l'impératif

| Réflexe impératif | Ce que dit la théorie |
|---|---|
| Le type est une annotation que le compilateur se contente de vérifier contre le code. | L'attribution peut être implicite : le type est *deviné* par inférence, sans qu'aucune annotation n'existe dans le texte. |
| « Non typé » et « typé dynamiquement » sont la même chose. | Un langage dynamiquement typé a quand même des types, vérifiés à l'exécution — PHP lève une erreur de type à l'exécution, il ne l'ignore pas. |
| La portée d'une variable est un détail d'implémentation, sans rapport avec la théorie des langages. | La portée statique contre dynamique est un choix de conception qui détermine ce qu'une fermeture capture ; presque tous les langages modernes ont choisi le statique. |
| Un algorithme qui boucle est juste un bug à corriger avec assez de temps de débogage. | Décider si un programme *arbitraire* termine est prouvé indécidable — aucune méthode générale, aussi ingénieuse soit-elle, n'existe. |

## Pièges de QCM

- **Distracteur : « non typé » comme synonyme de « typage dynamique ».**
  Plausible parce que dans un langage à typage dynamique aucune annotation
  n'apparaît dans le code, ce qui ressemble à l'absence de type. Faux : les
  types existent et sont vérifiés, seulement plus tard, à l'exécution — la
  preuve étant qu'une opération mal typée y lève une erreur de type.

- **Distracteur : typage fort/faible confondu avec statique/dynamique.**
  Plausible parce que les deux couples opposent une contrainte forte à une
  contrainte relâchée. Faux : ce sont deux axes orthogonaux — Python est
  fortement typé (`"1" + 1` lève une exception) et dynamique ; C est
  faiblement typé (conversions implicites de pointeurs) et statique.

- **Distracteur : « le problème de l'arrêt est indécidable » signifie qu'on ne
  peut prouver la terminaison d'*aucun* programme.**
  Plausible parce que « indécidable » sonne comme « impossible à savoir ».
  Faux : l'indécidabilité porte sur l'existence d'une méthode *générale*,
  valable pour *tout* couple programme-entrée. Prouver la terminaison d'un
  programme *particulier* (par exemple par une preuve d'induction) reste tout
  à fait possible.

- **Distracteur : Turing-complet signifie « aussi rapide qu'une machine de
  Turing ».**
  Plausible parce que « complet » évoque une notion de performance. Faux :
  Turing-complet signifie « capable de simuler n'importe quelle machine de
  Turing », une question d'expressivité, pas de vitesse. OCaml et Prolog le
  sont tous les deux, malgré des styles d'exécution très différents.

- **Distracteur : la portée dynamique n'existe dans aucun langage réel.**
  Plausible parce qu'elle est rare dans les langages modernes typés. Faux :
  Bash (portée des variables locales selon la pile d'appels) et certains
  mécanismes anciens (variables spéciales de Common Lisp) l'utilisent
  réellement — c'est un choix de conception, pas une curiosité théorique.

## À retenir par cœur

- Impératif → machine de Turing ; fonctionnel → λ-calcul.
- Statique/dynamique = *quand* on vérifie ; fort/faible = *si* on convertit
  implicitement. Deux axes indépendants.
- Attribution explicite (Church-style) contre implicite/inférée (Curry-style)
  contre hybride — OCaml est hybride.
- Portée statique = dépend de la position dans le texte ; portée dynamique =
  dépend de l'exécution. La quasi-totalité des langages modernes est statique.
- Turing-complet = peut simuler toute machine de Turing ; ce n'est pas une
  mesure de performance.
- Le problème de l'arrêt est indécidable : aucun algorithme général ne peut
  décider, pour tout programme et toute entrée, s'il termine.
- Le λ-calcul construit tout à partir de trois formes : variable, application,
  abstraction (`λx. f`).
