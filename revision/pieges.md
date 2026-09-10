# Les réflexes à désapprendre

Guide de révision pour les trois examens d'INF6120. Il s'adresse à des
programmeurs qui arrivent d'un langage impératif et objet — Java, C#,
TypeScript, PHP — et recense les endroits où ces habitudes-là produisent, en
OCaml, une réponse plausible et fausse.

Toutes les sorties d'interpréteur citées ici ont été exécutées sur **OCaml
5.5.1**, la version exigée par le cours. Le drill est dans [`qcm.md`](qcm.md).

| Examen | Poids | Portée |
|--------|-------|--------|
| Examen 1 | 33 % | OCaml seul |
| Examen 2 | 33 % | OCaml + Prolog |
| Final | 34 % | toute la matière |

Format annoncé : **choix de réponse multiple**, avec un peu de rédaction. C'est
à la fois une bonne nouvelle et un piège. La bonne nouvelle : aucun code
compilable à produire sous pression. Le piège : en QCM les quatre choix se
ressemblent, et le mauvais choix est presque toujours *la réponse correcte dans
un autre langage*. C'est là qu'une longue pratique de l'impératif joue contre
soi.

Les sections sont ordonnées par fréquence dans les examens antérieurs du même
professeur — 36 questions dépouillées ; la mention « poids » indique combien en
dépendaient.

