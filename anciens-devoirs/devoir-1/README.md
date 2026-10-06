# Devoir 1 (automne 2025) — automates cellulaires

Devoir d'entraînement non noté du cours INF6120 (énoncé :
<https://www.giraudo.uqam.ca/Teaching/INF6120/2025-09/Devoir1.pdf>).
Solution complète et testée, pour la révision.

## L'énoncé en bref

Un automate cellulaire unidimensionnel, c'est un ruban bi-infini de cases
(indexées par ℤ), une valeur vide `v` et une fonction d'évolution
`f : A × A × A → A`. À chaque étape, la case `i` devient
`f (e(i-1), e(i), e(i+1))`. Le ruban étant infini, on le représente par une
**fonction** `int -> 'a` :

```ocaml
type 'a automata = { ribbon : int -> 'a; evol : 'a * 'a * 'a -> 'a; void : 'a }
```

Le devoir demande : des outils sur les listes (partie 3), la création et la
modification d'automates (4), l'extraction de portions de ruban (5), les
transformations et l'évolution (6), deux automates célèbres — Sierpinski et
la règle 30 (7), la mémoïsation de l'évolution (8) et un exécutable qui
affiche le triangle de Sierpinski (9).

## Structure

| Fichier | Questions | Contenu |
|---|---|---|
| `lib/Tools.ml` | 3.1–3.7 | `interval`, `list_to_string`, `compose_iter`, préfixe / facteur / sous-mot, `is_duplicate_free` |
| `lib/Automata.ml` | 4.1–4.3, 6.1–6.3 | le type, `create`, `get_value`, `set_value`, `shift`, `mirror`, `map`, accesseur `evol` |
| `lib/Bunches.ml` | 5.1–5.4 | `get_bunch_values`, `to_string`, `has_factor`, `has_subword` |
| `lib/Evolutions.ml` | 6.4–6.8, 8.2 | `evolution` (mémoïsée), `evolutions`, `evolutions_bunch`, `string_representation`, `is_resurgent` |
| `lib/Examples.ml` | 7.1–7.2 | `sierpinski`, type `wb`, `chaos` |
| `lib/Memoization.ml` | 8.1–8.2 | `memo` et la réponse rédigée à la question 8.1 |
| `bin/main.ml` | 9.1 | lecture des trois arguments, affichage |
| `test/test_CellularAutomata.ml` | toutes | tous les exemples de l'énoncé (69 tests) |

Chaque fonction est précédée d'un commentaire : ce qu'elle fait, l'idée,
le cas de base, le piège typique.

## Concepts travaillés

- **Récursion sur les listes** et filtrage sur un couple `(u, v)`
  (`is_prefix_lists`, `is_subword_lists`) ; ordre des cas.
- **Réutilisation** : `is_factor_lists` = préfixe d'un suffixe ;
  `evolutions` = `compose_iter evolution` ; `is_resurgent` = « il y a un
  doublon » ; toute la partie 5 passe par `get_bunch_values`.
- **Fonctions comme données** : le ruban est une fermeture ; `set_value`,
  `shift`, `mirror`, `map`, `evolution` construisent une nouvelle fonction
  qui enveloppe l'ancienne. Rien n'est muté : l'ancien automate reste valide
  (persistance, `{ aut with ribbon = ... }`).
- **Évaluation retardée** : faire évoluer ne calcule rien ; c'est la lecture
  qui force le calcul, d'où l'explosion en 3^k de la question 8.1.
- **Mémoïsation** et fonctions d'ordre supérieur : `memo f` renvoie une
  fonction qui garde ses résultats dans sa fermeture.
- **Types somme et filtrage par motifs** regroupés (`White, Black, _`).
- **Ligne de commande** : `Sys.argv` converti en liste et filtré par
  motif, `int_of_string_opt` pour refuser proprement une entrée invalide.

Écart assumé : le sujet fournit `memo` avec une liste d'association dans
une cellule mutable (exemptée de pénalité). Ici, une table de hachage
(`Hashtbl`) joue le même rôle, avec une recherche en temps constant ;
l'idée est identique.

## Lancer

Depuis ce répertoire :

```sh
dune build                               # aucun warning attendu
dune test                                # « 69/69 tests réussis »
dune exec CellularAutomata -- -16 16 15  # triangle de Sierpinski
../../style                              # guide de style du cours
```

Pour expérimenter dans le toplevel : `dune utop lib`, puis
`open Cellular_automata;;`.
