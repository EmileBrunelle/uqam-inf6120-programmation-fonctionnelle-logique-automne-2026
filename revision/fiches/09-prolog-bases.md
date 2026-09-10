# Prolog : bases du langage

> Recueil, chapitre 4, pages 367–420

Prolog n'a pas de fonctions : l'objet central est le **prédicat**, déclaré par
des faits et des règles, interrogé par des requêtes. Cette fiche couvre le
vocabulaire syntaxique de base — avant l'unification et la résolution
(couvertes dans `pieges.md`, section 8). Les sorties citées ont été vérifiées
sur SWI-Prolog 10.0.2 ; le vocabulaire arithmétique (`#=` plutôt que `is`)
suit le recueil (chapitre 4).

## Ce qu'il faut savoir dire

| Terme | Définition attendue |
|---|---|
| Fait | Une vérité déclarée comme telle, relative au contexte de travail. Un fait sans variable est une vérité concrète ; avec variables universelles, une vérité qui peut être instanciée. |
| Règle | Un fait soumis à des conditions : « si C alors F ». Un fait est le cas particulier d'une règle dont la condition est toujours vraie. |
| Requête | Une question posée relativement à un ensemble de faits et de règles. Sa résolution est affirmative si le système parvient à la démontrer, négative sinon (négation par l'échec). |
| Terme | Défini récursivement : soit une variable (commence par une majuscule ou `_`), soit un atome (commence par une minuscule) appliqué à une suite de termes entre parenthèses. |
| Atome | Un terme sans variable en tête ; peut être d'arité 0 (une constante, parenthèses omises) ou porter des arguments. |
| Foncteur et arité | Le foncteur est le nom de l'atome ; l'arité est le nombre de termes sur lesquels il s'applique. La paire se note `nom/arité` — deux atomes de même nom mais d'arité différente sont des atomes *différents*. |
| Clause | Assemblage syntaxique `t :- t1, ..., tn.` : `t` est la tête, `t1, ..., tn` (une conjonction) est le corps. Sans `:-`, `t.` est un fait. |
| Prédicat | Une suite de clauses dont la tête est formée du même atome (même foncteur, même arité). |
| Clause de Horn | Formule de la forme `(H1 ∧ H2 ∧ ... ∧ Hn) → C`, où les `Hi` et `C` sont des termes. Une clause Prolog `C :- H1, ..., Hn.` en est la traduction directe. |

## Syntaxe et sémantique

```prolog
pere(randy, stan).
pere(randy, shelly).
mere(sharon, stan).
fratrie(Y, Z) :- pere(X, Y), pere(X, Z).
```

- `pere/2` est un prédicat à deux clauses, toutes deux des faits.
- `fratrie/2` est une règle : `X`, `Y`, `Z` sont des variables universelles,
  `pere(X, Y), pere(X, Z)` est le corps — une conjonction de deux termes.
- La requête `?- fratrie(stan, shelly).` est affirmative : en posant
  `X = randy`, `Y = stan`, `Z = shelly`, la clause s'applique et les deux
  termes du corps sont vérifiés par les faits `pere/2`.
- Une requête avec variables, `?- pere(randy, X).`, ne demande pas un simple
  vrai/faux : elle cherche l'ensemble des spécialisations de `X` qui rendent
  la requête vraie — ici `X = stan` et `X = shelly`.

### Le sens déclaratif d'un prédicat

Un prédicat ne décrit pas un calcul à dérouler dans un ordre fixé : il décrit
une **relation** entre ses arguments, vraie ou fausse selon leur valeur. Rien
dans l'écriture d'un prédicat ne désigne un argument comme entrée et un autre
comme sortie — c'est l'exemple classique qui le montre le mieux :

```prolog
add(z, N, N) :- entier(N).
add(s(N1), N2, s(N3)) :- add(N1, N2, N3).
```

`add/3` est déclaré une fois. Il peut ensuite être utilisé « dans le sens du
calcul » — trouver la somme à partir des deux termes — mais tout aussi bien
« dans le sens inverse » — trouver toutes les décompositions d'un nombre en
somme de deux entiers, en laissant les deux premiers arguments non
instanciés :

```
?- entier_3(N), add(X1, X2, N).
N = X2, X2 = s(s(s(z))), X1 = z ;
N = s(s(s(z))), X1 = s(z), X2 = s(s(z)) ;
N = s(s(s(z))), X1 = s(s(z)), X2 = s(z) ;
N = X1, X1 = s(s(s(z))), X2 = z ;
false.
```

Le même prédicat, sans être réécrit, répond à deux questions différentes
selon quels arguments sont fournis. Aucun langage impératif ne fait cela sans
écrire deux fonctions distinctes.

### Contrainte contre unification : `#=` et non `is`

Le recueil (pages 367–420 et la section CLP qui suit) n'utilise jamais `is` —
zéro occurrence sur les 115 pages du chapitre. L'arithmétique concrète y est
construite d'abord sur les entiers de Peano (`z`, `s(N)`), puis, pour les
calculs efficaces, via `library(clpfd)` et ses opérateurs de **contrainte** :
`#=`, `#\=`, `#<`, `#>`, `#>=`, `#=<` (attention à `#=<`, noté dans un ordre
inhabituel). C'est ce vocabulaire, pas `is`, qui est celui du cours.

Le point conceptuel qui compte n'est pas « unifier contre évaluer », mais
**contrainte contre unification directionnelle** : une contrainte `#=` reste
posée et se résout dans n'importe quel sens dès que suffisamment
d'arguments sont connus, alors que `is` (l'opérateur standard ISO, absent du
cours) exige que son membre droit soit entièrement instancié *avant*
l'appel — aucun retour en arrière possible.

