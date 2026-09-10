# Banque de QCM — Données et récursion en OCaml

30 questions. Répondre de tête, sans machine, puis déplier la réponse.
Les sorties d'interpréteur ont été vérifiées sur OCaml 5.5.1.

---

**1.** `type forme = Cercle of float | Rectangle of float * float`. De quelle famille de types s'agit-il ?

- **A)** Un type somme : chaque valeur est *soit* un cercle, *soit* un rectangle.
- **B)** Un type produit : un cercle et un rectangle sont assemblés ensemble.
- **C)** Un type paramétré, comme `'a list`.
- **D)** Un simple alias pour `float`.

<details>
<summary>Réponse</summary>

**A.** *Concept : type somme — un « ou », par opposition au type produit, un « et ».*

`Cercle` et `Rectangle` sont deux **constructeurs** : une valeur de `forme` est
l'un ou l'autre, jamais les deux. B décrit plutôt `float * float` à
l'intérieur du constructeur `Rectangle` — c'est bien un produit, mais entre les
deux champs d'un seul constructeur, pas entre les deux constructeurs. C
confondrait avec un type comme `'a arbre`, qui a un paramètre de type libre
`'a` ; ici rien n'est paramétré. D ignorerait qu'un `type ... = A | B` déclare
une union de formes distinctes, pas un simple renommage.

</details>

---

**2.** Soit `type personne = { nom : string; age : int }`, `p1 = { nom = "Ana"; age = 30 }`, puis `p2 = { p1 with age = 31 }`. Que vaut `p1` après cette évaluation ?

- **A)** `{nom = "Ana"; age = 31}`, car `p1` et `p2` partagent la même case mémoire.
- **B)** `{nom = "Ana"; age = 30}` : `p1` est inchangé.
- **C)** Une erreur, car un enregistrement ne peut être mis à jour deux fois.
- **D)** `{nom = "Ana"; age = 30}` mais uniquement si `p1` a été annoté `mutable`.

<details>
<summary>Réponse</summary>

**B.** *Concept : `{ p with ... }` construit un nouvel enregistrement, sans toucher l'original.*

Vérifié au toplevel : `p1` reste `{nom = "Ana"; age = 30}` après la création
de `p2`. A imagine une sémantique de référence partagée façon objet Java,
comme si `p2` était un alias de `p1`. C invente une restriction qui n'existe
pas — un enregistrement immuable peut servir de base à autant de mises à jour
qu'on veut, chacune produisant une copie neuve. D confond avec la mutabilité
d'un **champ** individuel (`mutable`, un mécanisme distinct qui ne change rien
ici puisque `age` n'est pas déclaré `mutable`).

</details>

---

**3.** Soit `type 'a arbre = Feuille | Noeud of 'a arbre * 'a * 'a arbre` et `let rec taille t = match t with Feuille -> 0 | Noeud (g, _, d) -> 1 + taille g + taille d`. Quel est le type de `taille` ?

- **A)** `'a arbre -> 'a`
- **B)** `'a -> int`
- **C)** `'a arbre -> int`
- **D)** `int arbre -> int`

<details>
<summary>Réponse</summary>

**C.** *Concept : type paramétré et récursif — la structure ne dépend pas du contenu.*

`taille` ne lit jamais la valeur portée par un `Noeud` (le `_` du motif
l'ignore) : elle ne fait que compter des nœuds, donc elle reste polymorphe en
`'a`, et retourne un entier. A confondrait le résultat avec le contenu de
l'arbre, comme si `taille` retournait un élément plutôt qu'un compte. B
oublierait complètement la structure `arbre` en entrée. D figerait `'a` à
`int`, une spécialisation que rien dans le code n'impose : `taille` fonctionne
aussi bien sur un `string arbre`.

</details>

---

**4.** Soit `let f o = match o with Some x -> x | None -> 0`. Quel est le type de `f` ?

- **A)** `'a option -> 'a`
- **B)** `int option -> int option`
- **C)** `'a -> int`
- **D)** `int option -> int`

