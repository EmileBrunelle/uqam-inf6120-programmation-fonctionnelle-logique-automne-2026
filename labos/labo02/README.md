# Labo 02 : définitions de fonctions

Labo non noté, résolu pour réviser. Énoncé : <https://inf6120.uqam.ca/labos/labo02/>.

## Lancer

```
cd labos/labo02
dune build --root .
dune test --root . --force
```

Code : `labo2.ml` (commenté fonction par fonction : idée, cas de base, piège).
Tests : `test/test_labo2.ml` (les exemples de l'énoncé et plus).

## Contenu

| Section | Fonctions | Récursion terminale ? |
|---|---|---|
| 1 | `fact` | non (`n * fact (n-1)`) |
| 2 | `fib` | non (somme de deux appels) |
| 3 | `pgcd` | oui |
| 4 | `ackermann` | non (appel interne en argument) |
| 5 | `binom`, `binom_verifie` | non |
| 6 | `is_even`, `is_odd` (mutuelles) | oui |
| 7 | `fact'`, `fib'` | oui (auxiliaire à accumulateur) |
| 8 | `exp`, `exp'`, `fast_exp`, `exp_nb`, `fast_exp_nb`, `exp_mult`, `fast_exp_mult` | `exp'` oui |
| 9 | `sum1`, `sum2` | non |
| 10 | `add`, `addx`, `add3` | (application partielle) |

Le dernier exercice de la section 7 (Syracuse) est en commentaire dans le HTML de
l'énoncé : non inclus.

## Section 8 : comptes

- Appels récursifs : `exp_nb 2 10 = (1024, 10)` (n appels) ;
  `fast_exp_nb 2 10 = (1024, 4)` (floor(log2 n) + 1 appels, car n est divisé par 2).
- Bonus, multiplications : `exp` en fait `n`. `fast_exp` en fait
  (nombre de chiffres de n en base 2) + (nombre de 1 dans n en base 2) :
  un carré par chiffre, une multiplication par `x` par chiffre égal à 1.
  Exemple : 21 = 10101 donne 5 + 3 = 8. Vérifié dans les tests pour n de 0 à 29.

## Section 10 : types (vérifiés au toplevel)

| Expression | Type / résultat |
|---|---|
| `add` | `int -> int -> int` |
| `add 5` | `int -> int` |
| `addx` | `int -> int -> int` |
| `addx 5` | `int -> int` |
| `add3` | `int -> int` |
| `add3 5` | `int` (8) |
| `add 5 1` | nombre : `6` |
| `add 5` | fonction : `int -> int` |
| `(add 5) 1` | nombre : `6` (même chose que `add 5 1`) |
| `add (5 1)` | erreur : `5` n'est pas une fonction |

`add` et `addx` se comportent pareil : `let add x y = ...` est du sucre pour
`let add = fun x -> fun y -> ...`. Toute fonction OCaml prend un seul argument ; `->`
associe à droite et l'application associe à gauche.

## Concepts à retenir

`let rec` ; cas de base d'abord ; `and` pour la récursion mutuelle ; accumulateur pour la
récursion terminale (le résultat est construit en descendant, pas en remontant) ; diviser
n par 2 pour passer de linéaire à logarithmique ; `float_of_int` et `/.` pour les
divisions flottantes.