```prolog
:- use_module(library(clpfd)).
somme_liste([], 0).
somme_liste([T|Q], R) :- somme_liste(Q, R1), R #= T + R1.
```

Vérifié sur SWI-Prolog 10.0.2 : `somme_liste([1,2,3], R)` calcule
`R = 6`. Dans l'autre sens, en fixant un domaine fini et en énumérant
(`length(L,2), L ins 0..6, somme_liste(L,6), label(L)`), les sept solutions
`[0,6], [1,5], [2,4], [3,3], [4,2], [5,1], [6,0]` sont trouvées — la
contrainte `#=` fonctionne dans les deux sens tant que les variables ont un
domaine fini à énumérer (`label/1`) ; sans domaine borné, `label/1` échoue par
manque d'instanciation. `is` n'offre pas cette réversibilité : un membre droit
non instancié comme `1 + Y` avec `Y` libre lève directement une
`instantiation_error`.

### Les opérateurs de comparaison

| Opérateur | Rôle |
|---|---|
| `=` | unification structurelle |
| `\=` | échec de l'unification (négation de `=`) |
| `==` | identité syntaxique stricte, sans tenter d'unifier (deux variables distinctes non liées ne sont jamais `==`) |
| `#=` | contrainte d'égalité arithmétique (clpfd, style du cours) — bidirectionnelle |
| `#\=`, `#<`, `#>`, `#>=`, `#=<` | contraintes de différence et de comparaison arithmétique (clpfd) |
| `is` | évaluation arithmétique unidirectionnelle et unification du résultat — opérateur standard ISO, **absent du recueil** |
| `=:=` | égalité arithmétique après évaluation des deux côtés (ISO, non clpfd) |

## Ce qui diffère de l'impératif

| Réflexe impératif | Ce que fait Prolog |
|---|---|
| Une fonction a des paramètres d'entrée fixés et une valeur de sortie décidée à l'écriture de la signature. | Un prédicat décrit une relation ; aucun argument n'est intrinsèquement une entrée ou une sortie — cela dépend de ce qui est instancié dans la requête. |
| `X = 3` affecte 3 à la variable X, qui peut ensuite être réaffectée. | `X = 3` unifie X avec 3. Une fois liée dans une résolution donnée, une variable ne change plus — il n'existe pas d'affectation destructive. |
| `=` est un test d'égalité de valeurs déjà calculées (comme `==` en Java sur des primitifs). | `=` déclenche l'unification, qui peut *construire* une liaison plutôt que seulement la vérifier. |
| Un calcul arithmétique se lit dans un seul sens : entrées connues → sortie déduite. | Une contrainte `#=` (clpfd, style du cours) reste posée et se résout dans n'importe quel sens dès que le domaine des variables est assez restreint pour énumérer. |