<details>
<summary>Réponse</summary>

**D.** *Concept : `option` force le traitement explicite de l'absence de valeur.*

La branche `None -> 0` fixe le type de retour à `int`, ce qui force aussi
`Some x` à porter un `int` : le paramètre est donc `int option`, pas un
`'a option` resté polymorphe (A). B ferait comme si `f` reconstruisait un
`option` plutôt que d'en extraire la valeur — une confusion avec une fonction
du genre `Option.map`. C oublierait que le paramètre doit être enveloppé dans
un `option`, pas un entier nu : `f 3` est mal typé, seul `f (Some 3)` l'est.

</details>

---

**5.** Que produit exactement le compilateur pour `let cri a = match a with Chien -> "wouf" | Chat -> "miaou"` (avec `type animal = Chien | Chat | Oiseau of string`) ?

- **A)** `Warning 8 [partial-match]: this pattern-matching is not exhaustive. Here is an example of a case that is not matched: Oiseau _`
- **B)** Aucun avertissement, car `Oiseau` porte un argument et n'est pas comparable aux autres.
- **C)** `Error: This pattern matches values of type animal but a pattern was expected which matches values of type string`
- **D)** `Warning 11 [unused-match-case]`

<details>
<summary>Réponse</summary>

**A.** *Concept : exhaustivité du filtrage — le compilateur fournit un contre-exemple concret.*

Le message donne littéralement le cas manquant, `Oiseau _`, ce qui permet de
compléter le filtrage sans deviner. B croit à tort qu'un constructeur avec
argument échappe à la vérification d'exhaustivité — au contraire, il y est
pleinement soumis. C invente une erreur de type là où il n'y en a aucune :
`cri` type très bien, juste avec un cas non couvert, ce qui n'est qu'un
avertissement. D est le numéro d'un avertissement qui n'a aucun rapport,
utilisé pour du code jamais atteignable, pas pour un motif manquant.

</details>

---

**6.** Que produit exactement le compilateur pour `let rec f2 = function [] -> None | [x] -> Some x` ?

- **A)** `Error: This function has type 'a list -> 'a option, it is applied to too many arguments`
- **B)** `Warning 8 [partial-match]: ... Here is an example of a case that is not matched: x::_::_`
- **C)** `Warning 8 [partial-match]: ... Here is an example of a case that is not matched: []`
- **D)** Aucun avertissement, car `[]` et `[x]` couvrent déjà tous les cas utiles d'une liste.

<details>
<summary>Réponse</summary>

**B.** *Concept : les trois formes d'une liste — `[]`, `[x]`, `x :: y :: reste`.*

Le contre-exemple `x::_::_` se lit « au moins deux éléments » : ni `[]` ni
`[x]` ne le couvrent. C propose le contre-exemple d'un tout autre filtrage
incomplet (celui qui oublierait la liste vide, pas les listes longues) — un
distracteur qui teste si on sait lequel des deux cas est réellement absent ici.
A invente une erreur d'arité sans rapport avec un filtrage. D suppose, à tort,
qu'une liste n'a que deux formes intéressantes, en oubliant celles de plus de
deux éléments.

</details>

---

**7.** Entre `let rec somme l = match l with [] -> 0 | x :: r -> x + somme r` et `let rec somme_acc acc l = match l with [] -> acc | x :: r -> somme_acc (acc + x) r`, laquelle est récursive terminale ?

- **A)** `somme`, car elle traite la liste dans l'ordre naturel.
- **B)** Les deux, puisque toutes deux se terminent par un appel récursif dans le code source.
- **C)** `somme_acc`, car rien ne reste à faire après l'appel récursif.
- **D)** Ni l'une ni l'autre : seule une boucle `for` ou `while` peut être terminale.

<details>
<summary>Réponse</summary>

