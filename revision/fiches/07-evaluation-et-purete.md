# Stratégies d'évaluation et pureté

> Recueil, chapitre 3, sections 3.11 et 3.12 (pages 325–350)

Cette matière est plus théorique que le reste du chapitre 3, mais elle est
directement responsable du guide de style noté : les constructions
impératives d'OCaml existent bel et bien dans le langage, et sont proscrites
précisément parce qu'elles cassent les propriétés développées ici. Comprendre
*pourquoi* la non-mutabilité et la transparence référentielle comptent rend
le guide de style mécanique plutôt qu'arbitraire.

## Ce qu'il faut savoir dire

| Terme | Définition attendue |
|---|---|
| Appel par valeur | Tous les arguments sont évalués jusqu'à obtenir des valeurs, *avant* l'application de la fonction. |
| Appel par nom | Chaque argument est substitué non évalué aux occurrences du paramètre correspondant, réévalué à chaque usage. |
| Appel par nécessité | Version mémoïsée de l'appel par nom : chaque argument n'est évalué qu'à son premier usage requis, puis le résultat est enregistré. |
| Transparence référentielle | Toute expression peut être remplacée par sa valeur sans changer le résultat du programme. |
| Fonction pure | Même entrée ⇒ même sortie, aucun effet observable en dehors de la valeur renvoyée. |
| Non-mutabilité | Une donnée construite ne peut plus être modifiée ; obtenir une variante en requiert la reconstruction. |

## Syntaxe et sémantique

### Les trois stratégies, sur le même exemple

Avec `let f x y z = x + z`, l'expression
`f (1 * 1) (f (if 1 = 1 then 2 else 3) 1 4) (3 * 4)` s'évalue différemment
selon la stratégie :

- **Par valeur** : tous les sous-arguments sont réduits d'abord —
  `f (1*1) (f (if 1=1 then 2 else 3) 1 4) (3*4) → f 1 (f 2 1 4) 12 → f 1 6 12 → 13`.
- **Par nom** : les arguments non utilisés (ici `y`, dans les deux appels à
  `f`) ne sont jamais évalués —
  `f (1*1) (f ... ) (3*4) → (1*1) + (3*4) → 13`. Même résultat, mais moins de
  calcul, au prix d'une réévaluation possible si l'argument est utilisé
  plusieurs fois.

Le coût caché de l'appel par nom apparaît avec `let f x y = x * x + y` :
`f (4 * 3) (2 * 1)` s'évalue en `(4*3) * (4*3) + (2*1)` — `4 * 3` est calculé
deux fois, faute de mémorisation.

L'**appel par nécessité** combine les deux : chaque argument n'est évalué que
s'il est requis (comme par nom), et le résultat de cette évaluation est
enregistré pour ne jamais être recalculé (comme par valeur). Il cumule les
avantages des deux sans leurs inconvénients, mais n'est correct que si la
**transparence référentielle** est respectée partout — sinon mémoriser une
évaluation change le comportement du programme. C'est pour cette raison que
seuls des langages fonctionnels purs, comme Haskell, l'utilisent par défaut.

**OCaml évalue par valeur.** Le module `Lazy` offre l'appel par nécessité à la
demande, explicitement :

```ocaml
# let l = lazy (print_endline "calcul"; 42);;
val l : int lazy_t = <lazy>
# Lazy.force l;;
calcul
- : int = 42
# Lazy.force l;;
- : int = 42
```

Le message `calcul` ne s'affiche qu'au premier `Lazy.force` : c'est
l'évaluation retardée. Le second appel renvoie `42` directement, sans
réimprimer `calcul` : c'est la mémoïsation.

### Transparence référentielle et pureté

```ocaml
# type point = { x : int; y : int };;
# let p = { x = 1; y = 2 };;
# { p with x = 9 };;
- : point = {x = 9; y = 2}
```

`{ p with x = 9 }` reconstruit une valeur ; `p` reste intact. Remplacer cette
expression par sa valeur (`{x = 9; y = 2}`) ne change rien au sens du reste du
programme — c'est la transparence référentielle. À l'inverse :

```ocaml
# let f () = print_endline "effet"; 3;;
# f () + f ();;
effet
effet
- : int = 6
```

`f` n'est pas pure : chaque appel produit un effet observable (une impression)
en plus de sa valeur. Remplacer un des deux `f ()` par `3` changerait le
programme (une ligne de moins imprimée) : `f ()` n'est donc pas transparent
référentiellement, même si sa valeur de retour, elle, est toujours `3`.

### Les constructions que le guide de style proscrit

`ref`, `:=`, `!`, `array`, `for`, `while` existent dans le langage et
fonctionnent :

