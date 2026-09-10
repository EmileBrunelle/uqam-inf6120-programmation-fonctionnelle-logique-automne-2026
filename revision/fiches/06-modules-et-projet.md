# Modules, entrées-sorties et projets

> Recueil, chapitre 3, sections 3.3 et 3.4 (pages 170–191)

Sujet à traiter brièvement : ces deux sections pèsent peu dans les examens
antérieurs dépouillés (essentiellement de l'outillage et une convention de
nommage), à l'opposé des chapitres sur la récursion, le filtrage ou les
listes. Le temps de révision est mieux investi ailleurs ; cette fiche reste
volontairement courte.

## Ce qu'il faut savoir dire

| Terme | Définition attendue |
|---|---|
| Espace de noms | Fonction, au sens mathématique, d'un ensemble d'identificateurs vers leurs définitions ; sert à restreindre la visibilité. |
| Module | À chaque fichier `.ml` d'un projet est associé un espace de noms qui lui est propre — c'est son module. |
| `unit` | Type à une seule valeur, `()` ; marque une expression exécutée pour son effet, pas pour sa valeur. |
| `;` (séquence) | Opérateur qui enchaîne `EXP1; EXP2` : `EXP1` doit être de type `unit`, la valeur du tout est celle de `EXP2`. |

## Syntaxe et sémantique

Dans un projet à plusieurs fichiers, une entité `x` définie dans `A.ml`
s'utilise depuis `B.ml` sous la forme `A.x`, ou sans préfixe après
`open A`. Deux fichiers peuvent définir des fonctions de même nom
(`A.fct` et `B.fct`) sans collision, précisément parce que chaque fichier a
son propre espace de noms.

Les fonctions d'entrée/sortie utilisent `unit` parce qu'une fonction
d'écriture n'a par convention rien de significatif à renvoyer — son intérêt
est l'effet secondaire — et une fonction de lecture n'a par convention rien de
significatif à recevoir.

```ocaml
# print_endline "bonjour";;
bonjour
- : unit = ()
# Printf.printf "J'ai %d pommes\n" 3;;
J'ai 3 pommes
- : unit = ()
```

`Printf.printf` fonctionne comme le `printf` du C ; `Scanf.scanf` comme son
`scanf`, à la différence près qu'il ne fait pas d'affectation à des variables
mais applique une fonction aux valeurs lues.

Deux expressions s'enchaînent avec `;` ; `E1; E2; ...; En` se lit
`(...(E1; E2); ...); En` — associativité à gauche — et sa valeur est celle de
`En`. Toutes les expressions avant la dernière doivent être de type `unit`,
sous peine d'avertissement du compilateur.

```ocaml
# let x = print_string "a"; print_string "b"; 3 + 4;;
ab
val x : int = 7
```

Le piège classique : la séquence est **moins prioritaire** que le
conditionnel. `if COND then print_X; SUITE` ne garde pas `SUITE` sous le
`then` — il faut un bloc `begin ... end` pour ça.

Pour un projet, la commande `dune init project NAME` crée l'arborescence ;
`dune build` compile, `dune exec NAME` exécute, `dune utop` lance un
interpréteur où les définitions du projet sont accessibles via le préfixe
`PROJECT.MODULE.`.

## Ce qui diffère de l'impératif

| Réflexe impératif | Ce que fait OCaml |
|---|---|
| Une fonction qui « ne renvoie rien » a un type de retour `void`, absent du système de types courant. | `unit` est un type à part entière, avec une seule valeur `()` ; il apparaît dans la signature et se manipule comme n'importe quel autre type. |
| Les instructions s'enchaînent simplement par des points-virgules ou des retours à la ligne, sans contrainte de type. | `E1; E2` exige `E1 : unit` ; enchaîner une expression dont la valeur est ignorée sans qu'elle soit `unit` déclenche un avertissement. |
| Un module ou un namespace se déclare explicitement (`namespace`, `package`, `module` en tête de fichier). | Chaque fichier `.ml` **est** un module, implicitement nommé d'après le nom du fichier — rien à déclarer. |

## Pièges de QCM

**« Une fonction d'entrée/sortie sans effet visible a le type `void`, absent
d'OCaml, donc le code ne type-check pas. »** Plausible pour qui vient d'un
langage où l'absence de valeur de retour est un cas spécial du système de
types. Faux : OCaml n'a pas de cas spécial, `unit` est un type ordinaire à une
seule valeur, et toute fonction en renvoie une, y compris `print_endline`.

**« `if COND then print_string "pair"; x / 2` calcule `x / 2` uniquement si
`COND` est vrai. »** Plausible en lisant l'indentation comme le ferait un bloc
`if` en Java ou en C. Faux : la séquence est moins prioritaire que le
conditionnel, donc ceci se lit `(if COND then print_string "pair"); (x / 2)` —
`x / 2` s'exécute dans tous les cas. Il faut `begin ... end` pour lier les
deux au `then`.

**« Chaque fichier `.ml` doit déclarer explicitement son module avec un
mot-clé, comme un `namespace` C# ou un `package` Java. »** Plausible par
analogie avec ces langages où l'espace de noms se déclare en tête de fichier.
Faux : en OCaml, le nom du fichier détermine à lui seul le module (`A.ml`
donne le module `A`), sans aucune syntaxe supplémentaire à écrire.

## À retenir par cœur

- `unit` a exactement une valeur, `()`, et sert de marqueur pour « effet
  secondaire, pas de résultat utile ».
- `E1; E2` exige `E1 : unit` ; la valeur du tout est celle de `E2`.
- La séquence est moins prioritaire que `if ... then ... else` : utiliser
  `begin ... end` pour grouper plusieurs expressions sous une branche.
- Un fichier `.ml` est automatiquement un module ; `A.x` ou `open A` donnent
  accès à ce qu'il définit.
- `dune build` compile, `dune exec NAME` exécute, `dune utop` ouvre un
  interpréteur avec les modules du projet accessibles en `PROJECT.MODULE.`.
