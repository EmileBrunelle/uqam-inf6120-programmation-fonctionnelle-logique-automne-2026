# Banque de QCM — Prolog (unification, résolution, listes)

25 questions. Répondre de tête, sans machine, puis déplier la réponse.
Question par question, la bonne réponse est celle **attendue à l'examen** —
celle du recueil du cours (chapitre 4, pages 400–481). Chaque trace citée a
été vérifiée à l'exécution sur SWI-Prolog 10.0.2 ; quand ce dernier s'écarte
de ce qu'enseigne le recueil (occur check, `is` contre les contraintes
`clpfd`), l'écart est signalé explicitement dans la réponse dépliée.

---

**1.** Quel est le résultat de l'unification de `b(X, c)` et `b(c, X)` ?

- **A)** Échec, car `X` apparaît des deux côtés.
- **B)** `{X ↦ c}`
- **C)** `{X ↦ c, X ↦ b}`
- **D)** `{X ↦ b}`

<details>
<summary>Réponse</summary>

**B.** *Concept : unification par superposition des positions.*

A serait vrai si `X` apparaissait deux fois **dans un même terme mis en
correspondance avec deux atomes différents** (l'occur check porte sur ce
cas-là, pas sur une variable réutilisée dans deux termes distincts). C et D
confondent la position : le premier argument de `b(X,c)` s'unifie avec le
premier de `b(c,X)`, donc `X` avec `c` — pas avec `b`, qui est le foncteur,
jamais une valeur à unifier.

</details>

---

**2.** Les termes `t1 := b(X1, X2)` et `t2 := b(b(X3, X1), X4)` sont-ils
unifiables ?

- **A)** Oui, avec `X1 ↦ b(X3, X1)`.
- **B)** Oui, avec `X1 ↦ X3`.
- **C)** Non.
- **D)** Oui, car toute paire de termes composés de même arité s'unifie.

<details>
<summary>Réponse</summary>

**C.** *Concept : occur check.*

A énonce littéralement la substitution qu'il faudrait produire — mais elle
est invalide dans l'algorithme enseigné, puisque `X1` se retrouverait à
désigner un terme qui la contient elle-même : ce n'est pas une substitution
finie. B serait le résultat si le second argument de `t2` avait été `X1` seul,
non `b(X3, X1)`. D est faux : l'arité et le foncteur communs sont
nécessaires, non suffisants — chaque paire d'arguments doit encore s'unifier.

**Écart vérifié à l'exécution** : par défaut, SWI-Prolog 10.0.2 **n'applique
pas** l'occur check — `?- X1 = b(_, X1).` y réussit réellement, en
construisant un terme cyclique (`X1 = b(_A, X1)`), au lieu d'échouer. La
réponse C reste celle attendue à l'examen, qui enseigne l'algorithme
d'unification *avec* occur check ; pour retrouver ce comportement en
pratique, il faut appeler explicitement `unify_with_occurs_check/2`, qui
échoue bien sur cet exemple.

</details>

---

**3.** Quel est le résultat de `?- a(X, Y) = a(Y, t).` ?

- **A)** `false.`
- **B)** `X = t, Y = t.`
- **C)** `X = Y, Y = t.`
- **D)** `X = Y.`

<details>
<summary>Réponse</summary>

**C.** *Concept : propagation de la substitution entre arguments successifs.*

A serait le résultat si les foncteurs ou les arités différaient, ce qui n'est
pas le cas ici. B est plausible si on résout chaque position indépendamment
sans propager `X ↦ Y` à la position suivante — mais l'algorithme unifie le
second argument `Y` avec `t` en tenant compte de la liaison déjà établie, ce
qui donne bien `Y = t` et, par transitivité, `X = t` — reporté comme
`X = Y, Y = t`. D est incomplet : la variable `Y` reste sans valeur concrète
alors que la requête la contraint.

</details>

---

**4.** Quel est le résultat de `?- a(X, Y) = b(X, Y).` ?

- **A)** `X = a, Y = b.`
- **B)** `false.`
- **C)** `X = Y.`
- **D)** Une erreur de type.

