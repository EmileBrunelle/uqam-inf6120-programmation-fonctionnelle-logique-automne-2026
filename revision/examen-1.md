# Examen 1 — quoi étudier, quoi faire

**Mardi 6 octobre 2026, 13 h 30 – 16 h 30.** Matière : OCaml seulement
(Prolog et théorie sont pour l'examen 2).

**Format :** choix de réponse, « cochez la ou les réponses qui
s'appliquent », sans indication du nombre de bonnes (0 à 4). Chaque choix se
juge donc seul : vrai ou faux, indépendamment des autres. « Aucune » est une
réponse possible.

## Ordre de lecture

| # | Fiche | Pourquoi |
|---|-------|----------|
| 1 | `fiches/01-types-et-inference.md` | Inférer un type est la question la plus fréquente |
| 2 | `fiches/02-fonctions-et-ordre-superieur.md` | Curryfication, application partielle, `map` / `filter` / `fold` |
| 3 | `fiches/04-recursion-et-filtrage.md` | Récursion terminale, filtrage exhaustif |
| 4 | `fiches/05-listes.md` | Coût de `::` et de `@`, fonctions de `List` |
| 5 | `fiches/03-types-de-donnees.md` | Types produit et somme, enregistrements |
| 6 | `fiches/07-evaluation-et-purete.md` | Effets secondaires, évaluation paresseuse |
| 7 | `pieges.md` | Les erreurs classiques |
| 8 | `fiches/06-modules-et-projet.md` | Si le temps le permet |

Pressé : `aide-memoire.md` seul, sections *Inférence de types*, *Curryfication
et ordre supérieur*, *Filtrage de motifs*, *Récursion terminale*, *Coût des
listes*, *Pièges, un par ligne*.

## À faire

1. Lire une fiche, puis fermer les notes.
2. Générer un examen blanc, sans notes :
   `./examen 1 -n 30 -g <nombre> -s multiple -o pratique-N`
3. Corriger avec `pratique-N-corrige.md`. Pour chaque erreur : écrire une
   ligne dans `erreurs.md` (la question, ce que tu as coché, pourquoi c'était
   faux).
4. Relire la fiche du sujet manqué, puis refaire un examen avec une autre graine.
5. Faire l'examen de pratique du prof
   (`ExempleExamen.pdf`, sur la page du cours) une fois à blanc, puis le
   corriger avec `ExempleExamenSolution.pdf`.

## Réflexes pour répondre

- Vérifier **chaque choix** : un « vrai » ne rend pas les autres faux.
- Type demandé : réécrire la fonction mentalement en suivant les opérateurs
  (`+` → `int`, `+.` → `float`, `^` → `string`, `::` → liste).
- Affichage demandé : évaluer de l'intérieur vers l'extérieur ; une fonction
  appliquée à trop peu d'arguments donne une fonction, pas une erreur.
- Récursion : un appel est terminal seulement si **rien** ne reste à faire
  après lui.
- Style du cours (proscrit) : `for`, `while`, `ref`, `:=`, tableaux, `==`,
  `!=`, `List.hd` et autres fonctions partielles.
- En cas de doute entre deux choix : lequel pourrais-tu confirmer au toplevel ?

## Veille de l'examen

- Dormir. Relire `pieges.md` plutôt qu'une nouvelle fiche.
- Vérifier la salle et l'heure, et ce qui est permis (notes manuscrites ?).
