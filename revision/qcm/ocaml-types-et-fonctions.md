# Banque de QCM — Types et fonctions en OCaml

30 questions. Répondre de tête, sans machine, puis déplier la réponse.
Les sorties d'interpréteur ont été vérifiées sur OCaml 5.5.1.

---

**1.** Quel est le type de `let compose f g x = f (g x)` ?

- **A)** `('a -> 'b) -> ('a -> 'b) -> 'a -> 'b`
- **B)** `('a -> 'a) -> ('a -> 'a) -> 'a -> 'a`
- **C)** `('b -> 'c) -> ('a -> 'b) -> 'c -> 'a`
- **D)** `('a -> 'b) -> ('c -> 'a) -> 'c -> 'b`

<details>
<summary>Réponse</summary>

**D.** *Concept : attribution des types par unification de contraintes.*

`g` reçoit `x`, donc `x : 'c` et `g : 'c -> 'a` pour un `'a` frais. `f` reçoit
le résultat de `g x`, donc `f : 'a -> 'b`. Le tout retourne `'b`. A force `f` et
`g` au même type, ce qui n'est vrai que si on compose une fonction avec
elle-même — un cas particulier, pas le type général. B est le type qu'aurait
`compose` si on lui interdisait de changer de type en chemin, ce qui n'est
jamais exigé ici.

</details>

---

**2.** Quel est le type de `let flip f x y = f y x` ?

- **A)** `('a -> 'b -> 'c) -> 'a -> 'b -> 'c`
- **B)** `('a -> 'a -> 'b) -> 'a -> 'a -> 'b`
- **C)** `('a -> 'b -> 'c) -> 'b -> 'a -> 'c`
- **D)** `('a * 'b -> 'c) -> 'b -> 'a -> 'c`

<details>
<summary>Réponse</summary>

**C.** *Concept : dérivation mécanique du type d'une fonction d'ordre supérieur.*

`f` prend d'abord un `'a`, puis un `'b`. `flip` appelle `f y x`, donc `y`
occupe la première place de `f` (`'a`) et `x` la seconde (`'b`) : `flip`
lui-même prend `x : 'b` puis `y : 'a`. A est le type de `f` lui-même, pas de
`flip` — piège classique d'inattention sur qui prend quoi. B force les deux
arguments de `f` au même type, ce que rien n'impose. D confond `f` curryfiée
avec une fonction sur un couple.

</details>

---

**3.** Quel est le type de `let twice f x = f (f x)` ?

- **A)** `('a -> 'a) -> 'a -> 'a`
- **B)** `('a -> 'b) -> 'a -> 'b`
- **C)** `('a -> 'a) -> 'a list -> 'a list`
- **D)** `('a -> 'b) -> 'a -> 'a`

<details>
<summary>Réponse</summary>

**A.** *Concept : unification de types entre applications successives.*

`f x` doit avoir le même type que `x` puisqu'il est réappliqué à `f`. Cette
seule contrainte force `f : 'a -> 'a`. B laisse `f` changer de type en cours
de route, ce qui est incompatible avec le fait que la sortie de `f` doit
retourner à l'entrée de `f`. C invente un paramètre liste absent de la
définition. D fait retourner à `twice` le type d'entrée de `f`, alors qu'elle
retourne la sortie de `f`, ici identique par l'unification déjà faite — un
distracteur qui n'est faux que par accident de formulation, à lire lentement.

</details>

---

**4.** Que répond le toplevel à `let bad_annot (x : int) : string = x` ?

- **A)** `val bad_annot : int -> string = <fun>`
- **B)** `Error: The value x has type int but an expression was expected of type string`
- **C)** Le compilateur ignore l'annotation `: string` et infère `int -> int`.
- **D)** `Warning 8 [partial-match]`

<details>
<summary>Réponse</summary>

**B.** *Concept : les annotations sont des contraintes, pas des conversions.*

Une annotation de type ne transforme rien : elle ajoute une contrainte que
l'unification doit satisfaire, et échoue si le corps ne la respecte pas. A est
la réponse qu'on aurait dans un langage à cast implicite. C suppose qu'une
annotation est une simple indication facultative, jamais vérifiée — faux, elle
est vérifiée systématiquement. D confond ceci avec un avertissement de
filtrage incomplet, sans rapport avec une erreur de type.