<details>
<summary>Réponse</summary>

**B.** *Concept : les foncteurs différents échouent d'emblée.*

A confond foncteur et argument : `a` et `b` sont les noms des prédicats, pas
des valeurs à unifier avec `X` et `Y`. C ignorerait que l'unification échoue
avant même d'atteindre les arguments. D transpose un réflexe de langage
typé statiquement : Prolog n'a pas de système de types qui rejetterait ceci à
la compilation — l'unification échoue simplement, sans erreur.

</details>

---

**5.** Une substitution `σ1` est dite « plus générale » qu'une substitution
`σ2` (qui unifie les deux mêmes termes) lorsque :

- **A)** `σ1` a moins de variables liées que `σ2`.
- **B)** Il existe `σ3` telle que `σ2 = σ3 ◦ σ1`.
- **C)** `σ1` est trouvée en premier par l'algorithme d'unification.
- **D)** `σ1` lie chaque variable à un atome plutôt qu'à un terme composé.

<details>
<summary>Réponse</summary>

**B.** *Concept : substitution la plus générale (mgu).*

A décrit une intuition proche mais incorrecte formellement : ce n'est pas le
nombre de liaisons qui compte, mais la possibilité de **dériver** `σ2` en
composant `σ1` avec une substitution supplémentaire. C confond l'ordre de
calcul avec la relation de généralité — l'algorithme du recueil calcule
justement toujours la plus générale, mais ce n'est pas ce qui la définit. D
est un cas particulier qui peut être vrai ou faux selon l'exemple : rien
n'exige que la substitution la plus générale évite les termes composés.

</details>

---

**6.** Dans une clause de Horn `(H1 ∧ H2 ∧ ... ∧ Hn) → C`, que représente le
cas `n = 0` ?

- **A)** Une clause toujours fausse.
- **B)** Une règle sans corps, syntaxiquement invalide.
- **C)** Un fait : `C` est vraie inconditionnellement.
- **D)** Une requête.

<details>
<summary>Réponse</châteausummary>
<summary>Réponse</summary>

**C.** *Concept : un fait est une clause de Horn sans hypothèse.*

A inverse le sens de l'implication : avec zéro hypothèse, l'implication n'est
pas vide de sens, elle affirme directement `C`. B applique un réflexe de
langage où une déclaration sans corps serait une erreur de syntaxe — en
Prolog, `couleur(vert).` est une clause parfaitement valide. D confond
clause (ce qui compose le programme) et but (ce qu'on soumet au système par
une requête).

</details>

---

**7.** Un programme contient, dans cet ordre, `parent(marvin, randy).`,
`parent(marvin, jimbo).`, puis `grand_parent(X,Y) :- parent(X,Z), parent(Z,Y).`.
La requête `?- grand_parent(marvin, W).` échoue immédiatement (aucune
solution). Que peut-on en conclure sur `parent(randy, _)` et
`parent(jimbo, _)` ?

- **A)** Rien : l'échec pourrait venir de l'ordre des clauses, indépendamment
  du contenu du programme.
- **B)** Aucun fait `parent(randy, _)` ni `parent(jimbo, _)` n'est démontrable
  à partir du programme.
- **C)** `randy` et `jimbo` ne sont pas des atomes valides.
- **D)** La clause `grand_parent/2` est mal formée.

<details>
<summary>Réponse</summary>

**B.** *Concept : l'échec de résolution reflète l'absence de démonstration, pas un défaut de syntaxe.*

A est un réflexe de méfiance excessive : l'ordre des clauses change l'ordre et
parfois la terminaison des solutions, mais pas le fait qu'une solution
existe ou non — si `grand_parent(marvin, W)` a une preuve logique, la
résolution SLD la trouvera dans un ordre ou un autre, sauf boucle infinie
avant de l'atteindre. C et D imaginent une erreur de forme là où il n'y en a
aucune : le programme est syntaxiquement correct, il manque simplement les
faits qui rendraient le but démontrable — exactement l'hypothèse du monde
clos en action.

</details>

---

