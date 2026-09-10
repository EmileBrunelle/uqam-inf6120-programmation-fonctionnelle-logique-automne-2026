# Banque de QCM — Théorie et paradigmes

15 questions. Répondre de tête, sans machine, puis déplier la réponse. Matière
couverte : instructions contre expressions, paradigmes, chronologie, machines
de Turing, décidabilité, λ-calcul, typage, portée (recueil, chapitres 1 et 2,
pages 1–103).

---

**1.** Quel est l'élément constitutif du paradigme *fonctionnel*, absent du
paradigme impératif ?

- **A)** les instructions de branchement
- **B)** la liaison d'un nom à une valeur
- **C)** les structures de données mutables
- **D)** les instructions d'affectation

<details>
<summary>Réponse</summary>

**B.** *Concept : constitutifs du paradigme fonctionnel contre impératif.*

Les instructions de branchement (A) sont communes aux deux paradigmes,
d'après le recueil. C et D sont au contraire des éléments *constitutifs de
l'impératif* : l'affectation modifie l'état de la machine, ce que le
fonctionnel exclut. La liaison d'un nom à une valeur est la manière
fonctionnelle de nommer sans jamais permettre de réaffecter ce nom.

</details>

---

**2.** Sur quel modèle de calcul le paradigme impératif se base-t-il, selon le
recueil ?

- **A)** le λ-calcul
- **B)** la logique des prédicats
- **C)** la machine de Turing
- **D)** les clauses de Horn

<details>
<summary>Réponse</summary>

**C.** *Concept : fondations théoriques des paradigmes.*

Le λ-calcul (A) est la base du paradigme *fonctionnel*, pas impératif — piège
classique d'inversion. La logique des prédicats (B) et les clauses de Horn
(D) relèvent du paradigme *logique*. Le recueil associe explicitement
impératif → machine de Turing, fonctionnel → λ-calcul.

</details>

---

**3.** En 1936, quel résultat A. Turing introduit-il ?

- **A)** le λ-calcul
- **B)** la machine de Turing
- **C)** le langage Prolog
- **D)** la logique combinatoire

<details>
<summary>Réponse</summary>

**B.** *Concept : chronologie des langages et modèles de calcul.*

Le λ-calcul (A) est dû à Church, contemporain mais distinct. La logique
combinatoire (D) est antérieure, introduite par Schönfinkel en 1920. Prolog
(C) est bien plus tardif, 1972, par Colmerauer et Roussel. 1936 est
précisément l'année de la machine de Turing.

</details>

---

**4.** Un langage L est dit Turing-complet si :

- **A)** il s'exécute au moins aussi vite qu'une machine de Turing universelle
- **B)** il permet de simuler n'importe quelle machine de Turing
- **C)** il ne peut résoudre que des problèmes décidables
- **D)** il dispose d'un ruban de mémoire de taille infinie à l'exécution

<details>
<summary>Réponse</summary>

**B.** *Concept : Turing-complétude.*

A confond expressivité et performance : Turing-complet ne dit rien sur la
vitesse d'exécution. C est faux dans l'autre sens : la Turing-complétude
n'empêche pas d'exprimer des problèmes indécidables — au contraire, elle
permet d'encoder le problème de l'arrêt lui-même. D décrit une machine de
Turing idéalisée, pas une propriété du langage ; en pratique le ruban
implanté est fini mais considéré comme suffisamment grand.

</details>

---

**5.** Le problème de l'arrêt est :

- **A)** décidable, mais dans un temps exponentiel
- **B)** indécidable seulement pour les langages non Turing-complets
- **C)** indécidable : aucune machine de Turing ne le résout pour tout couple programme-entrée
- **D)** décidable pour tout programme qui ne contient pas de boucle explicite

<details>
<summary>Réponse</summary>

**C.** *Concept : indécidabilité du problème de l'arrêt.*

A propose une fausse nuance : l'indécidabilité n'est pas une question de
complexité temporelle, c'est l'absence de *toute* méthode, même
arbitrairement lente. B inverse le rôle de la Turing-complétude : le problème
ne se pose que pour des langages assez expressifs pour l'encoder, donc
Turing-complets. D confond « pas de boucle syntaxique » et « termine » — la
récursion, absente de boucle `for`/`while`, peut tout autant boucler
indéfiniment.

