# Modèle — comment ajouter ses propres questions

Ce fichier n'est pas une banque : le générateur `./examen` ignore tout fichier
dont le nom commence par `_`. Il sert de gabarit.

Pour ajouter des questions, deux façons :

- les mettre à la fin d'une banque existante (`prolog.md`, `theorie.md`…) ;
- créer un nouveau fichier dans ce dossier, par exemple `seance-07.md`. Le
  générateur le ramasse automatiquement, et son nom devient un filtre utilisable
  avec `./examen -s seance-07`.

Nommer les fichiers par séance ou par thème est ce qui rend le dispositif utile
en cours de session : `./examen -s seance-03,seance-04` fabrique un examen sur
la seule matière déjà vue.

## Format attendu

Trois contraintes seulement, le reste est libre : la question numérotée en
**gras**, exactement quatre choix `A)` à `D)`, et une réponse dépliable dont la
première ligne commence par la lettre de la bonne réponse. Les questions sont
séparées par une ligne `---`.

Le générateur renumérote et mélange, donc les numéros d'origine n'ont pas
d'importance et les questions peuvent être ajoutées dans n'importe quel ordre.

---

**1.** Que répond le toplevel à `List.length [1; 2; 3]` ?

- **A)** `- : int = 3`
- **B)** `- : int = 2`
- **C)** `- : int list = [3]`
- **D)** `Error: This expression has type int list`

<details>
<summary>Réponse</summary>

**A.** *Concept : nommer ici le concept en jeu, pas la question.*

Expliquer d'abord pourquoi la bonne réponse est bonne, puis — c'est la partie
qui fait apprendre — pourquoi chaque mauvais choix était plausible. Un bon
distracteur est la réponse correcte dans un autre contexte : celle d'un autre
langage, celle qu'on obtiendrait sans une règle précise, ou le type d'une
fonction voisine. Un choix manifestement absurde ne fait rien apprendre.

</details>

---

## Deux conseils de fabrication

**Vérifier avant d'écrire.** Toute question du genre « quel type ? » ou « quel
affichage ? » se vérifie gratuitement au toplevel — et l'intuition se trompe
plus souvent qu'on croit. `List.map (fun x -> x) []` est `'a list` et non une
variable faible ; `7 / (-2)` vaut `-3` et non `-4`. Une banque qui contient une
fausseté vérifiable est pire qu'une banque vide.

```sh
eval $(opam env)
printf 'List.length [1; 2; 3];;\n' | ocaml
```

**Fabriquer les distracteurs est l'exercice.** Écrire les trois faux choix
demande de connaître la bonne réponse *et* de comprendre les erreurs voisines.
C'est pour ça que se fabriquer ses propres questions à partir des exercices
d'atelier vaut plus que répondre à celles des autres.