**8.** Dans l'arbre de résolution de `?- grand_parent(marvin, X).` (avec les
quatre faits `parent/2` et la règle `grand_parent/2` du recueil), les deux
solutions `X = shelly` puis `X = stan` apparaissent dans cet ordre. Pourquoi ?

- **A)** Parce que `shelly` précède `stan` dans l'ordre alphabétique.
- **B)** Parce que la clause `parent(randy, shelly).` précède
  `parent(randy, stan).` dans le programme, et que l'arbre est parcouru en
  profondeur d'abord, de gauche à droite.
- **C)** Parce que Prolog trie les solutions par ordre de première
  apparition dans la requête.
- **D)** L'ordre est indéterminé et dépend de l'implémentation.

<details>
<summary>Réponse</summary>

**B.** *Concept : l'ordre des solutions suit l'ordre des clauses dans un parcours en profondeur d'abord.*

A est un piège fréquent : Prolog ne trie jamais les résultats, l'ordre
alphabétique ici coïncide par hasard avec l'ordre d'écriture des clauses. C
invente un mécanisme de tri qui n'existe pas. D est faux pour la norme ISO :
le parcours en profondeur d'abord, dans l'ordre des clauses du programme,
est la stratégie standard qui rend l'ordre des solutions **déterministe et
prévisible** — c'est justement ce qui permet de le donner comme réponse
d'examen.

</details>

---

**9.** Avec `inf(z, _).` et `inf(s(N1), s(N2)) :- inf(N1, N2).`, la requête
`?- entier_1(X), inf(Y, X).` se termine après deux solutions, mais
`?- inf(Y, X), entier_1(X).` — mêmes sous-buts, ordre inversé — continue à
chercher indéfiniment sans trouver de nouvelle solution. Pourquoi ?

- **A)** `inf(Y, X)` seul admet une infinité de solutions, et ce n'est qu'en
  le combinant en second lieu à `entier_1(X)` que la contrainte borne
  l'espace de recherche assez tôt pour un arbre fini.
- **B)** Les deux requêtes ont des ensembles de solutions logiquement
  différents.
- **C)** `inf/2` est mal défini et devrait être corrigé.
- **D)** Prolog optimise automatiquement l'ordre des sous-buts sauf en cas
  d'erreur de programmation.

<details>
<summary>Réponse</summary>

**A.** *Concept : l'ordre des sous-buts affecte la forme de l'arbre de résolution, pas la sémantique logique du but.*

B est faux : les deux requêtes admettent exactement les mêmes solutions
logiques (`Y=z,X=s(z)` et `Y=X,X=s(z)`), seul l'arbre qui les explore diffère.
C blâme la définition alors que le problème est purement un choix d'ordre à
l'appel. D attribue à Prolog une intelligence qu'il n'a pas : SLD explore
strictement l'ordre écrit, sans réorganisation automatique — c'est précisément
pour cela que l'ordre des sous-buts est un choix de conception à surveiller.

</details>

---

**10.** Une fois une solution trouvée par résolution SLD, que fait
l'algorithme si on lui redemande une solution (par exemple en tapant `;` dans
l'interpréteur) ?

- **A)** Il relance la résolution depuis le but initial, sans mémoire des
  choix précédents.
- **B)** Il retourne en arrière jusqu'au dernier point où une autre clause
  restait à essayer, et poursuit depuis là.
- **C)** Il échoue, car une seule solution est calculée par requête.
- **D)** Il explore l'arbre en largeur d'abord à partir de ce point.

<details>
<summary>Réponse</summary>

**B.** *Concept : retour arrière (backtracking) au dernier point de choix.*

A décrirait un algorithme sans mémoire d'exécution, ce qui serait extrêmement
coûteux et n'est pas comment SLD fonctionne : le retour arrière reprend
précisément là où un choix restait ouvert. C contredit tous les exemples du
recueil, où une requête énumère plusieurs solutions successives. D mélange
deux stratégies : le parcours de l'arbre de résolution reste en profondeur
d'abord même après un retour arrière, jamais en largeur.

</details>

---

**11.** Que signifie « SLD » dans « résolution SLD » ?