</details>

---

**6.** D'après le recueil, un problème de décision P est *décidable* si :

- **A)** il existe une machine de Turing qui répond correctement pour toute entrée, en un temps fini
- **B)** il existe un algorithme qui répond correctement pour la plupart des entrées
- **C)** P est Turing-complet
- **D)** P peut s'exprimer comme une expression du λ-calcul

<details>
<summary>Réponse</summary>

**A.** *Concept : définition de la décidabilité.*

B affaiblit la définition en « la plupart » — la décidabilité exige une
réponse correcte pour *toute* entrée, sans exception. C confond un problème
de décision avec la propriété d'un *langage* : Turing-complet qualifie un
langage de programmation, pas un problème. D est une reformulation sans
rapport : le λ-calcul est un modèle de calcul, pas un critère de
décidabilité.

</details>

---

**7.** En λ-calcul, laquelle des affirmations suivantes est correcte ?

- **A)** un λ-terme est soit une variable, soit une application, soit une abstraction
- **B)** un λ-terme doit toujours être clos pour être valide
- **C)** l'application `f g` note l'abstraction de `g` par `f`
- **D)** toute expression du λ-calcul s'évalue en une valeur

<details>
<summary>Réponse</summary>

**A.** *Concept : définition récursive d'un λ-terme.*

B impose une contrainte qui n'existe pas : une variable libre est parfaitement
légale, elle rend seulement le terme non clos. C inverse les rôles :
`f g` est l'*application* de `f` à `g`, l'abstraction se note `λx. f`. D est
faux et c'est un point noté explicitement au recueil : `(λx. (x x)) (λx. (x x))`
ne termine jamais, aucune β-substitution ne le réduit à une valeur.

</details>

---

**8.** Que compare l'axe « typage statique contre dynamique » ?

- **A)** si des conversions implicites entre types existent
- **B)** si les types sont annotés explicitement dans le code
- **C)** à quel moment les types sont vérifiés — compilation ou exécution
- **D)** si le langage autorise le polymorphisme

<details>
<summary>Réponse</summary>

**C.** *Concept : vérification statique contre dynamique des types.*

A décrit l'axe fort/faible, orthogonal à celui-ci — c'est le piège le plus
fréquent de cette section. B décrit l'attribution explicite contre implicite,
un troisième axe distinct (Church-style contre Curry-style). D est sans
rapport : le polymorphisme est indépendant du moment de vérification, OCaml
(statique) et Python (dynamique) l'ont tous les deux.

</details>

---

**9.** Un langage « fortement typé » se caractérise par :

- **A)** la vérification des types a lieu à la compilation
- **D)** le langage interdit tout polymorphisme
- **C)** tous les types doivent être annotés explicitement
- **B)** aucune conversion implicite n'est effectuée entre types incompatibles

<details>
<summary>Réponse</summary>

**D.** *Concept : typage fort contre faible.*

A décrit le typage *statique*, un axe différent — un langage peut être
fortement typé et vérifié dynamiquement, comme Python. C décrit l'attribution
*explicite*, encore un autre axe : OCaml est fortement typé sans exiger
d'annotations, grâce à l'inférence. B est une généralisation abusive : le
polymorphisme (comme celui d'OCaml) coexiste très bien avec un typage fort.

</details>

---

**10.** L'attribution *implicite* des types (Curry-style) signifie que :

- **A)** les types ne sont vérifiés qu'à l'exécution
- **B)** les types des variables et fonctions ne sont pas mentionnés dans le programme ; ils sont devinés par inférence
- **C)** le langage n'a pas de système de types
- **D)** seules les expressions atomiques doivent être annotées

<details>
<summary>Réponse</summary>

**B.** *Concept : attribution explicite contre implicite des types.*

A confond attribution et vérification : l'inférence peut tout à fait se faire
à la compilation (statique), c'est le cas d'OCaml. C est faux : les types
existent et sont vérifiés, seulement non écrits par le programmeur. D décrit
l'attribution *hybride*, pas la purement implicite.

</details>

---

