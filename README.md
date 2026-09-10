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

Un répertoire par travail, chacun avec son `dune`. Le `main` de chaque TP tient
ses propres `assert` : `dune test` est donc la vérification de tout le dépôt.

## Ressources

- [Site du cours](https://inf6120.uqam.ca/) · [Manuel OCaml](https://ocaml.org/manual/)
- [Documentation dune](https://dune.readthedocs.io/)