**C.** *Concept : récursion terminale — l'appel récursif est la toute dernière opération.*

Dans `somme_acc`, l'appel `somme_acc (acc + x) r` est la dernière chose qui
se produit ; le compilateur le transforme en boucle à pile constante. Dans
`somme`, il reste un `x + ...` à calculer *après* le retour de l'appel
récursif : ce n'est pas terminal, même si l'appel apparaît en dernière
position dans le texte du code — piège A, qui confond position syntaxique et
ordre réel d'évaluation. B fait la même confusion en l'appliquant aux deux
fonctions. D ignore que la terminalité est une propriété de toute fonction
récursive, indépendante des constructions impératives interdites par le guide
de style du cours.

</details>

---

**8.** Quel est le coût de `x :: l` pour construire une nouvelle liste à partir de `l` ?

- **A)** O(n), car toute la liste `l` doit être recopiée pour y ajouter `x`.
- **B)** O(log n), comme l'insertion dans un arbre équilibré.
- **C)** Indéterminé : cela dépend de la taille de `x`.
- **D)** O(1) : une seule cellule est allouée, et elle pointe simplement sur `l`.

<details>
<summary>Réponse</summary>

**D.** *Concept : une liste OCaml est une liste chaînée immuable — l'ajout en tête ne copie rien.*

`l` est **partagée**, pas recopiée : la nouvelle cellule ne fait que pointer
dessus, d'où un coût constant. A décrit plutôt le coût de `l1 @ [x]`, l'ajout
en **fin** de liste, un piège fréquent entre les deux extrémités. B importe
une intuition d'arbre équilibré (comme une structure de données persistante
plus élaborée), absente d'une liste simplement chaînée. C confond la taille de
la structure avec celle d'un élément individuel, sans rapport avec le coût de
l'opération.

</details>

---

**9.** Que vaut `[1; 2] == [1; 2]` ?

- **A)** `false`
- **B)** `true`
- **C)** `Error: compare: functional value`
- **D)** Cela dépend de l'implémentation, la norme ne garantit rien.

<details>
<summary>Réponse</summary>

**A.** *Concept : `==` teste l'identité physique, pas le contenu.*

Vérifié au toplevel : les deux littéraux construisent deux blocs mémoire
distincts, donc `false`, même si leur contenu est identique. B serait la
réponse avec `=`, l'égalité **structurelle** — la confusion la plus classique
issue de l'habitude Java/JavaScript où `==` compare parfois le contenu. C
invente une erreur réservée aux valeurs contenant des fonctions, sans rapport
avec de simples entiers. D imagine un comportement non spécifié là où le
langage définit précisément `==` comme un test de partage physique.

</details>

---

**10.** Que vaut `"abc" == "abc"` ?

- **A)** `Error: string literals cannot be compared physically`
- **D)** Cela dépend du drapeau de compilation `-unboxed-strings`.
- **C)** `true`, car le compilateur partage les littéraux de chaîne identiques.
- **B)** `false`

<details>
<summary>Réponse</summary>

**D.** *Concept : deux occurrences syntaxiques d'un même littéral restent deux blocs distincts.*

Vérifié au toplevel : chaque `"abc"` alloue sa propre chaîne, donc `false`. C
suppose une optimisation de partage de littéraux comme le fait la JVM pour son
« string pool » — OCaml ne la garantit pas pour des chaînes construites
séparément dans le code source. A invente une restriction qui n'existe pas :
`==` s'applique à n'importe quelle valeur, chaînes comprises. B invente un
drapeau de compilation qui n'existe pas dans la chaîne d'outils du cours.

</details>

---

**11.** Que répond le toplevel à `1.0 +. 2` ?

- **A)** `- : float = 3.0`
- **B)** `- : float = 3.`
- **C)** `Error: This expression has type int but an expression was expected of type float` (avec l'indice `Did you mean 2.?`)
- **D)** `- : int = 3`

