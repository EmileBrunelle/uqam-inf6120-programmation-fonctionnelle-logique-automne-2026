# Prolog : unification, résolution et listes

> Recueil, chapitre 4, pages 400–481

C'est le cœur du volet logique et la section la plus rentable à maîtriser :
les examens antérieurs du même professeur demandent explicitement de donner
le résultat d'une unification et de dessiner l'arbre de résolution complet
d'une requête, deux exercices mécaniques une fois la procédure connue par
cœur. Le reste de la matière — listes, arithmétique par contraintes — s'appuie
sur ce même moteur de résolution, appliqué aux mêmes deux idées : substituer
et reculer.

## Ce qu'il faut savoir dire

| Terme | Définition attendue |
|---|---|
| Unification | Trouver une substitution qui rend deux termes syntaxiquement identiques. Ce n'est pas une affectation : c'est la résolution d'une équation sur des termes dont les variables sont les inconnues. |
| Substitution | Une fonction des variables vers les termes ; notée `{X₁ ↦ t₁, ..., Xₙ ↦ tₙ}`. La substitution identité `ι` ne change rien. |
| Substitution la plus générale | Parmi toutes les substitutions qui unifient deux termes, celle qui impose le moins de contraintes — d'où toutes les autres s'obtiennent par composition. C'est celle que l'algorithme d'unification calcule. |
| Clause de Horn | `(H₁ ∧ ... ∧ Hₙ) → C`. Quand `n = 0`, c'est un fait : `C` est vraie inconditionnellement. |
| But (requête) | Une conjonction `q₁ ∧ ... ∧ qₙ` à résoudre : trouver les substitutions qui rendent chaque `qᵢ` vrai simultanément. |
| Résolution SLD | Résolution Linéaire Sélective de clauses Définies : l'algorithme qui essaie, dans l'ordre du programme, la première clause dont la tête s'unifie avec le premier sous-but, remplace le sous-but par le corps de la clause substitué, et recommence. |
| Retour arrière | Après un succès ou un échec, revenir au dernier point où une autre clause aurait pu être sélectionnée, et l'essayer. |
| Hypothèse du monde clos | Tout ce qui n'est pas démontrable à partir des clauses du programme est considéré comme faux — pas « inconnu », faux. |

## Syntaxe et sémantique

### Algorithme d'unification

Trois cas suffisent, appliqués récursivement sur la structure des termes :