**11.** Que désigne la « portée » d'un identificateur ?

- **A)** le temps d'exécution nécessaire pour le résoudre
- **B)** l'étendue du programme dans laquelle cet identificateur existe
- **C)** l'ensemble des types que l'identificateur peut prendre
- **D)** le nombre de fois où l'identificateur est réaffecté

<details>
<summary>Réponse</summary>

**B.** *Concept : définition de la portée d'un identificateur.*

A introduit une notion de coût sans rapport avec la définition. C évoque le
polymorphisme, un tout autre sujet. D présuppose la réaffectation, qui
n'existe même pas dans un cadre fonctionnel pur — la portée concerne où un
nom *existe*, pas combien de fois il change de valeur.

</details>

---

**12.** Soit le programme OCaml suivant :

```ocaml
let x = 2 in
let f y = x * y in
let x = 10 in
f 3
```

Quelle est sa valeur ?

- **A)** 30
- **D)** cela dépend de l'ordre d'évaluation choisi par le compilateur
- **C)** une erreur de compilation (x redéfini)
- **B)** 6

<details>
<summary>Réponse</summary>

**D.** *Concept : portée statique et capture par fermeture.*

A, 30, est la réponse qu'on obtiendrait en portée *dynamique* — c'est
exactement le distracteur que la matière prévoit : `f` lirait le `x` en
vigueur *au moment de l'appel*. C est faux : réutiliser un nom avec un nouveau
`let` est autorisé, cela crée de l'ombrage, pas une erreur. B invente une
ambiguïté qui n'existe pas : la portée statique est entièrement déterminée
par la position textuelle des `let`, aucune place pour un choix du
compilateur.

</details>

---

**13.** Quelle affirmation décrit correctement la portée *dynamique* ?

- **A)** elle dépend de la position de l'identificateur dans le texte du programme
- **B)** elle dépend de la façon dont le programme s'exécute, et peut varier d'une exécution à l'autre
- **C)** c'est un synonyme de la portée statique dans les langages modernes
- **D)** elle n'existe dans aucun langage réellement utilisé

<details>
<summary>Réponse</summary>

**B.** *Concept : portée dynamique.*

A décrit au contraire la portée *statique*. C est une confusion pure et
simple des deux notions. D est réfuté par le recueil lui-même, qui donne un
exemple Bash fonctionnel avec `local` : la portée dynamique est rare mais pas
inexistante dans les langages modernes.

</details>

---

**14.** Dans le paradigme *logique*, qu'est-ce qui remplace la notion de
fonction du paradigme fonctionnel ?

- **A)** l'instruction de branchement
- **D)** la machine de Turing universelle
- **C)** la boucle récursive terminale
- **B)** le prédicat, interrogé par des requêtes sur des faits et des règles

<details>
<summary>Réponse</summary>

**D.** *Concept : objet central du paradigme logique.*

A n'est même pas un élément spécifique à un paradigme donné. C décrit un
mécanisme du paradigme fonctionnel (l'optimisation d'appel terminal), sans
équivalent direct en logique, qui n'a pas de notion d'appel de fonction. B est
un objet théorique du chapitre sur la calculabilité, sans rapport avec la
structure d'un programme logique.

</details>

---

**15.** Quelle formulation correspond au principe de *transparence
référentielle* ?

- **A)** toute expression peut être remplacée par sa valeur sans changer le sens du programme
- **B)** toute variable peut être réaffectée sans changer le sens du programme
- **C)** toute fonction peut être appelée dans n'importe quel ordre sans changer le résultat
- **D)** tout type peut être inféré sans annotation explicite

<details>
<summary>Réponse</summary>

**A.** *Concept : transparence référentielle.*

B introduit la réaffectation, exactement ce que la transparence référentielle
exclut — un effet secondaire comme une affectation la brise. C généralise à tort
à l'ordre d'évaluation, une question distincte (stratégies d'évaluation). D
décrit l'inférence de types, un sujet sans rapport : le recueil illustre la
transparence référentielle avec l'exemple C `g(f(1))` contre `g(1)`, où l'effet
de bord de `printf` dans `f` brise la propriété, indépendamment de tout typage.

</details>

---