- **A)** Sélective, Linéaire, pour clauses Définies.
- **B)** Symbolique, Logique, Déterministe.
- **C)** Structurelle, Linéaire, Décidable.
- **D)** Séquentielle, Locale, Déclarative.

<details>
<summary>Réponse</summary>

**A.** *Concept : terminologie de l'algorithme de résolution de Prolog.*

Les trois autres options recombinent des mots qui ont un sens en informatique
théorique — déterminisme, décidabilité, déclarativité — mais ne correspondent
pas à l'acronyme réel. « Sélective » réfère au choix d'un sous-but précis à
chaque étape, « Linéaire » à la structure de la preuve, « clauses Définies » au
fragment de la logique du premier ordre utilisé (clauses de Horn).

</details>

---

**12.** Quel est le résultat de `?- X = 1 + 2.` ?

- **A)** `X = 3.`
- **B)** `X = 1+2.`
- **C)** `false.`
- **D)** Une erreur, car `1 + 2` n'est pas instancié.

<details>
<summary>Réponse</summary>

**B.** *Concept : `=` unifie sans évaluer.*

A est la réponse qu'on obtiendrait avec `X is 1 + 2` (évaluation
arithmétique) — c'est le piège central de cette question, transposer le
réflexe d'un langage où `=` calcule. C imaginerait un échec d'unification là
où il n'y en a aucune raison : `X` est une variable libre, elle s'unifie avec
n'importe quel terme, y compris le terme composé `1+2`. D confond « non
instancié » (vrai pour `X`, ce qui ne pose aucun problème à `=`) avec une
exigence d'évaluation, qui ne s'applique qu'à `is` ou aux contraintes
`clpfd`.

</details>

---

**13.** Avec `fact/2` défini par contraintes `clpfd` comme dans le recueil
(`fact(0,1). fact(N,F) :- N #> 0, N1 #= N - 1, F #= N * F1, fact(N1,F1).`),
que renvoie `?- fact(X, 720).` ?

- **A)** Une erreur, car `N` n'est pas encore instanciée quand
  `N1 #= N - 1` s'exécute.
- **B)** `false.`, car les contraintes `clpfd` ne fonctionnent que dans le
  sens direct (calculer `F` à partir de `N`).
- **C)** `X = 6.`
- **D)** Une énumération infinie de tous les `X` possibles.

<details>
<summary>Réponse</summary>

**C.** *Concept : une contrainte se pose avant d'être résolue — elle n'exige pas que son membre droit soit déjà instancié, contrairement à `is`.*

Vérifié à l'exécution (SWI-Prolog 10.0.2) : `?- fact(X, 720).` donne bien
`X = 6.`, exactement comme dans le recueil. A transpose la règle de `is/2` de
la norme ISO (absent du recueil, qui n'utilise que `clpfd`) : `is` exigerait
en effet que son membre droit soit entièrement instancié, mais `#=` n'a pas
cette contrainte — c'est justement ce qui rend l'appel « à l'envers »
possible. B nie ce que l'exemple démontre : les contraintes `clpfd`
fonctionnent dans les deux sens, posées d'abord, résolues ensuite par la
recherche sous-jacente. D confond « factorielle inversée » avec un problème
mal posé : ici une seule valeur de `N` donne `720`, la recherche se termine
normalement avec une solution puis `false.`.

</details>

---

**14.** Dans le style enseigné par le recueil (bibliothèque `clpfd`), comment
exprime-t-on la contrainte « `N1` est égal à `N - 1` » ?

- **A)** `N1 = N - 1.`
- **B)** `N1 is N - 1.`
- **C)** `N1 #= N - 1.`
- **D)** `N - N1 = 1.`

<details>
<summary>Réponse</summary>

**C.** *Concept : les contraintes `clpfd` sont préfixées par `#`.*