## Pièges de QCM

- **Distracteur : `X = 1 + 2` lie `X` à `3`.**
  Plausible parce que dans presque tout langage impératif, `=` évalue le
  membre de droite avant d'affecter. Faux : `=` unifie sans évaluer ; `X` est
  liée au terme composé `1+2` (foncteur `+`, arité 2), pas à l'entier `3`.
  Seul un opérateur d'évaluation (`is` en ISO, absent du cours ; `#=` en
  clpfd) produit `3`.

- **Distracteur : `#=` se comporte comme `is`, en plus moderne.**
  Plausible parce que les deux calculent des sommes et donnent la même
  réponse dans le sens direct — `somme_liste([1,2,3], R)` donne `R = 6` avec
  l'un comme avec l'autre (vérifié sur SWI-Prolog 10.0.2). Faux : `is` exige
  que son membre droit soit entièrement instancié, sans quoi il lève une
  `instantiation_error` ; `#=` pose une *contrainte*, qui reste valide même
  membres partiellement inconnus et se résout dans les deux sens — la requête
  inverse `somme_liste(L, 6)` avec un domaine borné et `label/1` énumère les
  sept décompositions `[0,6], [1,5], ..., [6,0]`, ce qu'aucun `is` ne permet.

- **Distracteur : `pere/2` et `pere/1` seraient le même prédicat s'ils
  portaient un jour le même nom dans le même fichier.**
  Plausible parce qu'en programmation impérative la surcharge par arité
  n'existe pas toujours et le nom seul identifie souvent la fonction. Faux :
  en Prolog, le nom **et** l'arité forment ensemble l'identité de l'atome —
  `pere/1` et `pere/2` sont deux atomes distincts, chacun avec ses propres
  clauses, exactement comme `moins/1` et `moins/2` dans le recueil.

- **Distracteur : un fait est un cas particulier de règle, donc syntaxiquement
  différent d'une clause.**
  Plausible parce que le recueil les présente sur deux lignes séparées
  (« si C alors F » contre une vérité brute). Faux : les deux sont des
  clauses au sens strict — un fait est simplement une clause `t.` sans corps
  (`:- true` implicite), une règle une clause `t :- t1, ..., tn.` avec corps
  non vide.

- **Distracteur : une requête avec variables demande une seule réponse
  vrai/faux, comme un `if` classique.**
  Plausible parce qu'une requête *sans* variable se résout bien en vrai ou
  faux. Faux : dès qu'une requête contient une variable, la résolution
  cherche l'*ensemble* de ses solutions — toutes les spécialisations qui la
  rendent vraie, énumérées une à une avec `;`.

## À retenir par cœur

- Foncteur + arité = identité d'un atome, notée `nom/arité` ; changer l'arité
  change l'atome.
- Une clause = tête `:-` corps (conjonction) ; un fait est une clause à corps
  vide ; un prédicat regroupe toutes les clauses de même tête.
- `=` unifie sans évaluer ; le cours calcule avec `#=` (clpfd), pas `is` —
  zéro occurrence de `is` dans les 115 pages du chapitre.
- `#=` est une contrainte bidirectionnelle (marche dans les deux sens si le
  domaine est borné) ; `is` (ISO, hors cours) exige un membre droit instancié.
- Un prédicat n'a pas d'entrée ni de sortie fixées : le même `add/3` calcule
  une somme ou énumère des décompositions, selon les arguments instanciés.
- Une clause de Horn `(H1 ∧ ... ∧ Hn) → C` est la forme logique dont une
  clause Prolog `C :- H1, ..., Hn.` est la syntaxe.
- Une requête avec variables cherche un ensemble de solutions, pas une seule
  réponse booléenne.