</details>

---

**5.** Que répond le toplevel à `if true then 1 else 2.0` ?

- **A)** `- : float = 1.0`
- **B)** `- : int = 1`
- **C)** `Error: The constant 2.0 has type float but an expression was expected of type int`
- **D)** Les deux branches sont acceptées telles quelles, le type de l'expression entière est laissé polymorphe.

<details>
<summary>Réponse</summary>

**C.** *Concept : un `if` unifie le type de ses deux branches.*

Les deux branches d'un `if` (comme celles d'un `match`) doivent avoir
exactement le même type ; la première branche fixe `int`, ce qui rend la
seconde mal typée. A suppose une conversion implicite vers le type le plus
« large », comme en Java entre `int` et `double` — OCaml n'en fait aucune. B
ignorerait simplement la branche `else`, ce que le compilateur ne fait jamais,
branche morte ou non. D transformerait le typage statique en vérification
paresseuse, ce qu'aucun des deux paradigmes de typage vus en cours ne fait.

</details>

---

**6.** Une fonction a le type `'a list -> 'a list`. Laquelle des définitions suivantes peut avoir ce type ?

- **A)** `let f l = List.map (fun x -> x + 1) l`
- **B)** `let f l = List.rev l`
- **C)** `let f l = List.filter (fun x -> x > 0) l`
- **D)** Deux réponses sont possibles : B et C.

<details>
<summary>Réponse</summary>

**D.** *Concept : polymorphisme paramétrique — une fonction générique ne peut inspecter la valeur des éléments.*

`List.rev` ne fait que réordonner des cellules, `List.filter` ne fait que
garder ou jeter des éléments sans les lire : les deux restent polymorphes.
`List.map (fun x -> x + 1)` force les éléments à être des `int`, ce qui donne
`int list -> int list` — un cas particulier, pas la fonction demandée. C'est
la même famille de piège que « `'a -> 'a` » appliqué à une fonction qui, en
réalité, additionne son argument à un entier littéral quelque part dans le
corps.

</details>

---

**7.** Quel est le type de `List.assoc` ?

- **A)** `'a -> ('a * 'b) list -> 'b`
- **B)** `('a * 'b) list -> 'a -> 'b`
- **C)** `'a -> ('a * 'b) list -> 'b option`
- **D)** `'a -> 'b list -> 'a`

<details>
<summary>Réponse</summary>

**A.** *Concept : type exact d'une fonction de la bibliothèque `List`.*

`List.assoc clé liste` cherche la clé dans une liste de couples et retourne
la valeur associée, ou lève `Not_found` — d'où l'absence d'`option` dans le
type, ce qui élimine C. B inverse l'ordre des deux arguments, un piège pur
d'inattention sur la signature exacte. D ne correspond à aucune fonction du
module `List` : une liste de `'b` ne contiendrait aucun couple à chercher.

</details>

---

**8.** Quel est le type de `List.fold_right` ?

- **A)** `('acc -> 'a -> 'acc) -> 'acc -> 'a list -> 'acc`
- **B)** `('a -> 'acc -> 'acc) -> 'acc -> 'a list -> 'acc`
- **C)** `('a -> 'a -> 'a) -> 'a list -> 'a`
- **D)** `('a -> 'acc -> 'acc) -> 'a list -> 'acc -> 'acc`

<details>
<summary>Réponse</summary>

**D.** *Concept : ordre des arguments d'un pli droit contre un pli gauche.*

`fold_right` prend la fonction, puis la liste, puis l'accumulateur initial —
l'ordre inverse de `fold_left`, qui est A. C'est le type exact que le
professeur attend qu'on distingue sans hésiter. C est le type d'une réduction
sans accumulateur séparé (comme `List.fold_left (fun a b -> a+b)` appliqué à
un type homogène), une fonction voisine mais différente. B permute
accumulateur et liste par rapport à la vraie signature de `fold_right`.

</details>

---

**9.** Que répond le toplevel pour `let id x = x in let dup = id id in dup` ?

