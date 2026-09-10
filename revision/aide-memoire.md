# Aide-mémoire — INF6120

> Distillat de `fiches/`, `pieges.md` et `README.md`. Pas de contenu nouveau —
> voir ces fichiers pour les justifications et les sorties complètes vérifiées
> sur OCaml 5.5.1 / SWI-Prolog 10.0.2.

## Sommaire

- [Inférence de types](#inférence-de-types)
- [Types de base](#types-de-base)
- [Curryfication et ordre supérieur](#curryfication-et-ordre-supérieur)
- [Bibliothèque standard : `List`](#bibliothèque-standard--list)
- [Types produit / somme](#types-produit--somme)
- [Filtrage de motifs](#filtrage-de-motifs)
- [Récursion terminale](#récursion-terminale)
- [Coût des listes](#coût-des-listes)
- [Évaluation et pureté](#évaluation-et-pureté)
- [Modules et séquences](#modules-et-séquences)
- [Théorie et paradigmes](#théorie-et-paradigmes)
- [Prolog : bases](#prolog--bases)
- [Prolog : unification](#prolog--unification)
- [Prolog : résolution SLD](#prolog--résolution-sld)
- [Prolog : listes et CLP](#prolog--listes-et-clp)
- [Pièges, un par ligne](#pièges-un-par-ligne)
- [Guide de style — interdits](#guide-de-style--interdits)
- [D'un dev Java vers OCaml](#dun-dev-java-vers-ocaml)
- [OCaml vs Prolog : ne pas les mélanger](#ocaml-vs-prolog--ne-pas-les-mélanger)
- [D'un dev Java vers Prolog](#dun-dev-java-vers-prolog)

---

## Inférence de types

| Notion | Point clé |
|---|---|
| `let ID = EXP` | déclaration, pas de valeur |
| `let ID = EXP1 in EXP2` | expression, valeur = celle de `EXP2` |
| Ombrage | masque, ne modifie jamais une liaison existante |
| `and` | toutes les expressions de droite évaluées dans le contexte *avant* le `let` (pas séquentiel) |
| Vérification | statique (à la compilation) |
| Attribution | hybride : annotations facultatives, inférence sinon |
| Restriction aux valeurs | seule une valeur syntaxique (`fun`, constante) est généralisée ; le résultat d'une application reste à type faible `'_weak1` |

Procédure d'inférence : 1) variable de type fraîche par paramètre → 2) une
contrainte par usage → 3) `if`/`match` forcent leurs branches au même type →
4) sans contrainte, le paramètre reste `'a` → 5) assembler `t1 -> t2 -> ... -> t`
(`->` associe à **droite**).

```ocaml
# let rec d x = d x;;
val d : 'a -> 'b = <fun>
# let pair x y = (x, y);;
val pair : 'a -> 'b -> 'a * 'b = <fun>
# (fun x -> x) (fun x -> x);;
- : '_weak1 -> '_weak1 = <fun>
```

## Types de base

| Type | Contenu |
|---|---|
| `int` | 63 bits utiles (1 bit pour le GC) ; `max_int = 4611686018427387903` |
| `float` | toujours avec un point (`0.`, `4.52`) |
| `char` | `'a'`, `'\101'` |
| `string` | concaténation par `^` |
| `bool` | `true` / `false` |
| `unit` | valeur unique `()` |

Aucune conversion numérique implicite : `int`/`float` ne se mélangent jamais
(`float_of_int`, `int_of_float`). `1 / 0` lève `Division_by_zero`.
`if COND then EXP` (sans `else`) exige `EXP : unit`.

## Curryfication et ordre supérieur

Toute fonction OCaml est unaire : `t1 -> t2 -> t` se lit `t1 -> (t2 -> t)`.
Application partielle (`k < n` arguments) → une fonction, jamais une erreur.

```ocaml
# let add x y = x + y;;
val add : int -> int -> int = <fun>
# add 10;;
- : int -> int = <fun>
```

| Outil | Signature |
|---|---|
| `Fun.flip` | `('a -> 'b -> 'c) -> 'b -> 'a -> 'c` — inverse les 2 premiers arguments |
| `(\|>)` | `'a -> ('a -> 'b) -> 'b` — `e \|> f` ≡ `f e` |
| `compose f1 f2` | `fun x -> f1 (f2 x)`, type `('a -> 'b) -> ('c -> 'a) -> 'c -> 'b` |

Fermeture : capture la valeur visible à la **définition**, jamais à l'appel
(portée statique).

```ocaml
# let x = 2 in let f y = x * y in let x = 10 in f 3;;
- : int = 6   (* pas 30 *)
```

## Bibliothèque standard : `List`

Types exacts (OCaml 5.5.1) :

| Fonction | Signature |
|---|---|
| `List.map` | `('a -> 'b) -> 'a list -> 'b list` |
| `List.filter` | `('a -> bool) -> 'a list -> 'a list` |
| `List.fold_left` | `('acc -> 'a -> 'acc) -> 'acc -> 'a list -> 'acc` (récursif **terminal**) |
| `List.fold_right` | `('a -> 'acc -> 'acc) -> 'a list -> 'acc -> 'acc` (**non** terminal) |
| `List.mem` | `'a -> 'a list -> bool` |
| `List.exists` / `List.for_all` | `('a -> bool) -> 'a list -> bool` |
| `List.length` | `'a list -> int` |
| `List.rev` | `'a list -> 'a list` |
| `List.init` | `int -> (int -> 'a) -> 'a list` |
| `List.find_opt` | `('a -> bool) -> 'a list -> 'a option` |
| `compare`, `(=)` | `'a -> 'a -> int`, `'a -> 'a -> bool` |

```ocaml
# List.fold_left (fun acc x -> acc - x) 0 [1; 2; 3];;
- : int = -6      (* ((0-1)-2)-3 *)
# List.fold_right (fun x acc -> x - acc) [1; 2; 3] 0;;
- : int = 2       (* 1-(2-(3-0)) *)
```

`fold_left` : `acc` avant l'élément, ordre gauche→droite, terminal — préférer
dès que l'ordre n'importe pas. `fold_right` : `acc` après, nécessaire quand
l'ordre du calcul doit suivre celui de la liste.

Traduction boucle → fonctionnel :

| Boucle impérative | Équivalent |
|---|---|
| accumule dans une variable | accumulateur récursif, ou `fold_left` |
| transforme chaque élément | `List.map` |
| garde certains éléments | `List.filter` |
| `break` dès trouvé | `List.find_opt` |

## Types produit / somme

| Notion | Définition |
|---|---|
| Produit | « et » — couple, n-uplet (`*`), enregistrement (`{ }`) |
| Somme | « ou » — constructeurs (`\|`), avec/sans argument |
| `option` | `type 'a option = None \| Some of 'a` |

```ocaml
# type point = { x : int; y : int };;
# let p = { x = 1; y = 2 };;
# { p with x = 9 };;
- : point = {x = 9; y = 2}
# p;;
- : point = {x = 1; y = 2}      (* p intact : transparence référentielle *)
```

- `*` **non associatif** : `(T1*T2)*T3 ≠ T1*(T2*T3)`.
- Comparaison polymorphe (`<`, `compare`) suit l'ordre de **déclaration** des constructeurs, jamais l'alphabet. `None` avant `Some` dans `option`.
- Type récursif : `type 'a arbre = Feuille | Noeud of 'a arbre * 'a * 'a arbre`.
- Alias (`type paire = int * string`) : ne crée pas de type distinct.

## Filtrage de motifs

`match EXP with | M1 -> E1 | ... -> ...` : premier motif qui filtre, de haut
en bas.

```ocaml
# let g = function [] -> 0 | [x] -> x;;
Warning 8 [partial-match]: this pattern-matching is not exhaustive.
  Here is an example of a case that is not matched: x::_::_
```

- `Warning 8` : filtrage non exhaustif, contre-exemple concret fourni.
- `Warning 11` : motif redondant (un joker `_` placé avant absorbe tout).
- Garde : `MOTIF when TEST -> EXP` (`TEST : bool`).
- `let rec f ... and g ... = ...` : sans `and`, `g` n'est pas visible dans `f`.

## Récursion terminale

Test : *que reste-t-il à faire après l'appel récursif ?* Rien ⇒ terminal ;
un `+`, un `::`, un appel englobant ⇒ non terminal.

```ocaml
(* non terminale : le + reste à faire au retour *)
let rec somme l = match l with [] -> 0 | x :: r -> x + somme r
(* terminale : rien après l'appel *)
let rec somme_t acc l = match l with [] -> acc | x :: r -> somme_t (acc + x) r
```

Piège : `x :: aux r` **n'est pas** terminal — la cellule se construit après
le retour, même situation que `x + somme r`.

Accumulateur : paramètre qui porte le résultat partiel ; on l'initialise à la
valeur du cas de base en enrobant la fonction publique.

Induction structurelle : cas de base (constructeurs d'arité 0) + cas
d'hérédité (propriété sur les sous-éléments ⇒ propriété sur le tout).

## Coût des listes

Liste = **liste simplement chaînée immuable** (`'a list` ≡
`Vide | Cellule of 'a * 'a liste`).

| Opération | Coût | Pourquoi |
|---|---|---|
| `x :: l` | Θ(1) | une cellule allouée, `l` partagée |
| `List.hd`, `List.tl` | Θ(1) | mais **fonctions partielles**, proscrites |
| `List.length` | Θ(n) | longueur jamais stockée |
| `List.nth l i` | Θ(i) | pas d'accès indexé |
| `List.rev` | Θ(n) | une passe, terminale |
| `l1 @ l2` | Θ(\|l1\|) | recopie `l1` ; `l2` partagée |

**Piège coûteux** : `acc @ [x]` en boucle récursive = Θ(n²) (recopie
grandissante). Idiome correct : `x :: acc`, puis un seul `List.rev` final —
Θ(n).

`string` n'est **pas** `'a list` : `List.length "abc"` échoue au typage. Pour
parcourir : `String.length`, `String.get` (`.[i]`), ou
`List.init (String.length s) (String.get s)`.

## Évaluation et pureté

| Stratégie | Principe |
|---|---|
| Par valeur | tous les arguments évalués **avant** l'appel (OCaml par défaut) |
| Par nom | argument substitué non évalué, réévalué à chaque usage |
| Par nécessité | par nom + mémorisation (Haskell par défaut ; OCaml : module `Lazy`) |

```ocaml
# let l = lazy (print_endline "calcul"; 42);;
# Lazy.force l;;
calcul
- : int = 42
# Lazy.force l;;
- : int = 42        (* pas réimprimé : mémorisé *)
```

- Transparence référentielle : remplacer une expression par sa valeur ne change jamais le sens du programme.
- Fonction pure : même entrée ⇒ même sortie, aucun effet observable (`unit` en retour = souvent un indice d'impureté).
- Par nom/nécessité seulement : un argument non utilisé n'est jamais évalué (une exception ou boucle infinie dedans ne se déclenche pas).

## Modules et séquences

- Chaque fichier `.ml` **est** un module (`A.ml` → module `A`), sans déclaration. Accès : `A.x` ou `open A`.
- `unit` : type à une valeur `()`, marque un effet secondaire.
- `E1; E2` : `E1 : unit` obligatoire, valeur du tout = celle de `E2`. **Séquence moins prioritaire que `if`** : `if C then f x; g x` exécute `g x` dans tous les cas — utiliser `begin ... end` pour grouper sous le `then`.
- `dune build` compile, `dune exec NAME` exécute, `dune utop` ouvre l'interpréteur avec les modules du projet en `PROJECT.MODULE.`.

## Théorie et paradigmes

| Paradigme | Base théorique |
|---|---|
| Impératif | machine de Turing |
| Fonctionnel | λ-calcul (variable, application, abstraction `λx. f`) |
| Logique | faits, règles, requêtes — pas de notion fixe d'entrée/sortie |

Deux axes **indépendants** du typage :

| | Fort | Faible |
|---|---|---|
| Statique | OCaml, Java | C (conversions implicites de pointeurs) |
| Dynamique | Python | PHP, JavaScript |

- Attribution : explicite (Church) / implicite-inférée (Curry) / hybride (OCaml).
- Portée statique (position dans le texte) vs dynamique (contexte d'exécution) — quasi tous les langages modernes sont statiques.
- Turing-complet = capable de simuler toute machine de Turing (question d'expressivité, pas de vitesse).
- Problème de l'arrêt : **indécidable** en général — une preuve de terminaison d'un programme *particulier* reste possible.
- « Non typé » ≠ « typage dynamique » : les types existent, vérifiés à l'exécution.

## Prolog : bases

| Terme | Définition |
|---|---|
| Fait | vérité déclarée, `t.` (clause à corps vide) |
| Règle | `t :- t1, ..., tn.` (corps = conjonction) |
| Terme | variable (majuscule/`_`) ou atome appliqué à des termes |
| Foncteur/arité | identité d'un atome = `nom/arité` ; `pere/1` ≠ `pere/2` |
| Prédicat | ensemble des clauses de même tête (même foncteur, arité) |
| Clause de Horn | `(H1 ∧ ... ∧ Hn) → C`, traduite `C :- H1, ..., Hn.` |

Un prédicat décrit une **relation**, sans entrée/sortie fixée :
`add(X1, X2, N)` calcule une somme ou énumère des décompositions selon ce qui
est instancié.

**`#=` et non `is`** — le cours (0 occurrence de `is` en 115 pages) utilise
les naturels de Peano puis `clpfd` : `#=`, `#\=`, `#<`, `#>`, `#>=`, `#=<`.
Une contrainte `#=` reste posée et se résout dans les deux sens si le domaine
est assez restreint pour énumérer (`label/1`) ; `is` (ISO, hors cours) exige
son membre droit entièrement instancié.

| Opérateur | Rôle |
|---|---|
| `=` | unification structurelle |
| `\=` | échec de l'unification |
| `==` | identité syntaxique stricte |
| `#=`, `#\=`, `#<`, `#>`, `#>=`, `#=<` | contraintes clpfd, bidirectionnelles |
| `is` | évaluation ISO unidirectionnelle — **absent du cours** |
| `=:=` | égalité arithmétique ISO après évaluation (non clpfd) |

## Prolog : unification

Algorithme (3 cas) : 1) atomes/nombres identiques → ok ; 2) variable ↔
n'importe quel terme, **sauf** s'il la contient (*occur check*, enseigné par
le cours) ; 3) termes composés : même foncteur/arité + arguments unifiés
deux à deux, substitution propagée.

```prolog
?- a(X, a(Z, Z)) = a(Y, Y).
X = Y, Y = a(Z, Z).
?- a(X, Y) = b(X, Y).
false.
```

(vérifié : `a(X, a(Z,Z)) = a(Y,Y)` donne bien `X = Y, Y = a(Z,Z)` ;
`a(X,Y) = b(X,Y)` échoue — foncteurs différents.)

- Échec si : foncteurs/arités différents à la racine, ou variable à unifier avec un terme qui la contient.
- **SWI-Prolog n'applique pas l'occur check par défaut** : `X1 = b(_, X1)` réussit (terme cyclique) — le cours l'impose, donc à l'examen c'est un échec. `unify_with_occurs_check/2` retrouve ce comportement.

## Prolog : résolution SLD

Essaie les clauses **dans l'ordre du programme**, profondeur d'abord ;
remplace le sous-but par le corps substitué ; retour arrière au dernier
point de choix sur échec ou après une solution.

Conséquences :
- Ordre des solutions = ordre des clauses.
- Réordonner deux clauses peut transformer une terminaison en boucle infinie (sans changer la sémantique logique) — placer le sous-but le plus contraignant en premier, cas de base avant la règle récursive.
- Négation par échec `\+ But` : réussit ssi `But` n'a aucune solution (hypothèse du monde clos, pas négation logique) ; fiable seulement sur termes déjà instanciés — `X = b, \+ p(X)` ≠ `\+ p(X), X = b`.
- `!` (coupure, hors recueil/ISO) : élimine les points de choix ouverts depuis l'entrée dans la clause.

## Prolog : listes et CLP

```prolog
[T | Q]                 % tête T, queue Q — comme x :: reste en OCaml
membre(X, [X | _]).
membre(X, [_ | L]) :- membre(X, L).
concatenation([], L, L).
concatenation([X|L1], L2, [X|L3]) :- concatenation(L1, L2, L3).
```

`membre/2` ≡ `member/2`, `concatenation/3` ≡ `append/3` (prédéfinis).
`length/2` prédéfini.

CLP (`:- use_module(library(clpfd))`) :

| Outil | Rôle |
|---|---|
| `X in A..B` | borne une variable |
| `L ins A..B` | borne toutes les variables d'une liste |
| `all_distinct(L)` | force des valeurs distinctes |
| `label(L)` | force la recherche des valeurs concrètes |
| `findall(V, But, R)` | collecte toutes les solutions dans une liste |

```prolog
fact(0, 1).
fact(N, F) :- N #> 0, N1 #= N - 1, F #= N * F1, fact(N1, F1).
```

`fact(7, X)` → `X = 5040` ; `fact(X, 720)` → `X = 6` (sens inverse,
impossible avec `is`).

## Pièges, un par ligne

| Réflexe faux | Réalité |
|---|---|
| `(fun x -> x) (fun x -> x) : 'a -> 'a` | résultat d'une application ⇒ restriction aux valeurs ⇒ `'_weak1 -> '_weak1` |
| `let add x y = ...` a le type `int * int -> int` | curryfié : `int -> int -> int` ; `int * int -> int` est celui de `add (x,y)` |
| fermeture verrait le `x` du contexte d'appel (30) | portée statique : capture le `x` de la **définition** (6) |
| `List.fold_left`/`fold_right` donnent le même résultat avec le même opérateur/graine | faux dès que l'opérateur n'est pas associatif-commutatif : `-6` vs `2` sur `[1;2;3]` |
| `Rouge < Vert` compare alphabétiquement | ordre = position de **déclaration** des constructeurs |
| `{ p with x = 9 }` modifie `p` | construit un **nouvel** enregistrement ; `p` intact |
| `x :: aux r` est terminal (dernier appel visible) | non terminal : la cellule se construit **après** le retour |
| `acc @ [x]` en boucle ≈ `x :: acc` | `@` recopie tout `acc` ⇒ Θ(n²) contre Θ(n) |
| `List.hd`/`List.tl` renvoient une valeur par défaut sur `[]` | fonctions **partielles**, lèvent `Failure` — proscrites |
| une chaîne se traite avec `List.map`/`filter` | `string ≠ 'a list` ; passer par `String.*` |
| `1 = 1.0` vaut `true`/`false` | ne type-check pas du tout (`int` ≠ `float`) |
| non typé = typage dynamique | les types existent, vérifiés à l'exécution |
| argument non utilisé toujours évalué, peu importe la stratégie | vrai seulement par valeur ; par nom/nécessité, jamais évalué s'il est inutilisé |
| `Lazy.force` réexécute à chaque appel | mémorise au premier appel, ne réévalue plus |
| `X = 1 + 2` lie `X` à `3` | unifie `X` au **terme** `1+2` non évalué ; il faut `#=` (ou `is`, hors cours) |
| `#=` se comporte comme `is` | `#=` est une contrainte bidirectionnelle ; `is` exige son membre droit instancié |
| réordonner deux clauses Prolog ne change rien d'observable | peut transformer une terminaison en boucle infinie |
| `b(X,X) = b(c,d)` réussit avec `X ↦ c, X ↦ d` | `X` répétée impose la même valeur des deux côtés ⇒ échec (`c ≠ d`) |
| `\+ p(X)` avant d'instancier `X` équivalent à l'instancier avant | ordre compte : `\+` n'est fiable que sur termes déjà liés |

## Guide de style — interdits

Proscrits (mécanisés par `./style`), sauf mention explicite « proscrit » en
exemple de piège : `for`, `while`, `ref`, `:=`, `array`, `==`, `!=`, et les
fonctions partielles (`List.hd`, `List.tl`, `List.nth`). Toujours annoter les
types des fonctions principales ; zéro warning à la compilation.

## D'un dev Java vers OCaml

| Concept Java | Équivalent OCaml | La nuance qui mord |
|---|---|---|
| `final` partout | immuabilité par défaut | pas d'effort à faire ; `ref`/`:=` sont l'exception proscrite, pas la règle |
| `null` | `'a option` (`None` / `Some x`) | `NullPointerException` impossible ; le filtrage force à traiter `None` |
| Surcharge de méthodes | absente | l'inférence de types choisit un seul type par nom ; deux fonctions de même nom se masquent (ombrage), ne coexistent pas |
| `interface` / hiérarchie de classes | type somme + filtrage de motifs | fermé et vérifié à la compilation : `match` exhaustif remplace le `instanceof` en cascade |
| Generics `<T>` | `'a`, `'b`, ... | inférés, jamais déclarés explicitement dans la signature |
| `switch` (avec `default` par prudence) | `match` | exhaustivité vérifiée par le compilateur (`Warning 8`) ; pas de `default` nécessaire ni de `break` |
| `equals()` / `==` | `=` / `==` | `=` compare la **structure** (équivalent d'`equals`) ; `==` compare l'**identité physique** — et `==` est proscrit par le guide de style du cours |
| Boucle `for` / `while` | récursion ou `List.fold_left` | `for`/`while` proscrits ; l'accumulateur remplace la variable de boucle mutable |
| Exceptions (`try`/`catch`) | `try ... with` | même idée, non détaillée ici — voir les fiches existantes |

Le pivot : **les Streams**.

| Java (`Stream<T>`) | OCaml (`'a list`) | Nuance |
|---|---|---|
| `.stream().map(f)` | `List.map f` | identique dans l'esprit |
| `.filter(p)` | `List.filter p` | identique |
| `.reduce(init, op)` | `List.fold_left op init` | `reduce` cache l'accumulateur ; `fold_left` l'expose comme premier argument explicite |
| `.collect(Collectors.toList())` | rien | une liste OCaml est déjà une collection concrète, pas un pipeline à matérialiser |
| `.anyMatch(p)` / `.allMatch(p)` | `List.exists p` / `List.for_all p` | identique |
| `.findFirst()` | `List.find_opt p` | renvoie `'a option`, pas un `Optional<T>` qu'il faut encore déballer différemment |
| `Optional<T>` | `'a option` | même rôle ; `Some`/`None` se filtrent avec `match`, pas de `.get()` risqué |

```ocaml
# List.map (fun x -> x * 2) [1; 2; 3];;
- : int list = [2; 4; 6]
# List.filter (fun x -> x mod 2 = 0) [1; 2; 3; 4];;
- : int list = [2; 4]
# List.fold_left (fun acc x -> acc + x) 0 [1; 2; 3];;
- : int = 6
# List.find_opt (fun x -> x > 1) [1; 2; 3];;
- : int option = Some 2
# let a = [1; 2] and b = [1; 2] in a = b;;
- : bool = true
# let a = [1; 2] and b = [1; 2] in a == b;;
- : bool = false      (* deux listes distinctes en mémoire, mêmes éléments *)
```

Un Stream Java est **paresseux et à usage unique** (un deuxième `.forEach` sur
le même stream lève une exception) ; une liste OCaml est **stricte et
réutilisable** à volonté, sans pipeline à relancer.

Le cours commence par le versant impératif : boucles et effets secondaires.

| Java (impératif) | OCaml | Nuance |
|---|---|---|
| `for (int i = 0; i < n; i++)` avec compteur | `List.init n f`, ou récursion terminale avec accumulateur | le compteur devient un paramètre de la fonction récursive, jamais une variable mutée |
| `for (T x : liste)` pour un effet secondaire | `List.iter f liste` | `f` rend `unit` ; rien n'est construit |
| `for (T x : liste)` pour construire | `List.map f liste` | construit une nouvelle liste, ne mute rien |
| `while (cond sur état mutable)` | récursion terminale, l'état passe en paramètre | condition d'arrêt = motif de base (souvent `0` ou `[]`) |
| accumulation dans une variable locale mutable | paramètre accumulateur, ou `List.fold_left` | même rôle, porté par un argument plutôt qu'une case mémoire réécrite |

```ocaml
# let rec somme_jusqua n acc = if n = 0 then acc else somme_jusqua (n - 1) (acc + n);;
val somme_jusqua : int -> int -> int = <fun>
# somme_jusqua 5 0;;
- : int = 15
# List.init 5 (fun i -> i * i);;
- : int list = [0; 1; 4; 9; 16]
```

La nuance de fond : en Java, la boucle produit son résultat en **mutant**
quelque chose (le compteur, l'accumulateur, la collection). En OCaml, la
valeur est **retournée**, l'état est **passé en paramètre** — rien n'est
réécrit en place. Une fonction sans effet secondaire rend le même résultat
pour les mêmes arguments : elle est testable isolément et remplaçable par sa
valeur (transparence référentielle).

`System.out.println` renvoie `void` ; `print_endline` renvoie `unit`. La
différence n'est pas cosmétique : `unit` est une **vraie valeur** (`()`),
pas un trou dans le système de types — une fonction qui la renvoie peut
quand même être passée à `List.map` ou stockée.

```ocaml
# print_endline "test";;
test
- : unit = ()
```

`for`, `while`, `ref` et `:=` restent le point de **départ** Java à traduire
ici, jamais une solution OCaml — le guide de style du cours les proscrit.

## OCaml vs Prolog : ne pas les mélanger

| | OCaml | Prolog |
|---|---|---|
| `=` | liaison (`let`) puis, en expression, égalité **structurelle** | **unification** bidirectionnelle : instancie les variables des deux côtés pour rendre les termes identiques |
| Variable | liaison immuable, minuscule, portée lexicale | variable logique, **majuscule** initiale, instanciable une seule fois par branche de résolution |
| Décomposition de liste | `x :: reste` (motif de filtrage) | `[T \| Q]` (unification de terme) — même idée, syntaxe et mécanisme différents |
| Ce qui répond | une fonction retourne **une** valeur | un prédicat **réussit ou échoue**, et peut fournir **plusieurs** solutions par retour arrière (`;`, `findall/3`) |
| Ordre d'évaluation | strict par défaut, argument avant appel | résolution SLD : clauses dans l'ordre du texte, profondeur d'abord, retour arrière au dernier point de choix |
| Types | déclarés ou inférés, vérifiés statiquement | **aucun type déclaré** ; un terme s'unifie avec n'importe quel autre compatible |
| `_` | motif joker, ignore la valeur, même rôle qu'en Prolog | variable anonyme, jamais liée nulle part, jamais réutilisée pour la même valeur |
| Arithmétique | `+`, `-`, ... évalués immédiatement | `#=`, `#\=`, `#<`, ... (clpfd) posent une **contrainte**, résolue dans les deux sens ; `is` (ISO) est hors cours |

```ocaml
# match [1; 2; 3] with x :: reste -> (x, reste) | [] -> (0, []);;
- : int * int list = (1, [2; 3])
```

```prolog
?- findall(X, member(X, [1,2,3]), R).
R = [1, 2, 3].
?- 2 + 3 #= Y.
Y = 5.
```

(vérifié : `member/2` énumère les trois éléments par retour arrière, capturés
ici par `findall/3` ; `2 + 3 #= Y` résout la contrainte clpfd et lie `Y`.)

Le piège le plus fréquent : lire un `X = ...` de Prolog comme une affectation
OCaml. `X = 1 + 2` ne calcule rien — il unifie `X` au terme non évalué `1+2`
(voir la section Prolog : bases pour `#=` vs `is`).

## D'un dev Java vers Prolog

Le saut le plus violent des trois : plusieurs notions Java n'ont tout
simplement **pas d'équivalent**, plutôt qu'un équivalent à traduire terme à
terme.

| Réflexe Java | Ce qui existe en Prolog à la place |
|---|---|
| Appeler une méthode et récupérer **une** valeur de retour | poser un but qui **réussit ou échoue**, et peut donner **plusieurs** solutions par retour arrière |
| Paramètres d'entrée séparés de la valeur de sortie | un prédicat est une **relation** : les mêmes arguments servent d'entrée ou de sortie selon ce qui est instancié |
| Affectation `x = 5`, réaffectable | **unification** : une variable logique s'instancie **une seule fois** par branche de résolution, jamais réaffectée |
| `if / else` | plusieurs clauses essayées **dans l'ordre**, plus le retour arrière si la suite échoue |
| Boucle sur une collection | récursion sur la structure de la liste, `[T\|R]` |
| `null` | aucun équivalent : un but **échoue**, il ne renvoie rien |
| Typage statique (`int`, generics, ...) | aucun type déclaré ; un terme s'unifie avec tout terme compatible |
| Surcharge de méthodes | un prédicat est identifié par **nom et arité** : `concatenation/3` et une éventuelle `concatenation/2` seraient deux prédicats distincts |
| Arithmétique évaluée (`+`) | `#=` (clpfd), contrainte posée et résolue dans les deux sens ; `is` (ISO) est hors cours |

La relation, pas la fonction — un seul prédicat, utilisable dans les deux
sens :

```prolog
concatenation([], L, L).
concatenation([X|L1], L2, [X|L3]) :- concatenation(L1, L2, L3).
```

```prolog
?- concatenation([1,2],[3,4],R).
R = [1, 2, 3, 4].
?- findall(A-B, concatenation(A,B,[1,2,3]), Decomps).
Decomps = [[]-[1, 2, 3], [1]-[2, 3], [1, 2]-[3], [1, 2, 3]-[]].
```

(vérifié : posé avec les deux premiers arguments instanciés, `concatenation/3`
calcule la concaténation ; posé avec le troisième seul, il énumère par retour
arrière les quatre façons de le décomposer — impossible avec une méthode Java
`concat(a, b)` qui ne fonctionne que dans un sens.)

Un prédicat Java équivalent n'existe pas : une méthode ne peut ni échouer au
sens logique, ni offrir plusieurs résultats pour un seul appel — elle
retourne une valeur, lève une exception, ou boucle.
