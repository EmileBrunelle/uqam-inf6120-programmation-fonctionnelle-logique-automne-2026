# Révision — INF6120

Matériel de révision pour les trois examens du cours *Programmation
fonctionnelle et logique*. Il s'adresse à des programmeurs qui arrivent d'un
langage impératif et objet, et se concentre sur ce qui **diffère** de ce qu'ils
connaissent déjà — c'est là que se trouvent les points perdus.

Toutes les sorties d'interpréteur citées dans ces fichiers ont été **exécutées**
sur OCaml 5.5.1, la version exigée par le cours, et non déduites.

## Ce qui est évalué

| Examen | Poids | Portée |
|--------|-------|--------|
| Examen 1 | 33 % | OCaml seul |
| Examen 2 | 33 % | OCaml + Prolog |
| Final | 34 % | toute la matière |

Format annoncé : **choix de réponse multiple**, avec un peu de rédaction. Les
examens comptent pour 100 % de la note ; aucun travail pratique n'entre dans le
calcul.

Le format change ce qui paye en révision. En QCM, les quatre choix se
ressemblent, et le mauvais choix est presque toujours *la réponse correcte dans
un autre langage*. L'habileté notée n'est donc pas d'écrire du code, mais de le
**lire** et de dériver assez vite pour éliminer trois choix.

## Par où commencer

1. **[`pieges.md`](pieges.md)** — le document central. Huit sections ordonnées
   par le poids réel de chaque sujet dans les examens antérieurs, chacune
   opposant le réflexe impératif à ce que fait réellement OCaml. À lire en
   premier et à relire en dernier.
2. **[`fiches/`](fiches/)** — une fiche par thème du recueil, en profondeur, avec
   la terminologie du professeur. C'est le niveau de détail à travailler pendant
   la session, à mesure que les séances avancent.
3. **[`qcm/`](qcm/)** — les banques de questions, réponses repliées. C'est
   l'entraînement au format réel de l'examen.
4. **[`erreurs.md`](erreurs.md)** — le journal des concepts ratés. La moitié la
   plus rentable de tout ce dossier.

## Les fiches

| Fiche | Thème | Recueil |
|-------|-------|---------|
| [01](fiches/01-types-et-inference.md) | Types, inférence, polymorphisme | ch. 2–3 |
| [02](fiches/02-fonctions-et-ordre-superieur.md) | Fonctions, curryfication, ordre supérieur | ch. 3 |
| [03](fiches/03-types-de-donnees.md) | Types produit, somme, paramétrés, récursifs | ch. 1, 3 |
| [04](fiches/04-recursion-et-filtrage.md) | Filtrage de motifs, récursion terminale | ch. 3 |
| [05](fiches/05-listes.md) | Listes et coût réel des opérations | ch. 3 |
| [06](fiches/06-modules-et-projet.md) | Modules, entrées-sorties, séquences, dune | ch. 3 |
| [07](fiches/07-evaluation-et-purete.md) | Stratégies d'évaluation, pureté, immuabilité | ch. 3 |
| [08](fiches/08-theorie-et-paradigmes.md) | Paradigmes, calculabilité, typage | ch. 1–2 |
| [09](fiches/09-prolog-bases.md) | Prolog : faits, règles, requêtes, termes | ch. 4 |
| [10](fiches/10-prolog-resolution-et-listes.md) | Unification, résolution, arbres, listes, CLP | ch. 4 |

## Les banques de questions

| Banque | Questions | Couverture |
|--------|-----------|------------|
| [`qcm/ocaml-types-et-fonctions.md`](qcm/ocaml-types-et-fonctions.md) | 30 | inférence, polymorphisme, curryfication, ordre supérieur |
| [`qcm/ocaml-donnees-et-recursion.md`](qcm/ocaml-donnees-et-recursion.md) | 30 | types de données, filtrage, récursion, listes, égalité |
| [`qcm/prolog.md`](qcm/prolog.md) | 25 | unification, résolution, listes, négation, coupure |
| [`qcm/theorie.md`](qcm/theorie.md) | 15 | paradigmes, calculabilité, typage |

Chaque question a quatre choix et une réponse repliée qui **nomme le concept**
avant d'expliquer pourquoi le mauvais choix était plausible. Le nom du concept
est ce qui se recopie dans le journal d'erreurs.

## Se fabriquer un examen de pratique

Le script `./examen`, à la racine du dépôt, tire un examen des banques et en
sort le sujet et le corrigé séparément.

