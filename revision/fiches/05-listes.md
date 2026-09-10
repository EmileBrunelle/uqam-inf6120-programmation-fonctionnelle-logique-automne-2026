# Listes

> Recueil, chapitre 3, sections 3.9.3 et 3.10 (pages 296–325)

La liste est la structure de données la plus manipulée du cours et la plus
mal transposée depuis un langage impératif : elle n'est ni un tableau, ni une
`ArrayList`, mais un type somme récursif ordinaire, et son coût s'en déduit
entièrement. Une bonne partie des questions de complexité et d'affichage
repose sur cette seule différence structurelle.

## Ce qu'il faut savoir dire

| Terme | Définition attendue |
|---|---|
| Liste | Suite finie homogène, valeur du type polymorphe `'a list`. |
| `[]` | Constructeur de la liste vide, valeur polymorphe `'a list`. |
| `::` | Constructeur de cellule (`List.cons`), infixe, associatif à droite. |
| `'a list` (vu comme type somme) | Équivalent à `type 'a liste = Vide \| Cellule of 'a * 'a liste`. |
| `@` | `List.append`, concatène deux listes en en reconstruisant une. |

## Syntaxe et sémantique

Une liste n'est pas une primitive du langage : elle *pourrait* être définie par
l'utilisateur avec un type somme ordinaire à deux constructeurs, l'un sans
donnée (le cas vide), l'autre portant un élément et le reste de la liste. La
notation `[e1; e2; ...; en]` et l'opérateur `::` sont un sucre syntaxique pour
exactement cette structure — c'est ce qui explique tout le reste de la fiche.

```ocaml
# [2; 4; 5 + 3; 16];;
- : int list = [2; 4; 8; 16]
# [];;
- : 'a list = []
# 1 :: [2; 3];;
- : int list = [1; 2; 3]
```

`1 :: 2 :: 3 :: []` se lit `1 :: (2 :: (3 :: []))` : `::` associe à droite,
chaque `::` alloue une seule cellule qui pointe sur le reste, déjà construit.

```ocaml
# [1; 2; 3] @ [4; 5];;
- : int list = [1; 2; 3; 4; 5]
```

Le filtrage déconstruit une liste avec les mêmes motifs que sa construction :
`[]`, `e :: reste`, et rien d'autre. Toute fonction récursive sur les listes
suit ce patron à deux cas — davantage seulement pour distinguer `[e]` (liste à
un élément) quand la fonction regarde deux éléments d'affilée.

## Coût réel des opérations

Une liste est une **liste simplement chaînée immuable** : chaque cellule
connaît son élément et un pointeur vers la suite, jamais sa longueur totale ni
un accès direct à un indice. Le coût de chaque fonction se lit directement sur
cette structure, sans qu'il soit nécessaire de mesurer quoi que ce soit.

| Fonction | Coût | Pourquoi (structurel) |
|---|---|---|
| `x :: l` | Θ(1) | une cellule allouée, qui pointe sur `l` ; `l` n'est ni copiée ni parcourue, elle est **partagée**. |
| `List.hd`, `List.tl` | Θ(1) | une seule cellule à lire, mais fonctions partielles (voir plus bas). |
| `List.length` | Θ(n) | aucune cellule ne connaît la longueur totale ; il faut parcourir jusqu'à `[]`. |
| `List.nth l i` | Θ(i) | pas d'accès indexé : on suit les `i` premiers maillons un par un. |
| `List.mem`, `List.exists`, `List.for_all` | Θ(n) au pire | parcours qui peut s'arrêter tôt, mais rien ne le garantit dans le pire cas. |
| `List.rev` | Θ(n) | une seule passe, avec un accumulateur (récursion terminale). |
| `l1 @ l2` | Θ(\|l1\|) | reconstruit une cellule par élément de `l1` ; la queue reçoit `l2` **partagé**, non copié. |

Ce dernier point explique le partage de mémoire visible sur `4 :: lst1` : une
seule cellule est créée, les trois cellules de `lst1` sont réutilisées telles
quelles, parce qu'aucune des deux listes ne peut être mutée sous les pieds de
l'autre.

### Fonctions partielles à éviter

`List.hd`, `List.tl` et `List.nth` lèvent une exception sur un argument hors
domaine (liste vide, ou indice trop grand) plutôt que de renvoyer une valeur
pour tous les cas — ce sont des **fonctions partielles**, proscrites par le
guide de style du cours.

```ocaml
# List.hd [];;
Exception: Failure "hd".
```

L'alternative attendue est le filtrage, qui force à traiter `[]` :

```ocaml
let tete_opt lst =
  match lst with
  | [] -> None
  | e :: _ -> Some e
```

## L'idiome accumulateur + `List.rev`

Construire une liste résultat en l'accumulant en tête, puis inverser une seule
fois à la fin, est le patron attendu pour toute transformation récursive
terminale de liste :