<details>
<summary>Réponse</summary>

**C.** *Concept : les opérateurs flottants n'acceptent que des flottants — aucune conversion implicite.*

Vérifié au toplevel : `2` reste un `int`, et `+.` exige un `float` des deux
côtés ; l'erreur est levée avant tout calcul, avec la suggestion `2.`. A et B
supposent une promotion automatique `int -> float` comme en Java ou en C — un
réflexe qui coûte cher ici, puisqu'il n'existe aucune conversion implicite
entre les deux mondes numériques d'OCaml. D applique par erreur l'opérateur
entier `+`, ignorant le point qui distingue `+.` de `+`.

</details>

---

**12.** Que répond le toplevel à `(-7) mod 2` ?

- **A)** `- : int = 1`
- **B)** `Error: this expression is invalid on negative operands`
- **C)** `- : int = -1.`
- **D)** `- : int = -1`

<details>
<summary>Réponse</summary>

**D.** *Concept : le signe du reste suit celui du dividende, pas une convention mathématique fixe.*

Vérifié au toplevel : `(-7) mod 2` vaut `-1`. A serait la réponse d'un
« modulo mathématique » toujours positif, comme certains langages le
définissent (Python, notamment) — OCaml suit plutôt la convention du C, où le
signe du reste suit celui du premier opérande. B invente une restriction sur
les négatifs qui n'existe pas : `mod` accepte les deux signes. C ajoute un
point décimal à une valeur qui reste un `int`, une confusion de type absurde
ici puisque `mod` n'existe que sur les entiers.

</details>

---

**13.** Que répond le toplevel à `7 / (-2)` ?

- **A)** `- : int = -3`
- **B)** `- : int = -4`
- **C)** `- : int = -3.5`
- **D)** `- : float = -3.5`

<details>
<summary>Réponse</summary>

**A.** *Concept : la division entière tronque vers zéro, elle n'arrondit pas vers le bas.*

Vérifié au toplevel : `7 / (-2)` vaut `-3`, pas `-4`. B serait le résultat
d'un arrondi vers `-∞` (le comportement de Python pour `//`) — une convention
différente et plausible, mais pas celle d'OCaml. C et D introduisent une
partie décimale dans une division qui reste entre deux `int`, ce que
l'opérateur `/` ne fait jamais : seul `/.` produit un `float`, et seulement
entre deux `float`.

</details>

---

**14.** Que répond le toplevel à `max_int` ?

- **A)** `- : int = 2147483647`
- **B)** `- : int = 4611686018427387903`
- **C)** `- : int = 9223372036854775807`
- **D)** `- : int = 4611686018427387904`

<details>
<summary>Réponse</summary>

**B.** *Concept : l'entier natif d'OCaml occupe 63 bits, pas 64.*

Vérifié au toplevel. A est le `int` 32 bits classique (Java, ou un `int` C sur
certaines plateformes) — une taille qu'OCaml n'utilise pas pour son type
`int` natif. C serait la borne d'un entier 64 bits signé complet, comme le
`long` de Java ou de C# — proche, mais OCaml sacrifie un bit pour distinguer à
l'exécution un entier d'un pointeur, d'où la division par deux. D est un piège
de décalage d'une unité : c'est en réalité `min_int` (la borne négative),
pas `max_int`.

</details>

---

**15.** `let p = { nom = "Ana"; age = 30 } in { p with age = 31 }` construit un nouvel enregistrement sans toucher `p`. Quel principe théorique cette observation illustre-t-elle directement ?

- **A)** Le polymorphisme paramétrique.
- **B)** La récursivité terminale.
- **C)** La transparence référentielle : remplacer une expression par sa valeur ne change pas le sens du programme.
- **D)** La restriction aux valeurs.

<details>
<summary>Réponse</summary>

**C.** *Concept : transparence référentielle.*

