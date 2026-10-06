# Labo 03 : filtrage par motif, types algébriques et listes

Labo non noté, résolu pour réviser. Énoncé : <https://inf6120.uqam.ca/labos/labo03/>.

## Lancer

```
cd labos/labo03
dune build --root .     # aucun warning attendu
dune test --root . --force
```

Code : `labo3.ml` (commentaires de révision au-dessus de chaque fonction). Tests : `test/test_labo3.ml`.

## Contenu

- 1.1 `card` (enregistrement rang + couleur), `card_compare` : compare par valeur seulement.
- 1.2 `shape`, `surface`.
- 2.1 `integers_1` (décroissante), `integers_2` (`@`, O(n^2)), `integers_3` (`List.rev`), `integers_1_terminal` (accumulateur, un parcours).
- 2.2 `three_or_more` ... `find_pattern` (exception `EmptyList` quand la liste est vide).
- 2.3 `list_copy` ... `look_and_say`.
- 2.4 `f_split`/`f_merge`/`fusion_sort` et `q_split`/`q_merge`/`quick_sort`.

## Concepts

Types sommes et enregistrements, `match` sur `[]` / `x :: t`, motifs imbriqués, récursion terminale avec accumulateur, coût de `@` et de `List.length`, exceptions, tris diviser pour régner.