A donnerait une unification avec le terme composé non évalué `N-1`, pas une
contrainte numérique résolue. B est la syntaxe standard hors `clpfd` — valide
en ISO Prolog générique, mais ce n'est pas celle du recueil, qui bâtit toute
son arithmétique sur `clpfd`. D exprime la même relation mathématique mais
sous une forme qui n'est pas la notation attendue dans les exemples du cours
(`fact/2` s'écrit avec `N1 #= N - 1`, pas une relation réarrangée).

</details>

---

**15.** Que renvoie `?- membre(X, [b, a, Y]).` (avec `membre/2` défini comme
dans le recueil) ?

- **A)** Seulement `X = b` et `X = a`.
- **B)** `X = b ; X = a ; X = Y ; false.`
- **C)** `false.`, car `Y` n'est pas instanciée.
- **D)** Une énumération infinie, car `Y` peut prendre toute valeur.

<details>
<summary>Réponse</summary>

**B.** *Concept : un prédicat peut engendrer des solutions même sur des arguments partiellement non instanciés.*

A oublie la troisième position de la liste : `membre/2` explore chaque
position, y compris celle occupée par la variable libre `Y`, ce qui produit
la solution `X = Y` (les deux variables unifiées entre elles, sans valeur
concrète). C applique à tort une exigence d'instanciation complète, qui ne
s'applique pas à l'unification ordinaire ni à `membre/2`. D confond « une
variable non instanciée dans la liste » avec un domaine infini à énumérer :
ici la liste a une longueur fixe (trois éléments), donc trois solutions puis
`false.`.

</details>

---

**16.** Que renvoie `?- concatenation(L1, L2, [b, c, a, a]).` (avec
`concatenation/3` défini comme dans le recueil, équivalent à `append/3`) ?

- **A)** Une seule solution, `L1 = [], L2 = [b, c, a, a]`.
- **B)** `false.`, car `L1` et `L2` ne sont pas instanciées.
- **C)** Cinq solutions, énumérant tous les découpages de la liste en un
  préfixe `L1` et un suffixe `L2`.
- **D)** Une erreur, car les deux premiers arguments doivent être liés avant
  l'appel.

<details>
<summary>Réponse</summary>

**C.** *Concept : `append/3` (ici `concatenation/3`) fonctionne dans les deux sens grâce à l'unification.*

A ne donne que la première solution trouvée, en oubliant que le retour
arrière continue d'en produire d'autres. B et D projettent une contrainte de
langage fonctionnel — des arguments « d'entrée » obligatoires — qui n'existe
pas en Prolog : un prédicat défini par unification s'interroge dans n'importe
quel sens, ici pour engendrer les cinq façons de couper une liste de quatre
éléments en préfixe/suffixe (y compris les découpages vides).

</details>

---

**17.** Quelle notation Prolog correspond le mieux au motif `x :: reste`
d'OCaml sur une liste ?

- **A)** `[x, reste]`
- **B)** `[x | reste]`
- **C)** `[x] ++ reste`
- **D)** `head(x, reste)`

<details>
<summary>Réponse</summary>

**B.** *Concept : `[T|Q]` décompose une liste en tête et queue, comme `::` en OCaml.*

A dénote une liste à deux éléments précis, pas une décomposition tête/queue —
piège classique de confondre la virgule (élément suivant) et la barre
verticale (reste de la liste). C emprunte la notation de concaténation
d'un autre langage (par exemple F# ou Haskell pour l'opérateur infixe), qui
n'existe pas sous cette forme en Prolog — c'est `concatenation/3`
(`append/3`) qui joue ce rôle, comme prédicat, non comme opérateur. D invente
une syntaxe fonctionnelle qui n'a pas d'équivalent Prolog standard.

</details>

---

**18.** Le prédicat `length/2` est utilisé (non redéfini) dans le recueil,
par exemple dans `placement_tours(N, R) :- length(R, N), R ins 1..N, ...`.
Quel rôle joue cet appel à `length(R, N)` alors que `R` n'est pas encore
instanciée ?

- **A)** Il échoue, car `R` doit être une liste déjà connue.
- **B)** Il engendre une liste `R` de longueur `N` dont les éléments restent
  des variables libres, prêtes à être contraintes ensuite.
- **C)** Il calcule la longueur d'une liste vide par défaut.
- **D)** Il déclare `N` comme une constante globale.

<details>
<summary>Réponse</summary>