Puisque rien n'est modifié en place, on peut partout remplacer `p` par sa
valeur sans changer le résultat du programme — la définition exacte attendue
par le correcteur. A concerne les types génériques comme `'a list`, un sujet
sans rapport avec la mutation. B concerne la forme d'un appel récursif, pas
l'immuabilité des données. D est un phénomène de typage lié à la
généralisation des `let`, sans lien avec le fait qu'un enregistrement mis à
jour reste intact.

</details>

---

**16.** Soit `type animal = Chien | Chat | Oiseau of string`. Que vaut `compare Chien Chat` ?

- **A)** `Error: compare is not defined on variant types without an explicit equality`
- **B)** `0`, car ce sont deux constructeurs du même type.
- **C)** `1`
- **D)** `-1`

<details>
<summary>Réponse</summary>

**D.** *Concept : la comparaison polymorphe ordonne les constructeurs par ordre de déclaration.*

Vérifié au toplevel : `Chien`, déclaré en premier, est structurellement plus
« petit » que `Chat`. B confondrait comparaison et égalité : deux
constructeurs distincts du même type ne sont jamais égaux. C inverse le sens
de l'ordre. A invente une restriction : `compare` fonctionne sur n'importe
quel type sans fonction personnalisée, y compris les types somme — c'est
justement ce que le cours appelle la comparaison structurelle générique.

</details>

---

**17.** Quel est le coût de `List.nth l i` ?

- **A)** O(i) : il faut suivre les `i` premiers maillons, aucun accès indexé n'existe.
- **B)** O(1), comme l'indexation d'un tableau.
- **C)** O(n), toujours proportionnel à la longueur totale de la liste.
- **D)** O(log n), par recherche dichotomique sur la structure chaînée.

<details>
<summary>Réponse</summary>

**A.** *Concept : une liste chaînée n'offre pas d'accès indexé en temps constant.*

Il faut parcourir la liste maillon par maillon jusqu'au `i`-ième, donc un coût
qui dépend de l'indice demandé, pas de la longueur totale — ce qui élimine
d'ailleurs C dans le cas où `i` est petit devant `n`. B applique le réflexe
d'un tableau ou d'une `ArrayList`, structure à laquelle une liste OCaml ne
ressemble pas du tout malgré la syntaxe proche. D importe une recherche
dichotomique qui suppose un ordre et un accès direct au milieu de la
structure, deux propriétés qu'une liste chaînée n'a pas.

</details>

---

**18.** Soit `let rec last l = match l with [x] -> x | _ :: r -> last r`. Quel cas manque, selon l'avertissement du compilateur ?

- **A)** `x :: y :: reste`
- **B)** `[]`
- **C)** Aucun cas ne manque : la fonction est totale sur toute liste non vide.
- **D)** `[x; y]`

<details>
<summary>Réponse</summary>

**B.** *Concept : reconnaître le cas manquant à partir des trois formes d'une liste.*

Vérifié au toplevel : le contre-exemple donné est `[]`. Ni `[x]` ni
`_ :: r` (qui couvre toute liste d'au moins un élément, y compris les longues)
ne traitent la liste vide — d'où l'exception `Match_failure` si on appelle
`last []`. A décrit un motif déjà couvert par `_ :: r`, qui absorbe toutes les
listes de deux éléments ou plus. C ignore l'avertissement réel du compilateur.
D est un cas particulier de A, déjà couvert par la seconde branche.

</details>

---

**19.** Quel est le coût de `List.rev l` ?

- **A)** O(n²), car chaque élément déplacé recopie ce qui précède.
- **B)** O(1), la liste inversée partage les mêmes cellules.
- **C)** O(n), en une seule passe qui accumule en tête.
- **D)** O(n log n), comme un tri.

<details>
<summary>Réponse</summary>

**C.** *Concept : inverser une liste chaînée coûte une seule passe linéaire.*