```ocaml
# let rec miroir lst =
    let rec aux lst acc =
      match lst with
      | [] -> acc
      | e :: reste -> aux reste (e :: acc)
    in
    aux lst [];;
val miroir : 'a list -> 'a list = <fun>
# miroir [1; 2; 3; 4; 5];;
- : int list = [5; 4; 3; 2; 1]
```

Ici `acc` grandit par `e :: acc`, en Θ(1) à chaque tour, pour un total en
Θ(n) — exactement `List.rev` réimplantée.

### Le piège qui coûte des points partout : `acc @ [x]`

Remplacer `e :: acc` par `acc @ [e]` semble équivalent (« ajouter à la fin
plutôt qu'au début ») mais ne l'est pas : `@` recopie tout son premier
argument. Accumuler ainsi sur n éléments recopie l'accumulateur à chaque tour,
dont la taille croît de 1 à n :

```
1 + 2 + 3 + ... + n = Θ(n²)
```

contre Θ(n) pour l'idiome `x :: acc` suivi d'un seul `List.rev` final. Le
réflexe correct est toujours : accumuler en tête, inverser une fois à la fin —
jamais accumuler en queue à chaque tour.

## Ce qui diffère de l'impératif

| Réflexe impératif | Ce que fait OCaml |
|---|---|
| Une `ArrayList` ou un tableau : accès indexé en Θ(1), ajout en fin peu coûteux, taille connue d'avance sans parcours. | Une liste chaînée : accès indexé en Θ(i), ajout en tête en Θ(1), ajout en fin en Θ(n), longueur en Θ(n). |
| Une chaîne de caractères est essentiellement une liste ou un tableau de caractères ; on la parcourt comme telle. | `string` est un type à part, distinct de `'a list` ; `List.length "abc"` est une erreur de type, pas une conversion implicite. |
| Modifier une structure en place (`list.add`, `arr[i] = x`). | Toute « modification » construit une nouvelle liste ; les anciennes cellules restent valides et sont **partagées**, jamais copiées ni mutées. |

## Pièges de QCM

**« `List.nth` est en Θ(1), comme l'indexation d'un tableau. »** Plausible pour
qui vient d'un tableau ou d'une `ArrayList`, où l'indexation est justement en
temps constant. Faux : une liste n'a pas d'accès direct par indice, il faut
suivre `i` cellules depuis la tête, donc Θ(i).

**« `acc @ [x]` dans une boucle récursive est aussi efficace que `x :: acc`. »**
Plausible parce que les deux ajoutent visuellement « un élément à
l'accumulateur ». Faux : `x :: acc` alloue une cellule en Θ(1) ; `acc @ [x]`
recopie tout `acc`, ce qui rend la boucle entière Θ(n²) au lieu de Θ(n).

**« Une chaîne de caractères se traite avec `List.map`, `List.filter`, etc.,
comme une liste de caractères. »** Plausible parce que conceptuellement une
chaîne *est* une suite de caractères, et que d'autres langages (Python) la
traitent comme itérable au même titre qu'une liste. Faux en OCaml : `string`
n'est pas `'a list`, `List.length "abc"` échoue au typage. Il faut passer par
`String.length`, `String.get` (`.[i]`), ou construire explicitement la liste
des caractères avec `List.init (String.length s) (String.get s)`.

**« `List.hd` et `List.tl` renvoient une valeur par défaut sur la liste
vide. »** Plausible pour qui connaît des méthodes qui renvoient `null`,
`undefined` ou une valeur sentinelle plutôt que de lever. Faux : ce sont des
fonctions partielles qui lèvent `Failure "hd"` / `Failure "tl"` — le guide de
style du cours les proscrit précisément pour cette raison.

## À retenir par cœur

- `::` est Θ(1) et associatif à droite ; `@` est Θ(longueur du premier
  argument) et ne touche jamais le second.
- Aucune opération sur les listes n'a de coût constant *sauf* celles qui
  touchent uniquement la tête (`::`, `List.hd`, `List.tl`).
- `List.length`, `List.nth`, `List.rev`, `l1 @ l2` sont toutes en Θ(n) au
  minimum, faute d'accès indexé et de longueur mémorisée.
- L'idiome correct : accumuler en tête (`x :: acc`), inverser une seule fois
  avec `List.rev` à la fin — jamais `acc @ [x]` en boucle.
- `List.hd`, `List.tl`, `List.nth` sont des fonctions partielles, proscrites
  par le guide de style ; le filtrage sur `[]` / `e :: reste` est l'alternative.
- `string` n'est pas `'a list` : aucune fonction de `List` ne s'applique
  directement à une chaîne de caractères.
- Deux listes qui partagent une même queue (`4 :: lst1`) ne copient rien :
  l'immuabilité rend le partage sûr.