**B.** *Concept : un prédicat prédéfini peut être utilisé « à l'envers » pour construire un terme, pas seulement pour l'inspecter.*

A applique un réflexe où une fonction ne peut être appelée qu'avec ses
arguments « d'entrée » déjà connus — faux ici, comme pour `concatenation/3` :
`length/2` s'interroge dans les deux sens quand `N` est un entier concret. C
et D inventent des comportements sans rapport avec l'unification : rien dans
la définition de `length/2` ne mentionne une valeur par défaut ni une
déclaration de constante.

</details>

---

**19.** Avec `couleur(vert). couleur(jaune). couleur(rouge). couleur(bleu).
claire(vert). claire(jaune).` et
`foncee(C) :- couleur(C), \+ claire(C).`, que renvoie `?- foncee(C).` ?

- **A)** `C = vert ; C = jaune.`
- **B)** `C = rouge ; C = bleu ; false.`
- **C)** `false.`, car `\+` inverse toujours le résultat en échec.
- **D)** Une erreur, car `claire/1` n'est pas définie pour `rouge` et `bleu`.

<details>
<summary>Réponse</summary>

**B.** *Concept : négation par l'échec.*

A inverse le sens de `foncee` : ce sont justement les couleurs *sans* clause
`claire/1` qui satisfont `\+ claire(C)`. C généralise à tort : `\+ But`
réussit précisément quand `But` échoue, ce n'est pas un échec systématique.
D applique un réflexe de langage typé où l'absence de cas prévu serait une
erreur — en Prolog, l'absence de clause `claire(rouge).` signifie simplement
que `claire(rouge)` est indémontrable, donc que `\+ claire(rouge)` réussit.

</details>

---

**20.** Avec le seul fait `p(a).`, que renvoient respectivement
`?- X = b, \+ p(X).` et `?- \+ p(X), X = b.` ?

- **A)** Les deux réussissent avec `X = b`.
- **B)** Les deux échouent.
- **C)** `X = b.` pour la première, `false.` pour la seconde.
- **D)** `false.` pour la première, `X = b.` pour la seconde.

<details>
<summary>Réponse</summary>

**C.** *Concept : la négation par l'échec n'est fiable que sur des termes déjà instanciés.*

A suppose que l'ordre des sous-buts ne change rien, alors que c'est
précisément le contraire ici. B ignore que la première requête réussit bel et
bien. D inverse le résultat des deux requêtes. Dans la première, `X` vaut déjà
`b` quand `\+ p(X)` s'exécute : `p(b)` est indémontrable, la négation réussit.
Dans la seconde, `X` est encore libre : `p(X)` a une solution (`X ↦ a`), donc
`\+ p(X)` échoue immédiatement, avant même d'atteindre `X = b`.

</details>

---

**21.** Que signifie `t1 \= t2` ?

- **A)** `t1` et `t2` ont des types différents.
- **B)** `\+ (t1 = t2)` : `t1` et `t2` ne sont pas unifiables.
- **C)** `t1` est physiquement distinct de `t2` en mémoire.
- **D)** `t1` est syntaxiquement plus petit que `t2`.

<details>
<summary>Réponse</summary>

**B.** *Concept : `\=` est la négation par l'échec appliquée à l'unification.*

A projette une notion de typage étrangère à Prolog, qui n'a pas de système de
types au sens de Java ou d'OCaml. C décrit l'opposé de `==` (identité
physique), un opérateur différent qui ne fait pas intervenir la négation par
l'échec. D invente un ordre syntaxique qui n'a pas de rapport avec `\=`.

</details>

---

**22.** La requête `?- couleur(jaune).` échoue avec le seul programme
`couleur(vert). couleur(rouge).`. Peut-on en conclure que
`?- \+ couleur(jaune).` réussit ?

- **A)** Non, l'échec d'un but ne dit rien sur sa négation logique en général.
- **B)** Oui, et c'est vrai indépendamment de toute hypothèse.
- **C)** Non, car `\+` ne s'applique qu'aux prédicats arithmétiques.
- **D)** Cela dépend de l'ordre des clauses `couleur/1`.

<details>
<summary>Réponse</summary>