`List.rev` accumule les éléments un par un en tête d'un nouvel accumulateur,
donc une seule traversée, O(n) — et c'est terminal. A serait le coût d'un
mauvais idiome comme `acc @ [x]` répété dans une boucle, pas celui de `rev`
lui-même. B ignorerait qu'inverser une liste chaînée doit nécessairement
reconstruire chaque cellule, puisque le sens des pointeurs change. D importe à
tort un coût de tri, sans rapport avec une simple inversion.

</details>

---

**20.** Accumuler des éléments avec `acc @ [x]` à chaque tour d'une récursion sur une liste de longueur n coûte au total :

- **A)** O(n), comme `x :: acc`.
- **B)** O(log n), amorti sur l'ensemble des appels.
- **C)** O(1) par tour, donc négligeable.
- **D)** O(n²), car chaque `@` recopie tout l'accumulateur déjà construit.

<details>
<summary>Réponse</summary>

**D.** *Concept : le piège de complexité le plus coûteux en style fonctionnel naïf.*

Chaque `acc @ [x]` recopie l'intégralité de `acc`, dont la taille croît à
chaque tour ; la somme des copies sur n tours donne O(n²). A serait vrai pour
l'idiome correct, `x :: acc` suivi d'un seul `List.rev` final — précisément ce
que ce distracteur invite à confondre avec l'accumulation en fin de liste. B
et C sous-estiment le coût d'une seule opération `@`, déjà linéaire en elle-même,
avant même de la répéter n fois.

</details>

---

**21.** Quel est le type de `let rec somme_paire l = match l with [] -> 0 | (a, b) :: r -> a + b + somme_paire r` ?

- **A)** `(int * int) list -> int`
- **B)** `int list -> int`
- **C)** `(int * int) list -> int * int`
- **D)** `'a list -> int`

<details>
<summary>Réponse</summary>

**A.** *Concept : filtrage direct sur un motif de tuple dans une liste.*

Chaque élément de la liste est déstructuré en `(a, b)`, tous deux additionnés
comme des `int` : la liste contient donc des couples d'entiers, et le résultat
est un `int`. B oublierait que les éléments sont des couples, pas des entiers
nus. C confondrait la valeur retournée avec un élément de la liste d'entrée.
D laisserait les éléments polymorphes, alors que `+` les contraint tous les
deux à `int`.

</details>

---

**22.** Que répond le toplevel à `(1, 2) == (1, 2)` ?

- **A)** `Error: tuples cannot be compared physically`
- **B)** `false`
- **C)** `true`, les petits tuples d'entiers étant internés par le compilateur.
- **D)** Cela dépend de l'option d'optimisation `-O3`.

<details>
<summary>Réponse</summary>

**B.** *Concept : deux constructions séparées d'un même tuple restent deux blocs distincts.*

Vérifié au toplevel : chaque `(1, 2)` alloue son propre bloc mémoire, comme
pour les listes. C imagine un partage automatique de petites valeurs
immuables, une optimisation que le compilateur ne garantit pas ici (contraste
avec les entiers eux-mêmes, qui ne sont pas boxés et donc sans notion
d'identité physique séparée). A invente une restriction absente : `==`
s'applique à toute valeur, tuples compris. D invente un drapeau de compilation
hors du cadre du cours.

</details>

---

**23.** Que répond le toplevel à `2.0 = 2` ?

- **A)** `- : bool = true`
- **B)** `- : bool = false`
- **C)** `Error: This expression has type int but an expression was expected of type float` (avec l'indice `Did you mean 2.?`)
- **D)** `- : bool = true` mais uniquement en désactivant les avertissements de type.

<details>
<summary>Réponse</summary>

**C.** *Concept : `=` est une égalité structurelle typée — pas de comparaison entre `int` et `float`.*