```sh
./examen                       # 20 questions, tous les sujets
./examen 1                     # examen 1 : OCaml seulement
./examen 2                     # examen 2 : OCaml, Prolog et théorie
./examen -n 40 -s prolog       # 40 questions de Prolog
./examen -g 7                  # reproductible : même graine, même examen
./examen -o pratique-1         # écrit pratique-1.md et pratique-1-corrige.md
```

Sans `-o`, tout part sur la sortie standard, corrigé compris — pratique pour un
coup d'œil, moins pour se tester. Avec `-o`, le corrigé est dans un fichier
séparé qu'on n'ouvre qu'après.

La graine est affichée dans le titre de chaque examen : la noter permet de
refaire exactement le même à froid, une semaine plus tard, et de comparer.

**Ajouter ses propres questions est le mode d'emploi normal**, pas une
extension. Les banques sont du Markdown et le script ramasse tout fichier
`.md` du dossier `qcm/` — créer `qcm/seance-05.md` suffit, et son nom devient
un filtre : `./examen -s seance-05`. Nommer les fichiers par séance est ce qui
rend le dispositif utile en cours de session, puisque l'examen ne porte alors
que sur la matière déjà vue. Le format est décrit dans
[`qcm/_modele.md`](qcm/_modele.md) ; les fichiers commençant par `_` sont
ignorés.

Écrire ses propres questions est d'ailleurs le meilleur usage du dispositif :
fabriquer trois distracteurs plausibles à partir d'un exercice d'atelier oblige
à comprendre les erreurs voisines, ce que répondre à des questions déjà écrites
n'exige pas.

## Comment s'en servir

1. **Prédire avant de vérifier.** Pour toute question « quel type ? » ou « quel
   affichage ? », `utop` donne la réponse exacte gratuitement — mais seulement
   après avoir répondu de tête. L'inverse n'apprend rien.

   ```sh
   eval $(opam env)   # OCaml 5.5.1, celui du cours
   utop
   ```

2. **Tenir le journal.** Une ligne par concept manqué, jamais par question.
   Trois entrées sur le même concept désignent la fiche à relire.

3. **Écrire du code même si l'examen est un QCM.** Reconnaître un `fold` correct
   parmi quatre suppose de savoir en écrire un. Les ateliers du jeudi servent
   exactement à ça.

4. **Fabriquer des distracteurs.** L'exercice de révision le plus efficace qui
   existe : reprendre une question des examens antérieurs et se demander quels
   trois faux choix un correcteur y mettrait. Il faut connaître la bonne réponse
   *et* comprendre l'erreur.

5. **Refaire les banques à froid**, une semaine plus tard, sans relire. Ce qui
   est encore juste est acquis ; le reste n'était que de la mémoire à court
   terme.

## Trous connus, à combler quand le cours y arrive

Les dix ateliers du jeudi (<https://inf6120.uqam.ca/labos/laboXX/>) donnent le
séquencement réel de la matière. Confrontés aux fiches, deux manques subsistent,
tous deux sur de la matière de fin de session — les combler d'avance produirait
du matériel oublié le jour de l'examen.

| Atelier | Manque | Quoi écrire |
|---------|--------|-------------|
| 05 — arbres binaires | partiel : la fiche 03 définit le type récursif, mais rien sur les parcours préfixe / infixe / postfixe, la hauteur, les arbres binaires de recherche, ni `map_tree` / `fold_tree` | une fiche `11-arbres.md` |
| 10 — interprète minimal | absent : aucune fiche ne parle d'AST, d'environnement, de fermeture au sens `VClosure`, de `LetRec` ni de combinateur Y | une fiche `12-interprete.md` |
| 06 — preuves et révisions | trivial : le type `result` n'est mentionné nulle part | deux lignes dans la fiche 03 |

Vérifié en septembre 2026 : les contraintes `clpfd` de l'atelier 09 et les
preuves par induction de l'atelier 06 sont, elles, bien couvertes (fiches 10 et
04).

## Sources

Les notes de cours complètes du professeur (481 pages) et les deux examens
antérieurs de l'automne 2024 sont hors du dépôt, dans
`~/UQAM/2026-3/INF6120/`. Répartition de la matière dans le recueil : chapitre 3
« Programmation fonctionnelle » 263 pages (55 %), chapitre 4 « Programmation
logique » 115 pages (24 %), le reste étant de la théorie commune aux deux.

Les examens antérieurs sont à développement, pas en QCM — ils restent la
meilleure mesure du niveau de difficulté et de la matière visée, pas du format.

Le [guide de style](https://inf6120.uqam.ca/style) compte dans la note des
travaux et proscrit `for`, `while`, `ref`, `:=`, `array`, `==`, `!=` et les
fonctions partielles comme `List.hd`. Le script `./style` à la racine du dépôt
mécanise cette vérification.
