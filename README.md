# INF6120 — Programmation fonctionnelle et logique (UQAM, automne 2026)

Travaux et exercices en OCaml (le volet Prolog viendra dans son propre
répertoire).

## Mise en place

Reproduction complète de l'environnement, débogueur inclus. Testé sur une seule
machine — les versions exactes sont plus bas, à vous de juger si ça
s'applique chez vous.

```sh
sudo dnf install opam                    # opam 2.5.2 dans Fedora 44
opam init                                # répondre « y » : ajoute `eval $(opam env)` au shell
opam switch create 5.5.1                 # la version exigée par le cours
eval $(opam env)
opam install dune ocaml-lsp-server ocamlformat utop
```

`ocamldebug` n'est pas dans cette liste : il est livré avec le compilateur,
donc déjà là.

Extensions VS Code (`.vscode/extensions.json` les propose à l'ouverture) :

```sh
code --install-extension ocamllabs.ocaml-platform   # LSP : types, complétion, erreurs, format
code --install-extension formulahendry.code-runner  # le bouton ▶
```

Le dépôt apporte le reste : `dune-project` contient les deux réglages sans
lesquels le débogueur ne fonctionne pas (voir Utilisation), `.vscode/tasks.json`
les tâches, `.ocamlformat` le style.

### À ne pas faire

- **`opam install earlybird`** (l'adaptateur de débogage pour VS Code) :
  opam rétrograde le compilateur en 5.4.1 pour satisfaire ses dépendances, sans
  le dire clairement. Le cours exige 5.5. Vérifié le 2026-09-10.
- **`hackwaly.ocamlearlybird`** : extension gelée depuis mars 2021, elle refuse
  le bytecode d'OCaml 5 (sa liste blanche s'arrête à la magie `Caml1999X029`,
  OCaml 5.5 produit `Caml1999X036`).
- **Installer OCaml depuis les dépôts Fedora** (`dnf install ocaml`) : 5.4.0,
  plus vieux que ce que demande le cours, et deux compilateurs qui se disputent
  le `PATH`.

Si l'autocomplétion est morte dans VS Code, c'est presque toujours que
`ocaml-lsp-server` manque dans le switch courant, ou que VS Code a été lancé
sans `opam env`.

### Environnement de référence

| | Version |
|---|---|
| Fedora | 44 (noyau 7.1.13) |
| opam | 2.5.2 (paquet Fedora) |
| OCaml | 5.5.1 (`ocaml-base-compiler`, switch `default`) |
| dune | 3.24.2 |
| ocaml-lsp-server | 1.27.0 |
| ocamlformat | 0.29.0 |
| utop | 2.17.0 |
| ocamldebug | 5.5.1 (livré avec le compilateur) |
| VS Code | 1.136.2 |
| OCaml Platform | 2.3.0 |
| Code Runner | 0.12.2 |

## Utilisation

| | Commande |
|---|---|
| Compiler tout | `dune build` |
| Exécuter un TP | `dune exec tp1/tp1.exe` |
| Lancer les assertions | `dune test` |
| REPL avec le code chargé | `dune utop tp1` |
| Formater | `dune fmt` |

Le bouton ▶ (Code Runner), `Ctrl+Shift+B` et **F5** lancent tous le fichier
ouvert ; **F6** ouvre `ocamldebug` dessus. F5 et F6 viennent de raccourcis
personnels, hors dépôt — VS Code ne fournit aucun adaptateur de débogage pour
OCaml, donc F5 demanderait sinon « quel débogueur ? » à chaque fois, sans
jamais retenir la réponse. À remettre dans
`~/.config/Code/User/keybindings.json` sur une autre machine :

```json
{ "key": "f5", "command": "workbench.action.tasks.runTask",
  "args": "exécuter le fichier courant", "when": "editorLangId == ocaml" },
{ "key": "f6", "command": "workbench.action.tasks.runTask",
  "args": "déboguer le TP courant (ocamldebug)", "when": "editorLangId == ocaml" }
```
 Pour déboguer : `./debug tp1` lance `ocamldebug`, le débogueur livré avec
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