1. [Dériver un type à la main](#1--dériver-un-type-à-la-main) — 5/36
2. [Fonctions curryfiées](#2--fonctions-curryfiées) — 9/36
3. [Égalité, nombres, immuabilité](#3--égalité-nombres-immuabilité) — 4/36
4. [Types somme et filtrage](#4--types-somme-et-filtrage) — 9/36
5. [Récursion au lieu de boucles](#5--récursion-au-lieu-de-boucles) — 9/36
6. [Listes et coût réel](#6--listes-et-coût-réel) — 4/36
7. [Théorie qui tombe en QCM](#7--théorie-qui-tombe-en-qcm) — 2/36
8. [Prolog : unification et résolution](#8--prolog--unification-et-résolution) — 8/36
9. [Comment réviser d'ici l'examen](#9--comment-réviser-dici-lexamen)

---

## 1 — Dériver un type à la main

> Poids : 5 questions sur 36 · « Donner, en le justifiant soigneusement, le type de… »

C'est le type de question le plus rentable à maîtriser, parce qu'il est
mécanique : il existe une procédure, et elle donne toujours la bonne réponse.
En QCM, la justification n'a même pas à être rédigée — il suffit de dérouler la
procédure assez vite pour éliminer trois choix.

| Réflexe impératif | Ce que fait OCaml |
|---|---|
| Le type est ce qui a été *déclaré*. `List<String>` est un contrat écrit à la main, que le compilateur se contente de vérifier. | Le type est ce que le compilateur *déduit* de l'usage. Rien n'est déclaré ; il collecte des contraintes et les résout. Le type le plus général compatible gagne. |

### La procédure

1. Donner une variable de type fraîche à chaque paramètre : `'a`, `'b`, `'c`.
2. Lire le corps et noter une contrainte par usage. `x + 1` force `x : int` ;
   `x ^ "a"` force `string` ; `x :: l` force `l : 'a list` où `'a` est le type
   de `x`.
3. Un `if` force ses deux branches au même type. Un `match` aussi, sur toutes
   ses branches.
4. Aucune contrainte sur une variable ? Elle reste polymorphe. C'est une
   réponse, pas un échec.
5. Assembler de gauche à droite : `arg1 -> arg2 -> résultat`. La flèche est
   associative **à droite**.

Appliquée à `let rec d x = d x` : le paramètre reçoit `'a` ; le corps est un
appel à `d`, donc aucune valeur concrète ne contraint le retour, qui reste
`'b`, distinct de `'a`.

```ocaml
# let rec d x = d x;;
val d : 'a -> 'b = <fun>
```

Un type `'a -> 'b` est la signature d'une fonction qui ne retourne jamais —
elle boucle ou elle lève une exception. Le typage ne cherche pas à savoir si le
code termine : c'est *indécidable*, et c'est le lien direct avec le chapitre sur
les machines de Turing.

### Piège de QCM — la restriction aux valeurs

La fonction identité est polymorphe. Le résultat de *l'appliquer* ne l'est pas :

```ocaml
# let id x = x;;
val id : 'a -> 'a = <fun>
# (fun x -> x) (fun x -> x);;
- : '_weak1 -> '_weak1 = <fun>
```

`'_weak1` est une variable de type **faible** : pas encore fixée, mais elle le
sera au premier usage, et définitivement. OCaml ne généralise que les *valeurs
syntaxiques* — un `fun`, une constante — jamais le résultat d'une application.
Le choix `'a -> 'a` figurera dans le QCM, et il est faux.

### Polymorphisme n'est pas généricité

Le `'a` d'OCaml ressemble au `<T>` de Java, mais il n'y a ni effacement de type,
ni `instanceof`, ni `Object` en dessous. Une fonction de type `'a list -> int`
ne peut rien faire des éléments : elle ne peut que les compter ou les déplacer.
D'où une famille de questions — « laquelle de ces fonctions peut avoir le type
`'a list -> 'a list` ? » — dont la réponse est : celles qui ne regardent jamais
un élément.

```ocaml
# List.map;;
- : ('a -> 'b) -> 'a list -> 'b list = <fun>
# List.fold_left;;
- : ('acc -> 'a -> 'acc) -> 'acc -> 'a list -> 'acc = <fun>
```

---

## 2 — Fonctions curryfiées

> Poids : 9 questions sur 36 (avec l'écriture de fonctions) · applications partielles, ordre supérieur

| Réflexe impératif | Ce que fait OCaml |
|---|---|
| Une méthode prend *n* paramètres d'un coup. `add(1)` quand la signature en demande deux est une erreur de compilation. | Une fonction prend **toujours un seul** argument et retourne une fonction. `add 1` est une valeur parfaitement légale, de type `int -> int`. |

```ocaml
# let add x y = x + y;;
val add : int -> int -> int = <fun>
# add 10;;
- : int -> int = <fun>
# (+) 1;;
- : int -> int = <fun>
```

`int -> int -> int` se lit `int -> (int -> int)`. Les parenthèses ne sont jamais
dans l'énoncé, mais elles sont dans le sens.

### Piège de QCM — la version non curryfiée

Le distracteur classique est `int * int -> int`. C'est un type valide, mais
celui d'une *autre* fonction : `let add (x, y) = x + y`, qui prend un seul
argument, un couple. Deux fonctions distinctes, deux types distincts, et le QCM
propose les deux.

Même piège sur `fun x y -> x`, dont le type est `'a -> 'b -> 'a`. Le choix
`'a -> 'a -> 'a` est faux (rien ne force les deux paramètres au même type) et
`'a * 'b -> 'a` est faux (ce n'est pas la même fonction).

### Portée statique : ce que la fermeture capture

Question fréquente, et l'intuition acquise ailleurs est bonne *à condition* de
se rappeler qu'il n'existe aucune affectation :

```ocaml
# let x = 2 in let f y = x * y in let x = 10 in f 3;;
- : int = 6
```

`f` capture le `x` visible à sa **définition**, donc 2. Le `let x = 10` ne
modifie rien : il crée une nouvelle liaison qui *masque* l'ancienne pour la
suite. Le choix `30` est la réponse en portée dynamique — un mécanisme que
presque aucun langage moderne n'utilise, et c'est précisément pour ça qu'il est
proposé.

---

## 3 — Égalité, nombres, immuabilité

> Poids : 4 questions sur 36 · « donner l'affichage exact que produit l'interpréteur »

Section à surveiller de près : la convention y est **inversée** par rapport à
celle de la famille C / Java / JavaScript.

| Opérateur | En Java / JS | En OCaml |
|---|---|---|
| `=` | affectation | **égalité structurelle** — l'équivalent de `equals` |
| `==` | égalité (de référence pour les objets) | **identité physique** — même case mémoire |
| `<>` | — | différence structurelle |
| `!=` | différence | différence physique |
| `:=` | — | affectation dans une référence *(proscrit par le guide de style du cours)* |

```ocaml
# [1] == [1];;
- : bool = false
# [1] = [1];;
- : bool = true
```

Deux listes construites séparément ont le même contenu à deux emplacements
distincts : `=` compare le contenu, `==` compare l'emplacement. En pratique `==`
ne sert jamais — le guide de style du cours l'interdit — mais le QCM le montrera.

### Piège de QCM — aucune conversion numérique implicite

```ocaml
# 1 = 1.0;;
Error: The constant 1.0 has type float but an expression was
       expected of type int
# 1 / 0;;
Exception: Division_by_zero.
# max_int;;
- : int = 4611686018427387903
```

Trois surprises. Les opérateurs entiers (`+ - * /`) et flottants (`+. -. *. /.`)
sont distincts et ne se mélangent pas ; la conversion est explicite
(`float_of_int`). La division entière par zéro lève une exception au lieu de
rendre `Infinity`. Et `max_int` n'est ni 2³¹−1 ni 2⁶³−1 : l'entier OCaml occupe
**63 bits**, un bit servant à distinguer les entiers des pointeurs à l'exécution.

### Immuabilité : la mise à jour qui n'en est pas une

```ocaml
# type point = { x : int; y : int };;
type point = { x : int; y : int; }
# let p = { x = 1; y = 2 };;
val p : point = {x = 1; y = 2}
# { p with x = 9 };;
- : point = {x = 9; y = 2}
# p;;
- : point = {x = 1; y = 2}
```

`{ p with x = 9 }` construit un *nouveau* point ; `p` est intact. C'est la
**transparence référentielle** : une expression peut être remplacée par sa
valeur sans changer le sens du programme. Un `p.setX(9)` détruit cette
propriété, et c'est le cœur de la différence entre les deux paradigmes — une
question de définition là-dessus est à prévoir.

---

## 4 — Types somme et filtrage

> Poids : compté dans les 9 questions « écrire une fonction » · plus une question de définition somme / produit

| Réflexe impératif | Ce que fait OCaml |
|---|---|
| Plusieurs formes d'une même chose ⇒ une classe abstraite et des sous-classes, ou une union discriminée à la main. Le traitement se disperse dans les sous-classes. | Un **type somme** énumère les formes en trois lignes, et le `match` les traite en un seul endroit. Le compilateur avertit s'il en manque une. |

Le vocabulaire de l'examen : un type **produit** combine (un couple, un
enregistrement — « un *et* un »), un type **somme** choisit (« un *ou* un »).
`int * string` est un produit ; `Rouge | Vert` est une somme. Ce sont les
analogues respectifs de la classe à champs et de l'`enum` — sauf qu'un
constructeur de somme peut porter des données, ce qu'un `enum` Java fait mal.

### Piège de QCM — le cas manquant

On montre une fonction et on demande quel cas n'est pas couvert.
L'avertissement du compilateur fournit toujours un contre-exemple :

```ocaml
# let g = function [] -> 0 | [x] -> x;;
Warning 8 [partial-match]: this pattern-matching is not exhaustive.
  Here is an example of a case that is not matched: x::_::_
val g : int list -> int = <fun>
```

`x::_::_` se lit « au moins deux éléments ». Le motif manquant s'écrit de tête
dès qu'on retient les trois formes d'une liste : `[]`, `[x]` (soit `x :: []`) et
`x :: y :: reste`.

### L'ordre structurel des constructeurs

```ocaml
# type couleur = Rouge | Vert;;
type couleur = Rouge | Vert
# Rouge < Vert;;
- : bool = true
```

La comparaison polymorphe ordonne les constructeurs par leur ordre de
*déclaration*. Utile à savoir en QCM, dangereux dans du vrai code.

`option` mérite une mention à part : `None | Some of 'a` est la réponse d'OCaml
au `null`. La différence tient à ce que le type *force* le traitement du cas
absent — impossible de déréférencer un `None` par accident.

---

## 5 — Récursion au lieu de boucles

> Poids : la majeure partie des 9 questions « écrire une fonction » · récursion terminale explicitement au programme

Le guide de style du cours proscrit `for`, `while`, `ref`, `:=` et `array`. Ce
n'est pas du purisme : ces constructions existent bien en OCaml, mais s'en
servir revient à écrire de l'impératif avec une autre syntaxe. Tout ce qui se
faisait en boucle se fait en récursion, et la traduction est mécanique.

| Construction impérative | Équivalent OCaml |
|---|---|
| `for` qui accumule dans une variable | récursion avec un paramètre accumulateur, ou `List.fold_left` |
| `for` qui transforme chaque élément | `List.map` |
| `for` avec un `if` qui garde certains éléments | `List.filter` |
| `break` dès qu'on trouve | `List.find_opt` — ou le filtrage, qui s'arrête tout seul |
| variable mutable modifiée dans la boucle | paramètre passé à l'appel récursif suivant |

### Terminale ou non : savoir la reconnaître

Une fonction est **récursive terminale** si l'appel récursif est la *dernière*
opération — rien ne reste à faire au retour. Le compilateur la transforme alors
en boucle, à pile constante.

```ocaml
(* PAS terminale : au retour, il reste le + à faire *)
let rec somme l = match l with
  | [] -> 0
  | x :: r -> x + somme r

(* terminale : l'appel est la dernière chose qui arrive *)
let rec somme_t acc l = match l with
  | [] -> acc
  | x :: r -> somme_t (acc + x) r
```

Le test à appliquer en QCM : *que reste-t-il à faire après l'appel récursif ?*
S'il reste un `+`, un `::`, un appel englobant, ce n'est pas terminal. Attention
au faux ami `x :: aux r`, qui n'est **pas** terminal alors qu'il en a l'air : la
cellule se construit après le retour.

**Nuance à ne pas surinterpréter.** Sur OCaml 5, la pile grandit dynamiquement :
`somme` avale une liste d'un million d'éléments sans broncher (vérifié). La
question d'examen porte sur la *propriété* — cette fonction est-elle terminale ?
— pas sur le déclenchement d'un `Stack_overflow`. La bonne formulation n'est
donc pas « ça plante », mais « la pile croît linéairement en la longueur de la
liste ».

---

## 6 — Listes et coût réel

> Poids : présent dans les questions de complexité et d'affichage

| Réflexe impératif | Ce que fait OCaml |
|---|---|
| Une `ArrayList` ou un tableau associatif : accès indexé en temps constant, ajout en fin peu coûteux, taille connue d'avance. | Une liste est une **liste simplement chaînée immuable**. Accès indexé linéaire, ajout en tête constant, ajout en fin linéaire. |

| Opération | Coût | Pourquoi |
|---|---|---|
| `x :: l` | O(1) | une cellule allouée qui pointe sur `l` ; `l` est partagée, pas copiée |
| `l1 @ l2` | O(\|l1\|) | recopie toute la liste de gauche ; celle de droite est partagée |
| `List.length l` | O(n) | la longueur n'est stockée nulle part, il faut parcourir |
| `List.nth l i` | O(i) | pas d'accès indexé, on suit les maillons |
| `List.rev l` | O(n) | une seule passe, terminale |

**Le piège qui coûte des points partout.** Accumuler avec `acc @ [x]` dans une
récursion donne du **O(n²)** : à chaque tour, tout l'accumulateur est recopié.
L'idiome attendu est d'accumuler en tête avec `x :: acc`, puis de faire un seul
`List.rev` à la fin — O(n).

Dernier détail : `List.hd` et `List.tl` sont des **fonctions partielles** —
elles lèvent une exception sur la liste vide, et le guide de style du cours les
proscrit. Le filtrage, lui, force à traiter le cas `[]`.

---

## 7 — Théorie qui tombe en QCM

> Poids : 2 questions sur 36 en rédaction, mais un QCM en pose facilement plus — ce sont des questions bon marché à fabriquer

Environ 20 % des notes de cours ne portent ni sur OCaml ni sur Prolog :
calculabilité, paradigmes, typage. Ce sont des points faciles en QCM, parce que
les réponses sont des définitions.

| Notion | La formulation à retenir |
|---|---|
| Transparence référentielle | Remplacer une expression par sa valeur ne change pas le sens du programme. Cassée par toute affectation ou tout effet secondaire. |
| Fonction pure | Même entrée ⇒ même sortie, aucun effet observable. `print_endline` n'est pas pure ; son type de retour `unit` le trahit. |
| Machine de Turing | Modèle de calcul de référence. « Turing-complet » = capable de calculer tout ce qu'elle calcule. OCaml et Prolog le sont tous les deux. |
| Problème de l'arrêt | **Indécidable** : aucun programme ne peut décider, pour tout programme et toute entrée, s'il termine. D'où le fait que le typage ne s'en occupe pas. |
| Typage statique / dynamique | Statique = vérifié avant l'exécution (OCaml, Java). Dynamique = à l'exécution (PHP, JavaScript). |
| Typage fort / faible | Axe orthogonal au précédent. OCaml est fortement typé : aucune conversion implicite. PHP est faiblement typé — `"1" + 1` y passe. |
| Inférence de types | Le compilateur déduit les types sans annotation. Statique *et* sans déclarations : la combinaison que Java n'a pas. |

### Stratégies d'évaluation

- **Par valeur** — les arguments sont évalués avant l'appel. C'est OCaml, c'est
  Java, c'est le cas familier.
- **Par nom** — l'argument est substitué non évalué, et réévalué à chaque usage.
- **Par nécessité** (paresseuse) — évalué au premier usage, puis mémorisé. C'est
  Haskell ; en OCaml, c'est le module `Lazy`.

La question typique donne une expression dont un argument boucle ou lève une
exception, et demande le comportement selon la stratégie. Le point à retenir :
par valeur, un argument non utilisé est quand même évalué — donc le programme
plante ; par nom ou par nécessité, non.

---

## 8 — Prolog : unification et résolution

> Poids : 8 questions sur 36 · examen 2 et final seulement · 115 des 481 pages de notes

Prolog n'est pas un langage fonctionnel un peu plus bizarre : c'est un autre
paradigme. On ne décrit pas *comment* calculer, on déclare des faits et des
règles, et le moteur cherche. Le renversement mental à faire : **une variable
n'est pas une case mémoire, c'est une inconnue à résoudre**, comme dans une
équation.

| Réflexe impératif | Ce que fait Prolog |
|---|---|
| `X = 3` met 3 dans X. Une fonction a des entrées et une sortie, décidées à l'écriture. | `X = 3` *unifie* X avec 3 : il cherche une substitution qui rend les deux termes identiques. Un prédicat n'a ni entrées ni sorties — `somme_liste(L, R)` s'interroge dans les deux sens. |

### Unification : la mécanique

Unifier deux termes, c'est trouver la substitution la plus générale qui les rend
égaux. Trois règles suffisent :

1. Deux atomes ou nombres s'unifient s'ils sont identiques. `c` et `c` : oui.
   `c` et `d` : échec.
2. Une variable s'unifie avec n'importe quoi, et se lie à ce terme.
3. Deux termes composés s'unifient si le foncteur et l'arité coïncident, et si
   les arguments s'unifient deux à deux, de gauche à droite.

**Piège de QCM — la variable liée reste liée.** Unifier `b(X, c)` et `b(c, Y)` :
même foncteur, même arité, on descend. Premier argument : `X` avec `c` ⇒
`X = c`. Deuxième : `c` avec `Y` ⇒ `Y = c`. Réussite, substitution
`{X = c, Y = c}`.

Maintenant `b(X, X)` et `b(c, d)` : `X = c`, puis il faut unifier `c` — X est
déjà lié — avec `d` ⇒ **échec**. Une variable répétée dans un terme impose
l'égalité de ses positions. C'est le distracteur le plus courant.

### Arbre de résolution

Le moteur explore en **profondeur d'abord**, en essayant les clauses *dans
l'ordre du programme*, de haut en bas. Sur échec, il *revient en arrière* au
dernier point de choix. Trois conséquences pour l'examen :

- L'**ordre des solutions** est déterminé par l'ordre des clauses. Une question
  qui demande « donner les solutions » demande implicitement de les donner dans
  le bon ordre.
- Réordonner deux clauses peut transformer un programme qui termine en programme
  qui boucle, sans rien changer à sa signification logique.
- Le cas de base se place *avant* la règle récursive, sinon la recherche part en
  profondeur infinie.

### Listes et arithmétique

La notation `[T|Q]` est le `x :: reste` d'OCaml : tête et queue. Le patron
récursif est identique — un cas pour `[]`, un pour `[T|Q]`.

```prolog
:- use_module(library(clpfd)).

somme_liste([], 0).
somme_liste([T|Q], R) :- somme_liste(Q, R1), R #= T + R1.
```

**Attention à l'opérateur employé.** Le recueil du cours n'utilise `is` nulle
part dans ses 115 pages de programmation logique : l'arithmétique y passe par
les naturels de Peano, puis par la bibliothèque de contraintes `clpfd` et ses
opérateurs `#=`, `#\=`, `#<`, `#>`, `#>=` et `#=<` — cette dernière notation
étant inhabituelle, le recueil le souligne lui-même. `is` est bien l'opérateur
arithmétique standard d'ISO Prolog, mais ce n'est pas celui de ce cours.

Le piège de QCM porte donc sur `#=` contre `=`, et il est plus profond que la
simple évaluation :

- `=` est l'unification pure. `X = 1 + 2` lie X au **terme** `1+2`, non calculé.
- `#=` pose une **contrainte** d'égalité arithmétique, et une contrainte
  fonctionne dans les deux sens. Vérifié sur SWI-Prolog 10.0.2 avec la
  définition ci-dessus : `somme_liste([1,2,3], R)` donne `R = 6`, et la requête
  inverse fonctionne aussi — en bornant le domaine et en énumérant, les listes
  de deux éléments de somme 6 sortent toutes :

  ```prolog
  ?- length(L, 2), L ins 0..6, somme_liste(L, 6), label(L).
  L = [0,6] ; L = [1,5] ; L = [2,4] ; L = [3,3] ;
  L = [4,2] ; L = [5,1] ; L = [6,0].
  ```

  Le détail qui compte : sans domaine borné ni `label/1`, la contrainte reste
  posée mais non résolue en valeurs. Une contrainte n'est pas un calcul.

C'est là toute la différence avec un `is`, qui exige que son membre droit soit
entièrement instancié et ne calcule donc que dans un seul sens. Un distracteur
qui affirme que l'arithmétique Prolog impose un sens de calcul est exactement le
genre de choix plausible et faux qu'un QCM propose.

Dernier point au programme : la **négation par échec**. `\+ But` réussit si
Prolog *n'arrive pas* à prouver `But`. Ce n'est pas la négation logique, mais une
hypothèse de monde clos : ce qui n'est pas démontrable est déclaré faux.

---

## 9 — Comment réviser d'ici l'examen

> Trois examens · aucun travail noté ne compte · 100 % de la note se joue là

Pour quelqu'un qui programme depuis des années, la syntaxe et l'outillage ne
coûteront rien ; ce sont les réflexes impératifs installés de longue date qui
produisent, en QCM, des réponses plausibles et fausses. Réviser efficacement ne
consiste donc pas à relire les notes, mais à **faire remonter ces réflexes à la
surface pour les corriger un par un**.

1. **Le toplevel est un correcteur automatique.** Pour toute question « quel
   type ? » ou « quel affichage ? », `utop` donne la réponse exacte,
   gratuitement. Prédire d'abord, vérifier ensuite — l'inverse n'apprend rien.
2. **Tenir un journal d'erreurs** ([`erreurs.md`](erreurs.md)). Une ligne par
   concept manqué, jamais par question. Trois entrées sur la restriction aux
   valeurs, et le sujet à relire est identifié.
3. **Écrire du code même si l'examen est un QCM.** Reconnaître un `fold` correct
   parmi quatre suppose de savoir en écrire un. Les ateliers du jeudi servent
   exactement à ça.
4. **Traduire plutôt que mémoriser.** Pour chaque construction OCaml apprise,
   noter son équivalent impératif et surtout *l'endroit où l'équivalence casse*.
   La cassure est la question d'examen.
5. **Prolog demande son propre temps.** 24 % des notes et 8 des 36 questions
   antérieures, sur un paradigme qui ne ressemble à rien de familier. À ne pas
   laisser pour la fin de session.
6. **Refaire le drill à froid.** Une semaine plus tard, sans relire. Ce qui est
   encore juste est acquis ; le reste n'était que de la mémoire à court terme.

Un mot sur les examens antérieurs mis en ligne par le professeur : ils sont à
développement, pas en QCM. Ils restent la meilleure mesure du **niveau de
difficulté** et de la *matière* visée. Le meilleur usage à en faire est d'en
convertir les questions en QCM soi-même, en se demandant pour chacune quels
trois faux choix un correcteur y mettrait. Fabriquer un distracteur est
l'exercice de révision le plus efficace qui existe : il faut connaître la bonne
réponse *et* comprendre l'erreur.

---

Sources : notes de cours de l'édition précédente (481 p.) et deux examens
antérieurs de l'automne 2024, dépouillés le 10 septembre 2026. Le guide de style
noté proscrit `for`, `while`, `ref`, `:=`, `array`, `==`, `!=` et les fonctions
partielles comme `List.hd` — `./style` mécanise la vérification.