- **A)** `- : 'a -> 'a = <fun>`
- **B)** `Error: This expression has type 'a -> 'a but an expression was expected of type 'a`
- **C)** `- : '_weak1 -> '_weak1 = <fun>`
- **D)** `- : 'weak1 -> 'weak1 = <fun>` (sans le tiret bas)

<details>
<summary>Réponse</summary>

**C.** *Concept : restriction aux valeurs — seule une valeur syntaxique est généralisée.*

`id id` est une **application** de fonction, pas une valeur syntaxique (un
`fun` ou une constante), donc son résultat n'est pas généralisé même s'il est
polymorphe en théorie : on obtient une variable de type **faible**, à fixer au
premier usage concret. A est la réponse qu'on aurait si `dup` était défini
directement par `fun x -> x` — une simple copie de `id`, sans application. B
imagine une erreur de type là où il n'y en a pas : l'expression type très
bien, juste avec une variable faible. D confond la notation avec un identifiant
de type ordinaire ; le tiret bas de `'_weak1` fait partie de la syntaxe du
compilateur pour signaler « faible ».

</details>

---

**10.** À la suite de la question précédente, que répond `dup 5` ?

- **A)** `- : int = 5`
- **B)** `Error: This expression has type int but an expression was expected of type 'a`
- **C)** `- : '_weak1 = 5`
- **D)** `- : 'a = 5`

<details>
<summary>Réponse</summary>

**A.** *Concept : la variable faible se fixe définitivement au premier usage.*

`'_weak1` n'est pas une erreur ni une impossibilité de typer : c'est une
attente. Le premier appel concret, ici avec un `int`, la fixe pour de bon —
`dup` devient ensuite `int -> int` dans toute la session. B suppose à tort que
la variable faible bloque tout usage. C garde la notation faible après
résolution, alors qu'elle disparaît une fois fixée. D fait comme si la
variable avait été généralisée depuis le début, ce qui contredit la question
précédente.

</details>

---

**11.** Quel est le type de `let const x y = x in const 1` ?

- **A)** `'a -> int`
- **B)** `int -> 'a -> int`
- **C)** `'_weak1 -> int`
- **D)** `int`

<details>
<summary>Réponse</summary>

**C.** *Concept : la restriction aux valeurs s'applique aussi à une application partielle.*

`const 1` est une application (avec un seul argument sur deux fournis), donc
pas une valeur syntaxique : la variable qui reste libre, celle du paramètre
`y` jamais fourni, est faible plutôt que généralisée. A serait vrai si
`const 1` avait été écrit directement comme `fun y -> 1`, une fonction
littérale. B est le type de `const` avant toute application. D confond la
fonction partiellement appliquée avec le résultat d'un appel complet.

</details>

---

**12.** Toujours avec `let const x y = x in let a = const 1 in a "salut"`, que répond le toplevel pour `a "salut"` ?

- **A)** `Error: This expression has type string but an expression was expected of type 'a`
- **B)** `- : int = 1`
- **C)** `- : '_weak1 = 1`
- **D)** `- : string = "salut"`

<details>
<summary>Réponse</summary>

**B.** *Concept : fixer une variable faible avec un argument concret.*

L'application à `"salut"` fixe la variable faible de `a` à `string`, mais
`const` retourne toujours son **premier** argument, déjà `int` — le résultat
de l'appel est donc `1`, de type `int`. A imagine une vérification de type sur
l'argument jamais fourni, alors que seul le type de retour dépendait de `x`.
C garde la notation faible après un usage concret, ce qui n'a plus de sens. D
suppose, à tort, que `const` retourne son second argument — c'est le
comportement de `flip const`, une fonction différente.

</details>

---

**13.** Quel est le type de `5 |> (fun x -> x + 1) |> string_of_int` avec `let ( |> ) x f = f x` (redéfini localement, comme dans l'exercice de style du cours) ?

- **A)** `int`
- **B)** `string`
- **C)** `int -> string`
- **D)** `'a -> string`

<details>
<summary>Réponse</summary>

**B.** *Concept : type d'une chaîne de tubes (`pipe`), assemblée de gauche à droite.*

