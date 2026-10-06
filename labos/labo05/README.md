# Labo 5 — Arbres binaires

Énoncé : <https://inf6120.uqam.ca/labos/labo05/>. Non noté ; solution
commentée pour la révision. Code : `labo5.ml`, tests : `test/test_labo5.ml`.

## Résumé de l'énoncé
Type `bintree = Leaf | Node of int * bintree * bintree` et l'arbre
`example_tree` ; compter (feuilles, nœuds internes, nœuds, arêtes droites /
gauches entre nœuds internes) ; propriétés (hauteur, miroir, symétrie) ;
collectionner (valeurs, niveau, canopée) ; parcours préfixe / suffixe /
infixe ; arbre de recherche (`insert`, `search`) ; modifier (`double`,
`apply`, `mirror`, `sum_subtree`) ; ordre supérieur (`tree_map`, `fold_tree`
et deux fonctions écrites avec lui).

## Concepts à retenir
- **Récursion structurelle** : un `match` avec `Leaf` (cas de base) et
  `Node (v, g, d)` (appels récursifs sur `g` et `d`).
- **Hauteur** : `Leaf` vaut 0, `Node` vaut `1 + max`. L'exemple a une hauteur 4.
- **Parcours** : seul l'emplacement de `v` change (devant, derrière, entre).
  L'infixe d'un ABR est trié.
- **ABR** : on compare puis on descend d'un seul côté ; on reconstruit le nœud
  (immuabilité).
- **`fold_tree f x t`** : `Leaf` devient `x`, `Node (v, g, d)` devient
  `f v (fold g) (fold d)`. `tree_map`, comptes et collectes s'y expriment.
- L'arbre `example_tree` est reconstitué à partir des sorties de l'énoncé
  (l'image n'est pas dans le texte) ; les tests vérifient les 9 / 8 / 17 / 4 / 3
  et tous les parcours de l'énoncé.

## Lancer
```sh
cd labos/labo05
dune build   # aucun warning
dune test    # affiche « labo5 : tous les tests passent »
```