Vérifié au toplevel. `=` compare deux valeurs du **même** type ; ici les deux
opérandes ne sont même pas censés partager un type avant comparaison, donc
l'erreur survient avant toute évaluation d'égalité — B suppose que la
comparaison a lieu et échoue simplement, ce qui n'est pas le cas : elle
n'a jamais lieu. A supposerait une conversion numérique implicite façon
JavaScript (`2.0 == 2` y vaut `true`). D invente un mécanisme de suppression
d'erreur par avertissement, alors qu'il s'agit d'une erreur de compilation,
pas d'un simple avertissement désactivable.

</details>

---

**24.** Quel est le type de `let rec map_lent f l = match l with [] -> [] | x :: r -> f x :: map_lent f r` ?

- **A)** `('a -> 'a) -> 'a list -> 'a list`
- **B)** `('a -> 'b list) -> 'a list -> 'b list`
- **C)** `'a list -> ('a -> 'b) -> 'b list`
- **D)** `('a -> 'b) -> 'a list -> 'b list`

<details>
<summary>Réponse</summary>

**D.** *Concept : réimplémentation de `List.map` — même type que la fonction de la bibliothèque.*

`f` transforme chaque élément de `'a` vers `'b`, sans contrainte que les deux
types coïncident, exactement comme `List.map`. A forcerait `f` à préserver le
type, une restriction que rien dans le code n'impose (contrairement à
`twice`, où l'argument est réappliqué à lui-même). B ferait comme si `f`
produisait directement une liste par élément, un comportement propre à une
fonction du genre `List.concat_map`, pas à celle-ci. C inverse l'ordre des
deux arguments de `map_lent`.

</details>

---

**25.** Sur OCaml 5, `let rec somme l = match l with [] -> 0 | x :: r -> x + somme r` appliquée à une liste d'un million d'éléments :

- **A)** Se termine normalement, la pile croissant dynamiquement — mais la fonction reste non terminale.
- **B)** Lève systématiquement `Stack_overflow`, car toute fonction non terminale déborde la pile.
- **C)** Se termine seulement si elle est compilée avec l'option `-tailcall`.
- **D)** Devient automatiquement terminale grâce à l'optimisation du compilateur.

<details>
<summary>Réponse</summary>

**A.** *Concept : « non terminale » est une propriété du code, pas une prédiction de plantage.*

Vérifié : sur OCaml 5, la pile grandit dynamiquement, et un million d'éléments
passe sans encombre. La question d'examen porte sur ce que fait
*structurellement* le code (reste-t-il un calcul à faire après l'appel
récursif ?), pas sur le déclenchement effectif d'un débordement — B applique
une règle qui valait surtout sur d'anciennes plateformes à pile fixe, plausible
mais fausse ici. C invente une option de compilation qui n'a aucun effet sur
la terminalité réelle du code source. D confond « non terminale » avec «
increvable » : le compilateur ne réécrit jamais une fonction non terminale en
fonction terminale, il se contente de laisser croître la pile.

</details>

---

**26.** Quel est le type de `let t = (1, "a", true)` ?

- **A)** `int * string * bool -> unit`
- **B)** `int * string * bool`
- **C)** `(int, string, bool)`
- **D)** `int list`

<details>
<summary>Réponse</summary>

**B.** *Concept : un tuple hétérogène est un type produit à arité fixe.*

Chaque position du tuple garde son propre type, séparé par `*` : c'est la
notation d'un type produit à trois composantes. A transformerait le tuple en
type d'une fonction, une confusion entre une valeur et une signature. C
emprunte la syntaxe générique de Java (`<Int, String, Boolean>`), qu'OCaml
n'utilise pas pour les tuples. D confondrait un tuple hétérogène avec une
liste, qui exige que tous ses éléments partagent un seul et même type.

</details>

---

**27.** Quel est le type de `let rec longueur_t acc l = match l with [] -> acc | _ :: r -> longueur_t (acc + 1) r` ?

- **A)** `int list -> int -> int`
- **B)** `'a list -> int`
- **C)** `int -> 'a list -> int`
- **D)** `int -> int list -> int`