`5 |> (fun x -> x+1)` vaut `6 : int`, puis ce résultat est passé à
`string_of_int`, qui rend `"6" : string`. C'est la valeur de l'expression
entière, pas une fonction en attente d'argument — ce qui élimine C et D,
réponses qu'on aurait si l'expression s'arrêtait avant le dernier tube ou
si `5` n'était pas encore appliqué.

</details>

---

**14.** `let x = 3 in let f y = x + y in let x = 100 in f 1`. Que retourne cette expression ?

- **A)** `101`
- **B)** `4`
- **C)** `103`
- **D)** `1`

<details>
<summary>Réponse</summary>

**B.** *Concept : liaison et portée statique — une fermeture capture l'environnement de sa définition.*

`f` est définie pendant que `x` vaut `3` ; elle capture cette liaison-là. Le
second `let x = 100` crée une **nouvelle** liaison qui masque la première pour
la suite du programme, mais ne modifie rien dans la fermeture déjà construite
— il n'existe pas d'affectation en OCaml. `f 1` vaut donc `3 + 1 = 4`. A et C
supposent que `f` relit la valeur courante de `x` au moment de l'appel, ce qui
serait le cas en **portée dynamique**, un mécanisme que quasiment aucun langage
moderne n'utilise. D oublie le `+ y` du corps de `f`.

</details>

---

**15.** `let g = fun x -> x + 1 in let g = fun x -> x * 2 in g 10`. Que retourne cette expression ?

- **A)** `11`
- **B)** `Error: g is already defined`
- **C)** `21`
- **D)** `20`

<details>
<summary>Réponse</summary>

**D.** *Concept : masquage (shadowing) d'une liaison, pas mutation.*

Le second `let g = ...` ne modifie pas la première fonction `g` : il introduit
une liaison distincte qui masque la précédente pour tout ce qui suit. L'appel
`g 10` voit la fonction la plus récente, `fun x -> x * 2`, donc `20`. A
utiliserait la première définition, comme si le second `let` n'existait pas.
C additionnerait les deux résultats, une confusion entre masquage et
composition. B suppose une règle d'unicité des identifiants façon variable
`let`/`const` de JavaScript ; OCaml autorise de rebinder le même nom sans
restriction.

</details>

---

**16.** Quel est le type de `let sub x y = x - y in sub 5` ?

- **A)** `int`
- **B)** `int -> int -> int`
- **C)** `int -> int`
- **D)** `int * int -> int`

<details>
<summary>Réponse</summary>

**C.** *Concept : curryfication — une fonction OCaml ne prend jamais qu'un seul argument.*

`sub` a le type `int -> int -> int`, à lire `int -> (int -> int)`. Fournir un
seul argument, `5`, retourne la fonction restante, `int -> int`, une valeur
parfaitement légale à manipuler et à rappeler plus tard. A confond
l'application partielle avec un appel complet — comme si `sub 5` déclenchait
déjà une erreur de nombre d'arguments façon Java. B rend le type de `sub`
elle-même, avant application. D est le type d'une fonction voisine prenant un
couple, `let sub (x, y) = x - y`, pas celui d'une fonction curryfiée.

</details>

---

**17.** Étant donné `sub5 = sub 5` (avec `sub x y = x - y`), que vaut `sub5 3` ?

- **A)** `2`
- **B)** `-2`
- **C)** `8`
- **D)** `Error: sub5 expects 2 arguments, but is applied to 1`

<details>
<summary>Réponse</summary>

**A.** *Concept : ordre des paramètres dans une application partielle.*

`sub5` a fixé le premier paramètre `x = 5` ; l'appel `sub5 3` fournit le second,
`y = 3`, et calcule `5 - 3 = 2` (vérifié au toplevel : `sub5 3` donne
`- : int = 2`). B, `-2`, serait le résultat si l'application partielle fixait
plutôt `y` en premier — le comportement de `flip sub 5`, une fonction
différente. C confond soustraction et addition. D imagine une arité vérifiée à
l'exécution comme en Java, alors que l'arité n'est qu'une affaire de type,
déjà résolue à la compilation : rien n'empêche d'appliquer une fonction à deux
paramètres à un seul argument.

</details>

---

**18.** Quel est le type de `List.find_opt` ?