**B.** *Concept : hypothèse du monde clos.*

A est vrai en logique classique générale (l'absence de preuve n'équivaut pas
à la preuve du contraire) mais faux **dans le cadre spécifique adopté par
Prolog** : sous l'hypothèse du monde clos, tout ce qui n'est pas démontrable
est déclaré faux, donc l'échec de `couleur(jaune)` rend `\+ couleur(jaune)`
réussie par construction de l'opérateur. C invente une restriction sur `\+`
qui n'existe pas — il s'applique à n'importe quel but. D est un leurre :
l'ordre des clauses changerait l'ordre des solutions s'il y en avait
plusieurs, mais pas le fait qu'aucune n'existe ici.

</details>

---

**23.** Que fait l'opérateur de coupure `!`, selon la norme ISO (non traité
dans le recueil du cours) ?

- **A)** Il interrompt immédiatement tout le programme avec une erreur.
- **B)** Il réussit toujours, et élimine les points de choix ouverts depuis
  l'entrée dans la clause courante.
- **C)** Il correspond à `\+`, une négation par l'échec.
- **D)** Il force un retour arrière immédiat vers la clause précédente.

<details>
<summary>Réponse</summary>

**B.** *Concept : coupure (cut).*

A confond « couper les alternatives » avec « arrêter le programme » — `!`
laisse le but courant continuer normalement, il ne fait qu'empêcher un futur
retour arrière de revenir en arrière au-delà de son point d'insertion. C
mélange deux mécanismes distincts : la négation par l'échec teste l'échec
d'un but sans effet de bord sur les points de choix, la coupure élimine des
points de choix sans tester quoi que ce soit. D inverse complètement l'effet :
`!` empêche le retour arrière plutôt que de le déclencher.

</details>

---

**24.** Dans `clpfd`, quelle instruction force la recherche explicite des
valeurs concrètes des variables contraintes par `X in 0..2, Y in 0..2` ?

- **A)** `X #= Y.`
- **B)** `all_distinct([X, Y]).`
- **C)** `label([X, Y]).`
- **D)** `findall([X, Y], true, R).`

<details>
<summary>Réponse</summary>

**C.** *Concept : `label/1` déclenche l'énumération des valeurs, les contraintes seules ne font que les restreindre.*

A pose une contrainte supplémentaire entre `X` et `Y`, mais ne force aucune
valeur concrète — après `#=`, les deux variables restent seulement liées
l'une à l'autre dans leur domaine. B ajoute une contrainte de distinction,
avec le même effet : restreindre sans énumérer. D collecterait des solutions
d'un but donné, mais `true` n'exploite ni `X` ni `Y` et ne les instancie pas —
`findall/3` collecte, il n'énumère pas les valeurs d'une variable contrainte
à sa place.

</details>

---

**25.** Le prédicat `?- findall([X, Y], grand_parent(X, Y), R).` renvoie une
liste `R`. Que contient exactement `R` ?

- **A)** Le nombre de solutions de `grand_parent(X, Y)`.
- **B)** La première solution de `grand_parent(X, Y)` seulement.
- **C)** Une liste de couples `[X, Y]`, un par solution de
  `grand_parent(X, Y)`, y compris d'éventuels doublons si plusieurs dérivations
  produisent la même solution.
- **D)** `true` ou `false`, selon que `grand_parent(X, Y)` admette au moins
  une solution.

<details>
<summary>Réponse</summary>

**C.** *Concept : `findall/3` matérialise toutes les solutions d'un but sous forme de liste, sans les dédupliquer.*

A confondrait `findall/3` avec un prédicat de comptage — pour obtenir un
nombre, il faudrait encore prendre la longueur de `R` avec `length/2`. B
oublie que `findall/3` collecte *toutes* les solutions, pas seulement la
première — c'est justement son intérêt par rapport à l'énumération
interactive avec `;`. D confond `findall/3` avec un simple test de succès :
le recueil montre explicitement (avec `fratrie/2`) que `findall/3` peut
renvoyer des doublons, qu'il faut ensuite retirer avec `sort/2` si on veut un
ensemble de solutions distinctes.

</details>

---