1. Deux atomes ou nombres s'unifient s'ils sont identiques.
2. Une variable s'unifie avec n'importe quel terme et s'y lie — **sauf** si ce
   terme contient la variable elle-même (une variable répétée dans un couple
   à unifier impose l'égalité de ses deux positions).
3. Deux termes composés s'unifient si le foncteur et l'arité coïncident, et si
   les arguments s'unifient deux à deux, dans l'ordre, en propageant la
   substitution déjà trouvée à chaque étape suivante.

```
Fonction unifier(t1, t2)
    Si t1 et t2 sont tous deux la même variable X
        Renvoyer ι
    Sinon si (t1 est une variable qui apparaît dans t2) ou (t2 est une variable qui apparaît dans t1)
        Renvoyer Échec
    Sinon si t1 est une variable X
        Renvoyer {X ↦ t2}
    Sinon si t2 est une variable X
        Renvoyer {X ↦ t1}
    Sinon si les racines de t1 et t2 sont des atomes différents
        Renvoyer Échec
    Sinon
        σ := ι
        Pour chaque couple (s1, s2) de fils en mêmes positions de t1 et t2
            σ := unifier(s1 · σ, s2 · σ) ◦ σ
        Renvoyer σ
    Fin
Fin
```

Déroulé sur `t1 := a(e(X1), X1, X2)` et `t2 := a(X2, c, e(X3))` :

1. 1res positions : `unifier(e(X1), X2) = {X2 ↦ e(X1)}`.
2. 2es positions, sous la substitution courante : `unifier(X1, c) = {X1 ↦ c}`,
   composé donne `{X1 ↦ c, X2 ↦ e(c)}`.
3. 3es positions : `unifier(e(c), e(X3)) = {X3 ↦ c}`, composé donne
   `{X1 ↦ c, X2 ↦ e(c), X3 ↦ c}`.

Résultat : `{X1 ↦ c, X2 ↦ e(c), X3 ↦ c}`.

En Prolog, l'unification est demandée explicitement par `=` :

```prolog
?- a(X, Y) = a(X, t).
Y = t.
?- a(X, Y) = a(Y, t).
X = Y, Y = t.
?- a(X, Y) = b(X, Y).
false.
?- a(X, a(Z, Z)) = a(Y, Y).
X = Y, Y = a(Z, Z).
```

**Cas d'échec à reconnaître** : foncteurs ou arités différents à la racine
(`inf(z, s(X))` contre `inf(s(Y), Z)` — `z` et `s(X)` ont des racines
différentes), et — dans la sémantique **enseignée** par le recueil — la
variable qui se retrouve à unifier avec un terme qui la contient (l'*occur
check* : `X1` contre `b(X3, X1)` échoue, parce qu'il faudrait que `X1` désigne
un terme dont elle est elle-même une sous-partie).

**Écart vérifié avec SWI-Prolog 10.0.2** : par défaut, SWI-Prolog **n'applique
pas** l'occur check. `X1 = b(_, X1)` réussit et construit un terme cyclique
(un « arbre rationnel ») au lieu d'échouer :

```prolog
?- X1 = b(_, X1).
X1 = b(_A, X1).
```

C'est le recueil qui fait loi à l'examen — l'algorithme d'unification étudié
au cours **inclut** l'occur check et le cas ci-dessus doit être donné comme un
échec. Pour obtenir en pratique le comportement enseigné, SWI-Prolog offre
`unify_with_occurs_check/2`, qui échoue bien dans ce cas :

```prolog
?- unify_with_occurs_check(X1, b(_, X1)).
false.
```

L'écart entre les deux (`=` sans occur check par défaut contre l'algorithme
du cours qui l'impose) est en soi une question de QCM plausible.

### Résolution SLD, pas à pas

Programme :

```prolog
parent(marvin, randy).
parent(marvin, jimbo).
parent(randy, shelly).
parent(randy, stan).
grand_parent(X, Y) :- parent(X, Z), parent(Z, Y).
```

Requête : `?- grand_parent(marvin, X).`

1. Le but `grand_parent(marvin, X)` échoue à s'unifier avec les quatre
   premières clauses (des faits `parent/2`) ; il s'unifie avec la tête de la
   cinquième, `grand_parent(X1, Y1)` (variables renommées pour éviter toute
   collision), donnant `σ = {X1 ↦ marvin, Y1 ↦ X}`.
2. Le but courant devient le corps de la clause substitué :
   `parent(marvin, Z), parent(Z, X)`.
3. Le premier sous-but s'unifie avec le fait `parent(marvin, randy)`, donnant
   `σ' = {Z ↦ randy}`. But courant : `parent(randy, X)`.
4. Ce sous-but s'unifie avec `parent(randy, shelly)`, donnant `{X ↦ shelly}`.
   But vide : **succès**. Seules les variables du but initial sont
   rapportées : `X ↦ shelly`.
5. Retour arrière au dernier point de choix (l'étape 3) : `parent(randy, X)`
   s'unifie ensuite avec `parent(randy, stan)`, donnant une deuxième solution
   `X ↦ stan`.
6. Plus de clause à essayer : la recherche se termine.

### Arbre de résolution

Chaque nœud est un but courant ; chaque arête est étiquetée par la clause
sélectionnée et la substitution obtenue en unifiant le premier sous-but avec
sa tête. Un nœud `∅` (but vide) est un succès.

```
                              gp(m, X)
                                 |
              gp(X1,Y1) :- p(X1,Z1), p(Z1,Y1)
                    {X1 -> m, Y1 -> X}
                                 |
                       p(m, Z1), p(Z1, X)
                          /            \
              p(m,r) {Z1->r}      p(m,j) {Z1->j}
                    /                        \
              p(r, X)                    p(j, X)
              /       \
   p(r,sh){X->sh}  p(r,st){X->st}
        |               |
        ∅               ∅
     (X=sh)          (X=st)
```

(programme et abréviations : `gp` = `grand_parent`, `p` = `parent`, `m` =
`marvin`, `r` = `randy`, `j` = `jimbo`, `sh` = `shelly`, `st` = `stan` — repris
du recueil, pages 439–440). Deux solutions, dans l'ordre où l'arbre les
rencontre en profondeur d'abord, de gauche à droite : `X = shelly` puis
`X = stan`.

**Exemple original, pour s'entraîner à en dessiner un** — un programme à
quatre faits et une règle, vérifié à l'exécution (SWI-Prolog 10.0.2) :

```prolog
ami(alice, bob).
ami(alice, carl).
ami(bob, dora).
ami(carl, dora).
ami_ami(X, Z) :- ami(X, Y), ami(Y, Z).
```

Requête : `?- ami_ami(alice, Z).` — exécutée, elle donne bien
`Z = dora ; Z = dora ; false.` (deux dérivations distinctes vers la même
valeur).

```
                        ami_ami(alice, Z)
                               |
              ami_ami(X,Z) :- ami(X,Y), ami(Y,Z)
                        {X -> alice}
                               |
                      ami(alice, Y), ami(Y, Z)
                     /                        \
      ami(alice,bob). {Y->bob}        ami(alice,carl). {Y->carl}
              |                                    |
          ami(bob, Z)                        ami(carl, Z)
              |                                    |
  ami(bob,dora). {Z->dora}          ami(carl,dora). {Z->dora}
              |                                    |
              ∅  (Z = dora)                        ∅  (Z = dora)
```

Deux solutions, dans l'ordre où l'arbre les rencontre en profondeur d'abord,
de gauche à droite : la branche par `ami(alice, bob)` est explorée
entièrement — succès puis épuisement de ses propres points de choix — avant
que le retour arrière ne revienne au point de choix ouvert par
`ami(alice, Y)` et n'essaie `ami(alice, carl)`. C'est l'illustration directe
du principe du recueil (pages 441–443) : chaque branche est explorée
entièrement, dans l'ordre des clauses, avant le retour arrière vers la
branche suivante — même quand, comme ici, les deux branches aboutissent à la
même valeur.

### Ordre des clauses et terminaison

L'ordre des clauses détermine l'ordre des solutions **et** peut déterminer si
l'arbre de résolution est fini. Le recueil illustre ceci avec le prédicat
`inf/2` sur les entiers de Peano et le prédicat `entier_1/1` :

```prolog
entier_0(z).
entier_1(s(X)) :- entier_0(X).

inf(z, _).
inf(s(N1), s(N2)) :- inf(N1, N2).
```

```prolog
?- entier_1(X), inf(Y, X).
X = s(z), Y = z ;
X = Y, Y = s(z) ;
false.

?- inf(Y, X), entier_1(X).
Y = z, X = s(z) ;
Y = X, X = s(z) ;
% la résolution continue indéfiniment, sans nouvelle solution
```

Les deux requêtes ont les deux mêmes solutions logiques, mais la seconde a un
arbre de résolution à branche infinie : `inf(Y, X)` seul engendre une infinité
de couples, et ce n'est qu'en le combinant à `entier_1(X)` (qui borne `X`)
qu'on obtient un arbre fini — à condition de mettre `entier_1(X)`
**en premier**. Conséquence directement examinable : **placer les sous-buts
les plus contraignants en premier dans le corps d'une clause ou dans une
requête**, pour ne pas laisser la recherche s'enfoncer dans une branche
infinie avant même d'avoir essayé la contrainte qui l'aurait coupée court.

Un cas de base placé *après* la règle récursive dans le programme produit le
même risque : la sélection de clause suit l'ordre d'écriture, donc la
première clause qui s'unifie est toujours essayée en premier, qu'elle mène ou
non à une branche infinie.

### Coupure (`!`) — hors recueil, norme ISO

Le recueil (chapitre 4) ne traite pas la coupure ; ce qui suit est un rappel
de la norme ISO, à prendre comme culture générale plutôt que comme
terminologie du cours. `!` est un but toujours réussi qui, lors d'un retour
arrière, **élimine** tout point de choix créé depuis l'entrée dans la clause
courante (choix d'une autre clause pour le même prédicat, et choix restants
dans les sous-buts qui précèdent `!` dans le corps). Effet net : rend
déterministe un prédicat qui aurait autrement plusieurs solutions ou
plusieurs façons d'en trouver une seule.

### Négation par l'échec

```prolog
couleur(vert).
couleur(jaune).
couleur(rouge).
couleur(bleu).
claire(vert).
claire(jaune).

foncee(C) :-
    couleur(C),
    \+ claire(C).
```

```prolog
?- foncee(C).
C = rouge ;
C = bleu ;
false.
```

`\+ But` réussit si et seulement si `But` **ne produit aucune solution**. Ce
n'est pas la négation logique — c'est l'hypothèse du monde clos appliquée à
l'échec de la preuve. `\= ` est sa version pour l'unification :
`t1 \= t2` est équivalent à `\+ (t1 = t2)`.

**Piège d'ordre à l'intérieur même de la négation** — la négation par l'échec
n'est correcte que sur des termes déjà entièrement instanciés :

```prolog
?- X = b, \+ p(X).
X = b.
?- \+ p(X), X = b.
false.
```

(avec `p(a).` comme unique clause). Dans la première requête, `X` vaut déjà
`b` quand `\+ p(X)` s'exécute : `p(b)` est indémontrable, la négation réussit.
Dans la seconde, `X` n'est *pas encore* instanciée quand `\+ p(X)` s'exécute :
`p(X)` a une solution (`X = a`), donc sa négation échoue immédiatement — et
`X = b` n'est jamais atteint, alors que logiquement les deux sous-buts
semblent équivalents à ceux de la première requête.

### Listes

```prolog
[]                    % liste vide
[t1, t2, t3]           % liste de trois termes
[T | Q]                % tête T, queue Q
[t1, t2 | Q]           % deux têtes, puis la queue Q
```

```prolog
?- [a, b, c] = [X | Y].
X = a, Y = [b, c].
?- [a, a, X | [c, b]] = [Y | Z].
Y = a, Z = [a, X, c, b].
```

`membre/2` (équivalent du `member/2` prédéfini) :

```prolog
membre(X, [X | _]).
membre(X, [_ | LST]) :-
    membre(X, LST).
```

```prolog
?- membre(a, [b, a, c]).
true ;
false.
?- membre(X, [b, a, Y]).
X = b ;
X = a ;
X = Y ;
false.
```

`concatenation/3` (équivalent d'`append/3`) :

```prolog
concatenation([], LST, LST).
concatenation([X | LST_1], LST_2, [X | LST_3]) :-
    concatenation(LST_1, LST_2, LST_3).
```

```prolog
?- concatenation([a, b, c], [d, c], L).
L = [a, b, c, d, c].
?- concatenation(L1, L2, [b, c, a, a]).
L1 = [], L2 = [b, c, a, a] ;
L1 = [b], L2 = [c, a, a] ;
L1 = [b, c], L2 = [a, a] ;
L1 = [b, c, a], L2 = [a] ;
L1 = [b, c, a, a], L2 = [] ;
false.
```

`length/2` est prédéfini (utilisé, non redéfini, dans le recueil — par
exemple `length(R, N)` pour construire une liste de longueur `N` avec des
éléments non instanciés, dans le problème des tours page 476).

### Arithmétique et contraintes (CLP)

Le recueil aborde exclusivement l'arithmétique via la bibliothèque `clpfd`
(*Constraint Logic Programming over Finite Domains*), incluse par
`:- use_module(library(clpfd))`. Les contraintes s'écrivent avec des
opérateurs préfixés par `#` : `#=`, `#\=`, `#>=`, `#=<`, `#>`, `#<` — à
distinguer de `=` (unification de termes, pas d'évaluation).

```prolog
fact(0, 1).
fact(N, F) :-
    N #> 0,
    N1 #= N - 1,
    F #= N * F1,
    fact(N1, F1).
```

```prolog
?- fact(7, X).
X = 5040 ;
false.
?- fact(X, X).
X = 1 ;
X = 2 ;
false.
```

`X in A..B` borne une variable à un intervalle ; `LST ins A..B` l'applique à
toutes les variables d'une liste ; `all_distinct(LST)` force des valeurs
distinctes ; `label(LST)` force la recherche explicite des valeurs des
variables contraintes (sans `label`, la contrainte reste posée mais non
résolue en valeurs concrètes). `findall(LST_VARS, But, RES)` collecte toutes
les solutions dans une liste — utile puisque, par défaut, Prolog imprime les
solutions une à une, à la demande.

**Le vrai contraste à retenir : contrainte contre unification, pas seulement
« évaluer contre unifier ».** `=` unifie deux termes sans rien évaluer. Une
contrainte `clpfd` comme `#=` fonctionne, elle, **dans les deux sens** — elle
n'exige pas que son membre droit soit entièrement instancié, contrairement à
l'opérateur `is/2` de la norme ISO (hors `clpfd`, et absent des 115 pages du
recueil sur la programmation logique — vérifié par recherche sur le texte
extrait). Vérifié à l'exécution (SWI-Prolog 10.0.2) sur
`fact/2` du recueil :

```prolog
?- fact(7, X).
X = 5040.
?- fact(X, 720).
X = 6.
```

La seconde requête interroge `fact/2` « à l'envers » — impossible avec `is`,
qui aurait exigé que `N` soit déjà lié avant d'évaluer `N - 1`. C'est
exactement ce que permettent les contraintes : elles se posent avant d'être
résolues, dans n'importe quel ordre de sous-buts, et c'est `label/1` qui
force ensuite la recherche des valeurs concrètes.

**Sur `is` lui-même** : il appartient à la norme ISO (`X is Expr` évalue
`Expr` et unifie `X` au résultat), mais n'est ni enseigné ni utilisé dans le
recueil — à mentionner pour ne pas le chercher par réflexe à l'examen, pas à
réviser comme du contenu du cours.

## Ce qui diffère de l'impératif

| Réflexe impératif | Ce que fait Prolog |
|---|---|
| Une fonction a une entrée et une sortie fixées à l'écriture. | Un prédicat n'a ni entrée ni sortie prédéterminées : `concatenation(L1, L2, [b,c,a,a])` s'interroge dans n'importe quel sens, y compris pour engendrer tous les couples `(L1, L2)` possibles. |
| Une variable est une case mémoire qu'on affecte. | Une variable est une inconnue qu'on unifie ; une fois liée dans une branche de résolution, elle le reste jusqu'au retour arrière qui défait la liaison. |
| Une condition retourne vrai ou faux, une fois. | Une requête peut avoir zéro, une, ou une infinité de solutions, énumérées une à une par retour arrière ; `false.` final signifie « plus de solution », pas « erreur ». |
| L'ordre des instructions ne change pas ce qui est vrai. | L'ordre des clauses et des sous-buts ne change pas la sémantique logique, mais change l'ordre des solutions et peut transformer une terminaison en boucle infinie. |

## Pièges de QCM

- **« Le résultat de l'unification de `b(X,X)` et `b(c,d)` est `{X ↦ c, X ↦ d}` »**
  — plausible parce que chaque position semble s'unifier indépendamment.
  Faux : `X` apparaît deux fois dans le même terme, donc les deux positions
  doivent recevoir la **même** valeur ; `c` et `d` sont des atomes distincts,
  donc l'unification **échoue**, elle ne produit pas deux liaisons pour `X`.

- **« `X = 1 + 2` donne `X = 3` »** — plausible en pensant à `is`, ou par
  habitude d'un langage où `=` évalue. Faux dans ce cas précis : `=` est
  l'unification, elle lie `X` au terme non évalué `1+2`. Seule une évaluation
  arithmétique (`is`, ou une contrainte `#=` de `clpfd`) donnerait `X = 3`.

- **« Réordonner deux clauses d'un même prédicat ne change rien d'observable »**
  — plausible parce que la sémantique logique du programme (l'ensemble des
  faits démontrables) est en effet inchangée. Faux pour ce qui est
  *observable* : l'ordre des solutions dépend de l'ordre des clauses, et pire,
  un programme qui terminait peut se mettre à boucler indéfiniment si la
  clause menant à un arbre infini passe avant celle qui termine (cas
  `inf(Y,X), entier_1(X)` contre `entier_1(X), inf(Y,X)` du recueil).

- **« `\+ p(X)` est équivalent, dans n'importe quel ordre de sous-buts, à
  vérifier que `p` n'est vrai pour aucun `X` »** — plausible parce que ça
  décrit bien l'intention. Faux : si `X` n'est pas encore instanciée au
  moment où `\+ p(X)` s'exécute, la négation par l'échec regarde s'il *existe*
  un `X` qui rend `p(X)` vrai — pas la même question — et échoue dès qu'un tel
  `X` existe, même si l'énoncé demandait autre chose.

- **« Une requête sans solution prouve que sa négation est vraie »** —
  plausible car cela ressemble à un raisonnement classique en logique
  classique bivalente. Faux dans le cadre déclaré par le recueil : l'absence
  de démonstration d'un but ne constitue pas une démonstration de sa négation
  logique ; c'est *seulement* sous l'hypothèse du monde clos que Prolog traite
  l'échec comme un « faux » exploitable par `\+`.

## À retenir par cœur

- Unifier, c'est résoudre une équation sur des termes ; une variable répétée
  dans un même terme impose l'égalité de toutes ses positions.
- L'algorithme d'unification échoue sur : atomes/foncteurs différents à la
  racine, arités différentes, ou une variable qui devrait s'unifier avec un
  terme qui la contient.
- La résolution SLD essaie les clauses **dans l'ordre du programme**,
  descend en profondeur d'abord, et revient en arrière au dernier point de
  choix sur échec ou après une solution.
- L'ordre des clauses fixe l'ordre des solutions et peut transformer la
  terminaison en boucle infinie, sans changer la sémantique logique.
- `=` unifie sans évaluer ; l'arithmétique du cours passe par `clpfd`
  (`#=`, `in`, `ins`, `all_distinct`, `label`), pas par `is` (absent du
  recueil) — et une contrainte `#=` s'interroge dans les deux sens, à
  l'inverse d'`is`.
- Par défaut, SWI-Prolog n'applique **pas** l'occur check (`X = f(X)` réussit
  et crée un terme cyclique) ; l'algorithme du cours l'impose et donnerait un
  échec — `unify_with_occurs_check/2` retrouve ce comportement.
- `\+ But` réussit si `But` échoue — hypothèse du monde clos, pas négation
  logique — et n'est fiable que sur des termes déjà instanciés.
- `[T|Q]` décompose une liste comme `x :: reste` en OCaml ; `membre/2` et
  `concatenation/3` du recueil sont les prédéfinis `member/2` et `append/3`.