- **A)** `('a -> bool) -> 'a list -> 'a`
- **B)** `('a -> bool) -> 'a list -> 'a option`
- **C)** `'a -> 'a list -> 'a option`
- **D)** `('a -> bool) -> 'a list -> bool`

<details>
<summary>Réponse</summary>

**B.** *Concept : le suffixe `_opt` remplace une exception par un `option`.*

`List.find_opt` a le même rôle que `List.find` (A) mais rend `None` plutôt que
de lever `Not_found` sur un échec — c'est le distracteur le plus tentant,
puisque c'est la même fonction sans la sécurité de l'`option`. C oublie le
prédicat de recherche et cherche une valeur exacte, ce que fait plutôt
`List.mem` couplé à un `_opt` qui n'existe pas sous cette forme précise. D est
le type de `List.exists`, qui répond seulement « il y en a un » sans le
retourner.

</details>

---

**19.** Quel est le type de `List.iter` ?

- **A)** `('a -> 'b) -> 'a list -> 'b list`
- **B)** `unit -> 'a list -> unit`
- **C)** `('a -> unit) -> 'a list -> 'a list`
- **D)** `('a -> unit) -> 'a list -> unit`

<details>
<summary>Réponse</summary>

**D.** *Concept : une fonction qui parcourt pour l'effet de bord, pas pour la valeur.*

`List.iter` sert à exécuter une action (typiquement `print_...`) sur chaque
élément ; son retour est `unit`, car aucune valeur n'est construite. A est le
type de `List.map`, qui construit une nouvelle liste — la confusion la plus
fréquente entre les deux. C ferait comme si `iter` retournait quand même la
liste parcourue, un mélange des deux fonctions. B oublie que le paramètre
fonction doit recevoir un élément de la liste, pas rien du tout.

</details>

---

**20.** Quel est le type de `List.sort` ?

- **A)** `'a list -> 'a list`
- **B)** `('a -> 'a -> int) -> 'a list -> 'a list`
- **C)** `('a -> 'a -> bool) -> 'a list -> 'a list`
- **D)** `('a -> 'b -> int) -> 'a list -> 'b list`

<details>
<summary>Réponse</summary>

**B.** *Concept : une fonction de comparaison retourne un `int` de signe, pas un `bool`.*

`List.sort` attend une fonction de comparaison à trois issues — négatif, nul,
positif — comme `compare`, donc un retour `int`, pas un simple `bool` (C),
qui ne distinguerait que « avant » de « pas avant » sans dire quoi faire des
égaux. A oublierait complètement le critère de tri, comme si un seul ordre
existait pour tout type. D mélange deux types d'éléments différents dans la
comparaison, ce que n'importe quel tri en place interdit.

</details>

---

**21.** Quel est le type de `List.exists` ?

- **A)** `('a -> bool) -> 'a list -> bool`
- **B)** `('a -> bool) -> 'a list -> 'a option`
- **C)** `'a -> 'a list -> bool`
- **D)** `('a -> bool) -> 'a list -> 'a`

<details>
<summary>Réponse</summary>

**A.** *Concept : type exact d'un prédicat d'existence sur une liste.*

`List.exists p l` répond seulement s'il existe un élément satisfaisant `p`,
d'où le `bool` final — B est le type de `List.find_opt`, qui en plus retourne
l'élément trouvé. C est le type de `List.mem`, qui teste une égalité directe
avec une valeur donnée plutôt qu'un prédicat. D voudrait retourner l'élément
sans jamais permettre l'échec, ce que `List.exists` ne fait pas — c'est plutôt
le type d'une version totale et dangereuse de `List.find`.

</details>

---

**22.** Quel est le type de `List.mem` ?

- **A)** `('a -> bool) -> 'a list -> bool`
- **B)** `'a list -> 'a -> bool`
- **C)** `'a -> 'a list -> bool`
- **D)** `'a -> 'a list -> 'a option`

<details>
<summary>Réponse</summary>

**C.** *Concept : `mem` teste une égalité, pas un prédicat quelconque.*