<details>
<summary>Réponse</summary>

**C.** *Concept : un accumulateur de récursion terminale n'ajoute aucune contrainte sur le contenu de la liste.*

`acc` est un `int` (incrémenté par `+ 1`), et les éléments de `l` ne sont
jamais lus : `l` reste `'a list`. B oublierait le paramètre accumulateur,
comme si la fonction était appelée avec la seule liste — signature de la
version non accumulée, `longueur`. A inverse l'ordre des deux paramètres. D
fixe à tort le type des éléments de la liste à `int`, une confusion entre le
type de l'accumulateur et celui du contenu.

</details>

---

**28.** Soit `type animal = Chien | Chat | Oiseau of string` et `let partial = function Chien -> "wouf" | Oiseau s -> s`. Quel cas manque, selon l'avertissement du compilateur ?

- **A)** `Chien`, déjà couvert deux fois par erreur.
- **B)** Aucun : `Oiseau s` couvre implicitement `Chat` puisque tous deux portent une donnée.
- **C)** `Oiseau _`, en plus de `Oiseau s`.
- **D)** `Chat`

<details>
<summary>Réponse</summary>

**D.** *Concept : chaque constructeur d'un type somme doit apparaître explicitement dans le filtrage.*

Vérifié au toplevel : le contre-exemple est `Chat`. B confond deux
constructeurs distincts du même type sous prétexte que l'un porte une donnée
et pas l'autre — le filtrage se fait par constructeur, jamais par « forme »
générale. A invente une double couverture qui n'existe pas dans ce code. C
imagine un second manquement à l'intérieur même du constructeur déjà couvert
par `Oiseau s`, alors que ce motif capture bien tous les `Oiseau`.

</details>

---

**29.** Quel est le type de `List.append` ?

- **A)** `'a list -> 'a list -> 'a list`
- **B)** `'a list -> 'b list -> ('a * 'b) list`
- **C)** `'a list -> 'a list -> int`
- **D)** `'a -> 'a list -> 'a list`

<details>
<summary>Réponse</summary>

**A.** *Concept : concaténer deux listes exige qu'elles partagent le même type d'élément.*

`List.append` (l'équivalent nommé de `@`) prend deux listes du même type
`'a` et en rend une troisième, du même type. B imaginerait un appariement
élément par élément façon `List.combine`, une fonction différente qui, de
plus, exige des listes de même longueur. C confondrait la concaténation avec
un calcul de longueur combinée. D est le type de `x :: l`, l'ajout d'un
élément isolé, pas la fusion de deux listes.

</details>

---

**30.** `let rec longueur l = match l with [] -> 0 | _ :: r -> 1 + longueur r`. Est-elle récursive terminale ?

- **A)** Oui, l'appel `longueur r` est visuellement la dernière chose écrite dans la branche.
- **B)** Non : il reste un `1 + ...` à calculer après le retour de l'appel récursif.
- **C)** Oui, parce qu'elle ne construit aucune liste en retour.
- **D)** La question n'a pas de réponse : la terminalité ne se définit que pour les fonctions à accumulateur.

<details>
<summary>Réponse</summary>

**B.** *Concept : le test de terminalité porte sur ce qui reste à faire, pas sur la position syntaxique de l'appel.*

Après le retour de `longueur r`, il faut encore calculer `1 + ...` : ce
n'est pas la dernière opération, donc pas terminal, même si l'appel apparaît
en fin de ligne — le piège exact de A, qui confond ordre d'écriture et ordre
d'évaluation. C invente un critère (l'absence de construction de liste) sans
rapport avec la définition de la récursivité terminale, qui porte sur les
calculs entiers comme sur les listes. D nie une propriété qui se définit très
bien indépendamment de la présence d'un accumulateur — c'est justement la
comparaison entre `longueur` et `longueur_t` qui l'illustre.

</details>

---
