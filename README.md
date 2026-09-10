# INF6120 — Programmation fonctionnelle et logique (UQAM, automne 2026)

Travaux et exercices en OCaml (le volet Prolog viendra dans son propre
répertoire).

## Mise en place

Outillage, une fois par machine :

```sh
sudo dnf install opam
opam init            # crée le switch et ajoute `eval $(opam env)` au profil
opam install dune ocaml-lsp-server ocamlformat utop
```

Dans VS Code : extension [OCaml Platform](https://marketplace.visualstudio.com/items?itemName=ocamllabs.ocaml-platform)
(déjà recommandée par `.vscode/extensions.json`). Elle prend le switch opam
courant ; si l'autocomplétion est morte, c'est presque toujours que
`ocaml-lsp-server` manque dans ce switch ou que VS Code a été lancé sans
`opam env`.

## Utilisation

| | Commande |
|---|---|
| Compiler tout | `dune build` |
| Exécuter un TP | `dune exec tp1/tp1.exe` |
| Lancer les assertions | `dune test` |
| REPL avec le code chargé | `dune utop tp1` |
| Formater | `dune fmt` |

Le bouton ▶ (Code Runner) et `Ctrl+Shift+B` lancent tous deux le fichier
ouvert. Pour déboguer : `./debug tp1` lance `ocamldebug`, le débogueur livré avec
OCaml. Points d'arrêt, `step`/`next`, `print <var>`, `backtrace`, et il sait
même reculer (`back`). Les commandes utiles sont en tête du script.

Deux pièges qui coûtent une soirée :

- Un point d'arrêt ne tient que sur un **corps de fonction**. Le code
  d'initialisation d'un module (`let () = ...`) ne produit aucun événement de
  débogage — ocamldebug répond « Can't find any event there ».
- Le module s'appelle `Tp1`, pas `Dune__exe__Tp1`, grâce à
  `(wrapped_executables false)` dans `dune-project`. Et `(map_workspace_root
  false)` empêche dune d'inscrire `/workspace_root` à la place des vrais
  chemins.

Côté VS Code, il n'y a pas de débogueur graphique utilisable : earlybird, le
seul adaptateur, force opam à **rétrograder le compilateur en 5.4** pour
s'installer. Vérifié le 2026-09-10 : à éviter, le cours exige 5.5.

Un répertoire par travail, chacun avec son `dune`. Le `main` de chaque TP tient
ses propres `assert` : `dune test` est donc la vérification de tout le dépôt.

## Ressources

- [Site du cours](https://inf6120.uqam.ca/) · [Manuel OCaml](https://ocaml.org/manual/)
- [Documentation dune](https://dune.readthedocs.io/)