`List.mem x l` compare `x` structurellement à chaque élément de `l` — pas
besoin de fonction, juste une valeur à chercher, ce qui élimine A, type de
`List.exists`. B inverse l'ordre des deux arguments, la même inattention que
sur `List.assoc`. D imite `List.find_opt` en renvoyant la valeur trouvée, alors
que `mem` ne renvoie qu'un `bool` : on sait déjà ce qu'on cherche.

</details>

---

**23.** Quel est le type de `List.nth` ?

- **A)** `int -> 'a list -> 'a`
- **D)** `'a list -> int -> 'a list`
- **C)** `'a list -> int -> 'a option`
- **B)** `'a list -> int -> 'a`

<details>
<summary>Réponse</summary>

**D.** *Concept : ordre des arguments d'un accès indexé, malgré son coût linéaire.*

`List.nth l i` prend la liste d'abord, l'indice ensuite ; c'est aussi une
fonction **partielle** (elle lève une exception si l'indice dépasse), donc
sans `option` — ce qui élimine C. A inverse l'ordre des paramètres. B
confondrait un accès à un seul élément avec une extraction de sous-liste,
un rôle que ne joue pas `List.nth`.

</details>

---

**24.** Quel est le type de `let pipe x f = f x` ?

- **A)** `'a -> ('a -> 'b) -> 'b`
- **B)** `('a -> 'b) -> 'a -> 'b`
- **C)** `'a -> ('b -> 'a) -> 'b`
- **D)** `'a -> ('a -> 'a) -> 'a`

<details>
<summary>Réponse</summary>

**A.** *Concept : type fonctionnel d'un opérateur de type « tube », proche de `( |> )` de la bibliothèque standard.*

`x` peut être de n'importe quel type `'a` ; `f` doit l'accepter et rendre un
`'b` indépendant. B est le type de `( @@ )`, l'application classique dans
l'autre ordre — une fonction voisine, pas celle-ci : ici c'est `x` qui vient
en premier. C ferait comme si `f` retournait le type de `x` en entrée plutôt
que de le consommer. D force entrée et sortie de `f` au même type, une
contrainte absente du code.

</details>

---

**25.** Un correcteur demande : « pourquoi le type de `fun x y -> x + y` n'est-il pas `'a -> 'a -> 'a` ? ». Quelle réponse un correcteur accepte-t-il ?

- **A)** Parce qu'OCaml refuse de généraliser une fonction à deux paramètres.
- **B)** Parce que le corps de la fonction contient un appel de fonction, ce qui empêche toute généralisation.
- **C)** Parce que la fonction n'est pas une valeur syntaxique, donc sujette à la restriction aux valeurs.
- **D)** Parce que `+` contraint ses deux opérandes et son résultat à `int`, ce qui élimine toute variable de type libre.

<details>
<summary>Réponse</summary>

**D.** *Concept : unification des contraintes imposées par les opérateurs de base.*

`+` n'existe en OCaml que sur `int -> int -> int` (pas de surcharge implicite
comme en Java), donc `x` et `y` sont tous deux forcés à `int`, et le résultat
aussi. A décrit une limitation qui n'existe pas : les fonctions à plusieurs
paramètres se généralisent très bien quand rien ne les contraint (voir
`compose`, `flip`). C invoque la restriction aux valeurs hors de propos : une
définition `fun x y -> ...` est justement une valeur syntaxique, donc
pleinement généralisable — le problème ici est uniquement l'usage de `+`. B
confond présence d'un appel de fonction dans le corps avec absence de valeur
syntaxique pour la fonction elle-même : ce sont deux choses différentes.

</details>

---

**26.** Quel est le type de `let annotated : int -> int = fun x -> x + 1` ?

- **A)** `'a -> 'a`
- **D)** `'a -> int`
- **C)** `int -> int -> int`
- **B)** `int -> int`

<details>
<summary>Réponse</summary>

**D.** *Concept : une annotation de type restreint l'inférence sans rien changer au comportement.*

L'annotation `int -> int` coïncide avec ce que l'inférence aurait trouvé seule
via `+`, donc elle ne fait que confirmer — la fonction se comporte
normalement. A ignorerait l'annotation et redériverait un type générique, ce
qu'aucune annotation cohérente ne permet. C ajoute une flèche fantôme, comme
si la fonction prenait deux arguments. B laisse le paramètre polymorphe malgré
l'annotation explicite, une contradiction directe avec l'énoncé du type.

