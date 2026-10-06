# Labo 04 : fonctions d'ordre supérieur

Labo non noté, résolu pour réviser. Énoncé : <https://inf6120.uqam.ca/labos/labo04/>.

## Lancer

```
cd labos/labo04
dune build --root .     # aucun warning attendu
dune test --root . --force
```

Code : `labo4.ml`. Tests : `test/test_labo4.ml`.

## Contenu

- Curryfication : `f_sum` (et version `function`), `f1` à `f5` (types imposés), `make_list`, `List.map` avec `square` et la multiplication partiellement appliquée.
- « Sur une ligne » : expressions avec `List.map/filter/exists/for_all`, sans nouvelle fonction nommée.
- Replis avec `List.fold_left` : `sum`, `size`, `last`, `nb_occ`, `max_list`, `average`.
- Prédicats : `my_for_all` (récursion), `my_for_all2` (`fold_left`), `my_for_all3` (`fold_right`), `my_exists`, `none`, `not_all`, `ordered`, `filter2`.
- `perm` : toutes les permutations (insérer la tête partout dans chaque permutation de la queue).

## Note

L'exemple de l'énoncé pour « chaînes en minuscules » omet `"quokka"`, qui est pourtant en minuscules : notre résultat l'inclut.
