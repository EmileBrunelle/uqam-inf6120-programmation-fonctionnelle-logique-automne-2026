# Labo 6 — Théorèmes et révisions

Énoncé : <https://inf6120.uqam.ca/labos/labo06/>. Non noté ; solution
commentée pour la révision.

- Code (toutes les fonctions, une section par exercice) : `labo6.ml`
- Tests : `test/test_labo6.ml`
- Preuves (append, filter, fold, Q12) : [`preuves.md`](preuves.md)

## Lancer
```sh
cd labos/labo06
dune build   # aucun warning
dune test    # affiche « labo6 : tous les tests passent »
```

## Où est quoi
| Énoncé | Réponse |
|---|---|
| append, rev, filter, combine, fold_left/right, sum | `labo6.ml` ; preuves T1 à T9 dans `preuves.md` |
| Shadowing | `shadowing` (vaut 3) et `shadowing_renomme` |
| RLE | `compress`, `decompress`, versions `_fold`, trace en commentaire |
| find, filter_map, dict (`lookup`, `extend`, `dict_max`, `values`, `dict_sum`) | `labo6.ml` |
| iterate | `Seq.t` paresseux |
| convert, JSON | `convert`, type `json` |
| Intra été 2024, Q2 à Q12 | `labo6.ml` (une fonction par question) |

## Réponses non codées
- **Shadowing** : à la ligne `x + 2`, `x` est le paramètre de `f`, qui
  vaut 1 (le `x` extérieur est masqué). Le résultat de `f x` est 3.
  Version renommée : `let x = 1 in let f y = let z = y + 2 in z in f x`.
- **Signatures RLE** : `compress : 'a list -> (int * 'a) list`,
  `decompress : (int * 'a) list -> 'a list`.
- **Trace de `compress [1,1,1,2]`** : avec des virgules, c'est une liste
  d'un seul quadruplet (piège). Sur `[1;1;1;2]` : voir le commentaire de
  `compress` (résultat `[(3,1);(1,2)]`).
- **Propriété RLE** : pour toute liste `l`, `decompress (compress l) = l`.
- **Q1** : vrai = « on peut passer des fonctions en argument » et
  « on peut créer des fonctions dans des fonctions pour les retourner ».
- **Q3** : `let f = function x -> function y -> x + (2 * y)`.
- **Q4** : `(3, 2)`. **Q5** : `[6; 7; 7; 7; 7]`.
- **Q6** : `1 + length t` laisse une addition en attente après l'appel
  récursif : chaque élément ajoute un cadre sur la pile (pas récursive
  terminale). Remède : accumulateur (`length_terminale`).
- **Q12** : cas = `m = 0` et `m = k + 1` ; HI = `exp x (k+n) = exp x k * exp x n` ;
  preuve dans `preuves.md`.
- **Erreur de l'énoncé** (T9) : la propriété `fold_left f init (append xs ys) =
  fold_left f init xs ++ fold_left f init ys` est fausse ; la bonne est
  `fold_left f (fold_left f init xs) ys`.
