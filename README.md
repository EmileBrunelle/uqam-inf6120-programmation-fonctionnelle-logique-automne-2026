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
ouvert. **Pas de débogueur pas-à-pas**, et ce n'est pas un trou dans cette
installation : earlybird est le seul adaptateur pour VS Code, et sous OCaml 5.5
il lance le programme sans jamais poser les points d'arrêt. Vérifié le
2026-09-10 : bytecode avec section `DBUG` complète, chemins non réécrits
(`map_workspace_root false` dans `dune-project`, sinon dune inscrit
`/workspace_root`), type `ocaml.earlybird` d'OCaml Platform — le programme
roule jusqu'au bout quand même. Ne pas installer `hackwaly.ocamlearlybird` :
gelée depuis 2021, elle refuse même le bytecode d'OCaml 5. Seule piste
restante si ça devient vital : un switch `opam switch create 4.14.2`, la
version sous laquelle earlybird a été développé.

Cela dit, en OCaml on débogue surtout à `utop`, aux types et au `printf`.

Un répertoire par travail, chacun avec son `dune`. Le `main` de chaque TP tient
ses propres `assert` : `dune test` est donc la vérification de tout le dépôt.

## Ressources

- [Site du cours](https://inf6120.uqam.ca/) · [Manuel OCaml](https://ocaml.org/manual/)
- [Documentation dune](https://dune.readthedocs.io/)