</details>

---

**27.** Le professeur demande : « `let f x = if x then 1 else 0` a quel type ? ». Quel est-il ?

- **A)** `'a -> int`
- **B)** `bool -> 'a`
- **C)** `bool -> int`
- **D)** `int -> int`

<details>
<summary>Réponse</summary>

**C.** *Concept : le test d'un `if` doit être de type `bool`, sans coercition.*

La condition d'un `if` est nécessairement un `bool` en OCaml (contrairement à
C ou JavaScript, où un entier ou une chaîne peuvent servir de condition), donc
`x : bool` est fixé, et les deux branches, `1` et `0`, fixent le retour à
`int`. A laisserait `x` polymorphe, comme si un `if` acceptait n'importe quel
type de test façon « valeur truthy ». B oublierait de contraindre les
branches. D confondrait le paramètre avec le résultat, une erreur d'assemblage
de la flèche.

</details>

---

**28.** Quel est le type de `List.filter` ?

- **A)** `('a -> bool) -> 'a list -> 'a list`
- **B)** `('a -> 'a) -> 'a list -> 'a list`
- **C)** `('a -> bool) -> 'a list -> bool list`
- **D)** `'a list -> ('a -> bool) -> 'a list`

<details>
<summary>Réponse</summary>

**A.** *Concept : type exact d'une fonction d'ordre supérieur qui sélectionne sans transformer.*

`List.filter` garde les éléments qui satisfont le prédicat, inchangés : la
liste d'entrée et de sortie ont le même type d'élément, `'a`. B est le type
d'une transformation façon `List.map` avec une fonction totale sur `'a`, pas
un test. C ferait comme si `filter` retournait le résultat du test pour
chaque élément plutôt que l'élément lui-même — c'est plutôt le rôle d'un
`List.map` couplé au prédicat. D inverse simplement l'ordre des deux
arguments.

</details>

---

**29.** Quel est le type de `List.rev_map` ?

- **A)** `('a -> 'b) -> 'a list -> 'b list`
- **B)** `'a list -> 'a list`
- **C)** `('a -> 'a) -> 'a list -> 'a list`
- **D)** `('a -> 'b) -> 'a list -> 'a list`

<details>
<summary>Réponse</summary>

**A.** *Concept : `rev_map` a le même type que `map`, seul l'ordre du résultat change.*

`List.rev_map f l` est équivalent à `List.rev (List.map f l)` mais en une
seule passe ; le type ne dépend en rien de l'ordre final, donc c'est
exactement le type de `List.map`. B oublierait complètement le paramètre
fonction. C, comme au numéro 28, contraindrait `f` à ne jamais changer de
type, une restriction absente de la signature réelle. D mélange le type de
retour de `f` avec celui des éléments d'entrée.

</details>

---

**30.** Quel est le type de `let empty_list = List.map (fun x -> x) []` ?

- **A)** `'a list`
- **B)** `unit list`
- **C)** `Error: cannot infer the type of []`
- **D)** `'_weak1 list`

<details>
<summary>Réponse</summary>

**A.** *Concept : la restriction relâchée aux valeurs généralise les variables de type covariantes.*

C'est le contre-exemple qui empêche de retenir « toute application donne une
variable faible ». La règle réelle d'OCaml est la restriction **relâchée** :
une variable de type qui n'apparaît qu'en position **covariante** — ici le
paramètre de `'a list`, qui ne fait que sortir — est généralisée malgré
l'application. Vérifié :

```ocaml
# let e = List.map (fun x -> x) [];;
val e : 'a list = []
```

D est le piège, et c'est la réponse correcte pour deux cas voisins où la
variable n'est *pas* covariante : `ref []` la place en position invariante, et
`id id` la place dans un type fonctionnel, donc contravariante.

```ocaml
# let r = ref [];;
val r : '_weak1 list ref = {contents = []}
# let g = (fun x -> x) (fun x -> x);;
val g : '_weak2 -> '_weak2 = <fun>
```

B invente un type par défaut qui n'existe pas en OCaml. C imagine une erreur là
où l'inférence n'a aucune difficulté.

</details>

---
