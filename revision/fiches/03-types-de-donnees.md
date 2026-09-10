# Types de données

> Recueil, chapitre 1, pages 15–19 (arbres binaires) et chapitre 3, section
> 3.5 « Types », pages 191–225. Les naturels de Peano sont introduits plus
> loin, page 366, comme exemple de type somme récursif.

Cette matière est la plus mécanique du cours : définir un type produit ou
somme, dériver ce que produit `{ p with ... }`, ou dire dans quel ordre deux
constructeurs se comparent, ce sont des questions à procédure fixe, sans
ambiguïté possible. Elles tombent aussi bien en QCM qu'en question de
définition, et l'écart avec les `struct`, `enum` et `class` connus par
ailleurs est précis : chaque section ci-dessous nomme l'endroit exact où
l'intuition importée d'un autre langage cesse de s'appliquer.

## Ce qu'il faut savoir dire

| Terme | Définition attendue |
|---|---|
| Type produit | Combine plusieurs valeurs à la fois — « un *et* un ». Couple, n-uplet (`*`) ou enregistrement (`{ }`, produit *nommé*). |
| Type somme | Choisit entre plusieurs formes — « un *ou* un ». Énumère des constructeurs (`\|`), avec ou sans argument attaché. |
| Constructeur | Identificateur commençant par une majuscule, valeur d'un type somme ; peut porter un argument (`Idk of T`). |
| Type paramétré | `type ('P1, ..., 'Pn) ID = OP` : un type qui désigne un ensemble de types, spécialisé en fournissant des types concrets aux paramètres. |
| Type récursif | Type dont la définition fait référence à lui-même (arbre, liste, naturel de Peano). |
| Alias de type | `type ID = T` où `T` est un type déjà existant : nomme un type sans en créer un nouveau distinct. |
| `option` | `type 'a option = None \| Some of 'a`. Encapsule un échec possible sans exception. |

## Syntaxe et sémantique

Couple et n-uplet, avec l'opérateur `*` non associatif — `(T1 * T2) * T3` et
`T1 * (T2 * T3)` sont deux types distincts :

```ocaml
# (3.5, 21);;
- : float * int = (3.5, 21)
# let (c1, c2) = (3.5, 21) in c1;;
- : float = 3.5
```

Enregistrement, accès par `.champ`, et mise à jour non destructive :

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

Type somme, avec et sans arguments :

```ocaml
# type couleur = Rouge | Vert | Bleu;;
type couleur = Rouge | Vert | Bleu
# type nombre = Entier of int | Rationnel of int * int | Infini;;
type nombre = Entier of int | Rationnel of int * int | Infini
```

Type récursif — arbre binaire (chapitre 1) et naturel de Peano (chapitre 3,
page 366), les deux à un seul niveau de récursion via un constructeur qui se
contient lui-même :

```ocaml
# type 'a arbre = Feuille | Noeud of 'a arbre * 'a * 'a arbre;;
type 'a arbre = Feuille | Noeud of 'a arbre * 'a * 'a arbre
# Noeud (Feuille, 3, Noeud (Feuille, 5, Feuille));;
- : int arbre = Noeud (Feuille, 3, Noeud (Feuille, 5, Feuille))
# type nat_peano = Zero | Succ of nat_peano;;
type nat_peano = Zero | Succ of nat_peano
# let deux = Succ (Succ Zero);;
val deux : nat_peano = Succ (Succ Zero)
```

Type paramétré et alias :

```ocaml
# type 'a boite = { contenu : 'a };;
type 'a boite = { contenu : 'a; }
# { contenu = 3 };;
- : int boite = {contenu = 3}
# type paire = int * string;;
type paire = int * string
```

Comparaison polymorphe — `compare` et `<` suivent l'ordre de *déclaration*
des constructeurs, pas un ordre alphabétique ni sémantique :

```ocaml
# Rouge < Vert;;
- : bool = true
# compare Rouge Bleu;;
- : int = -1
# compare (Some 1) None;;
- : int = 1
```

## Ce qui diffère de l'impératif