```ocaml
# let r = ref 0;;
val r : int ref = {contents = 0}
# r := 5;;
- : unit = ()
# !r;;
- : int = 5
# let a = [|1; 2; 3|];;
val a : int array = [|1; 2; 3|]
# a.(0) <- 9;;
- : unit = ()
# a;;
- : int array = [|9; 2; 3|]
# for i = 1 to 3 do print_int i done;;
123- : unit = ()
```

`ref` est une case mémoire mutable (`contents`), `:=` y écrit, `!` y lit —
c'est de l'affectation, pas du filtrage ni de la liaison. `array` est une zone
mémoire mutable à accès indexé constant, à l'opposé d'une liste chaînée
immuable. `for` et `while` n'ont de sens que pour piloter des effets de bord
sur ces structures mutables : sans mutation à répéter, une boucle impérative
n'a rien à faire.

Chacune de ces six constructions casse la non-mutabilité ou introduit un
effet de bord invisible dans le type de retour — exactement ce que la
transparence référentielle interdit. C'est pourquoi le guide de style noté du
cours les proscrit : leur usage revient à écrire de l'impératif dans la
syntaxe d'un langage fonctionnel, et supprime les garanties (raisonnement
équationnel, partage sûr de mémoire) que la non-mutabilité procure.

## Ce qui diffère de l'impératif

| Réflexe impératif | Ce que fait OCaml (et le guide de style attend) |
|---|---|
| Les arguments d'un appel sont toujours évalués avant l'appel, sans alternative — c'est la seule stratégie connue. | OCaml évalue aussi par valeur par défaut, mais l'évaluation paresseuse existe explicitement via `Lazy`, avec un comportement observable différent (l'effet ne se produit qu'à `Lazy.force`). |
| Modifier une variable ou un champ en place (`x = x + 1`, `obj.field = v`) est l'opération de base de toute boucle. | `ref`, `:=`, `!` existent mais sont proscrits : l'idiome attendu est de reconstruire une nouvelle valeur (récursion avec accumulateur) plutôt que muter. |
| Une fonction qui imprime, lit un fichier ou modifie une variable globale est une fonction comme les autres, avec un type de retour ordinaire. | Un effet de bord n'est pas invisible : il rend la fonction non pure et casse la transparence référentielle, même si le type de retour semble ordinaire (souvent `unit`, un signal en soi). |

## Pièges de QCM

**« Peu importe la stratégie d'évaluation, un programme qui boucle sur un
argument non utilisé boucle toujours. »** Plausible parce qu'en appel par
valeur — la seule stratégie que connaît la plupart des langages usuels — c'est
vrai : l'argument est évalué avant l'appel, qu'il serve ou non. Faux en
général : par nom ou par nécessité, un argument non utilisé dans le corps
n'est jamais évalué, donc une non-terminaison ou une exception dans cet
argument n'est jamais déclenchée.

**« Le module `Lazy` évalue paresseusement, donc chaque `Lazy.force` réexécute
le calcul pour rester à jour. »** Plausible par confusion avec une fonction
paresseuse au sens de « recalculée à la demande » sans mémorisation, comme un
getter recalculé à chaque accès. Faux : `Lazy.force` mémorise le résultat au
premier appel ; les appels suivants renvoient la valeur enregistrée sans
réévaluer — l'effet de bord `calcul` ne s'imprime qu'une fois.

**« `{ p with x = 9 }` modifie `p` comme le ferait `p.x = 9` en Java. »**
Plausible parce que la syntaxe évoque une mise à jour de champ. Faux : `with`
construit un **nouvel** enregistrement ; `p` original reste inchangé après
l'opération, ce qui est vérifiable en réaffichant `p`.

**« Une fonction qui ne modifie ni variable globale ni référence est
automatiquement pure. »** Plausible parce que la mutation est la forme d'effet
de bord la plus visible. Faux : imprimer sur la sortie standard, lire une
entrée, ou lever une exception selon les données sont aussi des effets
observables qui cassent la pureté et la transparence référentielle, même sans
`ref` ni `array` en vue.

## À retenir par cœur

- Trois stratégies : par valeur (arguments évalués avant l'appel), par nom
  (substitution non évaluée, réévaluée à chaque usage), par nécessité (par nom
  + mémorisation).
- OCaml évalue par valeur par défaut ; l'appel par nécessité est disponible
  explicitement via `Lazy` (`Lazy.force`).
- L'appel par nécessité n'est correct que sous transparence référentielle —
  c'est pourquoi seuls les langages purs (Haskell) l'utilisent par défaut.
- Transparence référentielle : remplacer une expression par sa valeur ne
  change jamais le sens du programme ; un effet de bord la casse.
- Fonction pure : même entrée, même sortie, aucun effet observable — le type
  `unit` en retour est souvent un indice d'impureté.
- `ref`, `:=`, `!`, `array`, `for`, `while` fonctionnent en OCaml mais sont
  proscrits par le guide de style : ils cassent la non-mutabilité ou
  introduisent un effet de bord invisible dans le type.