| Réflexe impératif | Ce que fait OCaml |
|---|---|
| Un setter (`p.setX(9)`) modifie l'objet en place ; le même objet, deux états successifs. | `{ p with x = 9 }` construit un *nouvel* enregistrement ; `p` n'est jamais touché. C'est la transparence référentielle. |
| Une `union` C prend la taille du plus grand membre et ne porte aucune étiquette : lire le mauvais champ ne provoque aucune erreur. | Un type somme porte son étiquette, le constructeur, et le `match` sur ses cas est vérifié à la compilation (exhaustivité). |
| Un `enum` Java n'a pas d'ordre défini pour `<` (ou lève une erreur de type). | Les constructeurs sont ordonnés selon leur position dans la déclaration ; `<` et `compare` l'utilisent directement, sans redéfinition. |

## Pièges de QCM

1. **« `Rouge < Vert` compare les valeurs alphabétiquement, donc c'est comme
   comparer les identificateurs de constructeurs. »** Plausible parce que
   `Rouge` précède effectivement `Vert` dans l'alphabet ici — un exemple mal
   choisi masque la vraie règle. C'est faux : l'ordre suit la position dans
   la *déclaration* `type couleur = Rouge | Vert | Bleu`, pas l'alphabet. Un
   type déclaré `Vert | Rouge | Bleu` inverserait le résultat de `Rouge <
   Vert` sans qu'aucune lettre n'ait changé.

2. **« `{ p with x = 9 }` modifie `p`, donc l'expression suivante `p.x`
   renvoie `9`. »** Plausible pour quiconque vient d'un langage à objets
   mutables, où un setter change l'état de l'objet référencé. C'est faux :
   `{ p with x = 9 }` produit une valeur neuve, `p` reste `{x = 1; y = 2}`
   après l'opération — vérifié plus haut.

3. **« `(T1 * T2) * T3` et `T1 * (T2 * T3)` sont le même type, puisque `*`
   est associatif comme en arithmétique. »** Plausible par analogie avec la
   multiplication. C'est faux : ce sont deux types distincts, l'un contenant
   des couples dont la première coordonnée est elle-même un couple, l'autre
   l'inverse ; une fonction typée pour l'un échoue à la compilation sur
   l'autre.

4. **« `None < Some 3` est faux, puisque `None` ne contient aucune valeur à
   comparer. »** Plausible si on pense que la comparaison exige un contenu
   des deux côtés. C'est faux : `option` est un type somme ordinaire, et
   `None` précède `Some` dans sa déclaration (`None | Some of 'a`) — la
   comparaison structurelle s'applique normalement, `compare (Some 1) None`
   renvoie `1`, donc `None < Some 1` est vrai.

5. **« Un type paramétré comme `'a option` est générique au sens de `List<T>`
   en Java : à l'exécution, on peut interroger le type concret porté par une
   valeur. »** Plausible par la ressemblance de notation. C'est faux : le
   polymorphisme d'OCaml est paramétrique et s'efface à la compilation ; il
   n'existe ni `instanceof`, ni moyen de récupérer `'a` à l'exécution — une
   fonction de type `'a option -> int` ne peut qu'ignorer ou compter le
   contenu, jamais l'inspecter.

## À retenir par cœur

- Produit = « et » (couple, n-uplet, enregistrement) ; somme = « ou »
  (constructeurs).
- `*` n'est pas associatif : `(T1 * T2) * T3 ≠ T1 * (T2 * T3)`.
- `{ p with champ = v }` construit un nouvel enregistrement ; l'original est
  intact.
- Il est interdit de réutiliser un même nom de champ dans deux types
  enregistrement du même espace de noms — le compilateur en garde un seul.
- L'ordre des constructeurs pour `<`, `>`, `compare` suit leur ordre de
  *déclaration*, jamais l'alphabet.
- `type 'a option = None | Some of 'a` : `None` vient avant `Some` dans cet
  ordre.
- Un type récursif (arbre, naturel de Peano) se définit en un constructeur
  qui référence le type en cours de définition.
- Un alias (`type paire = int * string`) nomme un type existant ; il ne crée
  pas de nouveau type distinct pour le vérificateur de types.
