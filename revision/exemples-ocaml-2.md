# 20 autres exemples OCaml commentés (révision QCM, série 2)

Suite de `exemples-ocaml.md` : 20 nouveaux problèmes originaux, sur les thèmes des devoirs d'entraînement
(automates sur listes de cellules, mémoïsation, mots et facteurs, chaînes construites avec `fold`,
composition et itération de fonctions, structures sur une grille, énumération), sans reprendre les
énoncés des devoirs ni ceux des 25 premiers exemples.
Chaque sortie a été vérifiée dans le toplevel (OCaml 5.5.1). Format : énoncé, code, trace à la main,
puis des pièges de lecture du genre « que fait ce code ? ».

Réflexe QCM : lis le **type** avant le corps, puis déroule sur un petit exemple à la main.
Certains exemples réutilisent les définitions d'un exemple précédent (c'est indiqué).

---

## 1. Automate cellulaire : une génération

**Énoncé** : une rangée de cellules (`bool list`). À chaque génération, une cellule devient vivante si
**exactement un** de ses deux voisins l'est (OU exclusif ; hors de la rangée, on suppose des cellules mortes).
La valeur propre de la cellule ne compte pas.

```ocaml
let rec regle90_aux (g : bool) (l : bool list) : bool list =
  match l with
  | [] -> []
  | x :: reste ->
    let d = (match reste with [] -> false | y :: _ -> y) in
    (g <> d) :: regle90_aux x reste

let regle90 (l : bool list) : bool list = regle90_aux false l
```

**Trace** `regle90 [false; false; true; false; false]` : `g` = voisin de gauche (l'**ancienne** valeur de la cellule précédente).
Cellule 0 : `false <> false` = `false`. Cellule 1 : g = `false`, d = `true` → `true`. Cellule 2 : `false <> false` → `false`.
Cellule 3 : g = `true`, d = `false` → `true`. Cellule 4 : g = `false`, d = bord = `false` → `false`.
Résultat `[false; true; false; true; false]`.

**Pièges**
- `regle90 [true]` → `[false]` (aucun voisin vivant) ; `regle90 []` → `[]`.
- `regle90 [true; false]` → `[false; true]` ; `regle90 [true; true; true]` → `[true; false; true]` (le milieu a deux voisins vivants : XOR de `true` et `true` = `false`).
- Dans l'appel récursif on passe `x` (l'ancienne valeur), pas la nouvelle : sinon la génération se contaminerait de gauche à droite.

---

## 2. Plusieurs générations et historique

**Énoncé** : avancer de `n` générations, ou garder toutes les rangées (`regle90` de l'exemple 1).

```ocaml
let rec evoluer (n : int) (l : bool list) : bool list =
  if n = 0 then l else evoluer (n - 1) (regle90 l)

let rec historique (n : int) (l : bool list) : bool list list =
  if n = 0 then [l] else l :: historique (n - 1) (regle90 l)
```

**Trace** `historique 2 [false; false; true; false; false]` : `l0 :: historique 1 l1` = `l0 :: l1 :: historique 0 l2` = `l0 :: l1 :: [l2]`,
avec `l1 = [false; true; false; true; false]` et `l2 = [true; false; false; false; true]`.

**Pièges**
- `List.length (historique 3 [true])` → `4` : `n + 1` rangées (la rangée de départ est incluse). `historique 0 [true]` → `[[true]]`.
- `evoluer 2 [false; false; true; false; false]` → `[true; false; false; false; true]` (dernier élément de l'historique).
- `evoluer (-1) l` ne termine jamais (`n` n'atteint pas `0` en descendant) : un test `n <= 0` serait plus sûr.

---

## 3. Propagation du feu dans une forêt

**Énoncé** : une rangée d'arbres. Un feu devient cendre ; un arbre prend feu si un voisin brûle ; cendre et vide ne changent pas.

```ocaml
type etat = Vide | Arbre | Feu | Cendre

let suivante (g : etat) (c : etat) (d : etat) : etat =
  match c with
  | Feu -> Cendre
  | Arbre -> if g = Feu || d = Feu then Feu else Arbre
  | Cendre | Vide -> c

let rec foret_aux (g : etat) (l : etat list) : etat list =
  match l with
  | [] -> []
  | c :: reste ->
    let d = (match reste with [] -> Vide | y :: _ -> y) in
    suivante g c d :: foret_aux c reste

let evoluer_foret (l : etat list) : etat list = foret_aux Vide l
```

**Trace** `evoluer_foret [Arbre; Arbre; Feu; Arbre]` (bords = `Vide`) : cellule 0 : g = `Vide`, d = `Arbre` → `Arbre` ;
cellule 1 : d = `Feu` → `Feu` ; cellule 2 : `Feu` → `Cendre` ; cellule 3 : g = `Feu` (ancienne valeur) → `Feu`.
Résultat `[Arbre; Feu; Cendre; Feu]`.

**Pièges**
- `evoluer_foret [Feu]` → `[Cendre]` ; `evoluer_foret [Feu; Arbre; Arbre]` → `[Cendre; Feu; Arbre]` (le feu avance d'**une** case par génération).
- `evoluer_foret [Arbre; Cendre; Arbre]` → inchangé : la cendre ne propage pas et ne se reconvertit pas.
- Le `match c with` couvre les 4 constructeurs grâce au motif `Cendre | Vide` ; oublier un constructeur donnerait un avertissement « non exhaustif ».

---

## 4. Fibonacci mémoïsé sans effet secondaire

**Énoncé** : passer le cache en paramètre et le retourner avec le résultat (liste d'association `(n, fib n)`).

```ocaml
let rec fib_memo (n : int) (memo : (int * int) list) : int * (int * int) list =
  if n < 2 then (n, memo)
  else
    match List.assoc_opt n memo with
    | Some v -> (v, memo)
    | None ->
      let (a, m1) = fib_memo (n - 1) memo in
      let (b, m2) = fib_memo (n - 2) m1 in
      (a + b, (n, a + b) :: m2)
```

**Trace** `fib_memo 3 []` : `3` absent. `fib_memo 2 []` : `2` absent ; `fib_memo 1 []` = `(1, [])`, `fib_memo 0 []` = `(0, [])` →
`(1, [(2, 1)])`. Puis `fib_memo 1 [(2, 1)]` = `(1, [(2, 1)])`. Résultat `(2, [(3, 2); (2, 1)])`.
Le cache `m1` (et non `memo`) est passé au second appel : c'est ce qui fait réutiliser le travail du premier.

**Pièges**
- `fib_memo 6 []` → `(8, [(6, 8); (5, 5); (4, 3); (3, 2); (2, 1)])` ; `fib_memo 1 []` → `(1, [])` (les cas de base ne sont pas mémorisés).
- `fst (fib_memo 30 []) ` → `832040`, instantané ; sans cache, le même calcul ferait plus d'un million d'appels.
- Un cache **faux** est cru sur parole : `fib_memo 5 [(3, 100)]` → `(201, [(5, 201); (4, 101); (2, 1); (3, 100)])`.
- Si on passait `memo` au lieu de `m1` au second appel, le résultat resterait juste mais le cache perdrait des entrées (et on recalculerait).

---

## 5. Coefficients binomiaux mémoïsés (clés = paires)

**Énoncé** : `C(n, k) = C(n-1, k-1) + C(n-1, k)`, avec `C(n, 0) = C(n, n) = 1`. Le cache associe une paire `(n, k)` à sa valeur.

```ocaml
let rec binom (n : int) (k : int) (memo : ((int * int) * int) list)
  : int * ((int * int) * int) list =
  if k = 0 || k = n then (1, memo)
  else
    match List.assoc_opt (n, k) memo with
    | Some v -> (v, memo)
    | None ->
      let (a, m1) = binom (n - 1) (k - 1) memo in
      let (b, m2) = binom (n - 1) k m1 in
      (a + b, ((n, k), a + b) :: m2)
```

**Trace** `binom 4 2 []` : `binom 3 1 []` → `binom 2 0` = 1 ; `binom 2 1` = `1 + 1 = 2` (mémorisé) ; donc `(3, 1)` vaut 3.
Ensuite `binom 3 2 m1` : `binom 2 1` est **trouvé** dans le cache (2), `binom 2 2` = 1 → 3. Total `3 + 3 = 6`.

**Pièges**
- `binom 4 2 []` → `(6, [((4, 2), 6); ((3, 2), 3); ((3, 1), 3); ((2, 1), 2)])`.
- `fst (binom 30 15 [])` → `155117520` ; `List.length (snd (binom 6 3 []))` → `9`.
- `binom 3 0 []` → `(1, [])` : cas de base, rien n'est mémorisé.
- Cache empoisonné : `binom 4 2 [((3, 1), 10)]` → `(13, ...)` au lieu de `6`.

---

## 6. Longueur d'une suite de Collatz, avec cache partagé

**Énoncé** : nombre de termes de la suite `n → n/2` (pair) ou `3n+1` (impair) jusqu'à `1` (inclus). Le cache est enfilé dans un `fold_left`.

```ocaml
let rec collatz (n : int) (memo : (int * int) list) : int * (int * int) list =
  if n = 1 then (1, memo)
  else
    match List.assoc_opt n memo with
    | Some v -> (v, memo)
    | None ->
      let suiv = if n mod 2 = 0 then n / 2 else 3 * n + 1 in
      let (l, m) = collatz suiv memo in
      (l + 1, (n, l + 1) :: m)

let tout : int * (int * int) list =
  List.fold_left (fun (_, m) n -> collatz n m) (0, []) [1; 2; 3; 4; 5; 6]
```

**Trace** `collatz 6 []` : 6 → 3 → 10 → 5 → 16 → 8 → 4 → 2 → 1, soit 9 termes. Au retour, on mémorise
`(2, 2)`, `(4, 3)`, `(8, 4)`, `(16, 5)`, `(5, 6)`, `(10, 7)`, `(3, 8)`, `(6, 9)`.

**Pièges**
- `fst (collatz 1 [])` → `1` ; `fst (collatz 27 [])` → `112`.
- `tout` → `(9, [(6, 9); (3, 8); (10, 7); (5, 6); (16, 5); (8, 4); (4, 3); (2, 2)])` : `1` n'est jamais mémorisé, et `2`, `3`, `4`, `5` sont déjà dans le cache quand `6` arrive.
- `List.length (snd tout)` → `8` ; `List.assoc 3 (snd tout)` → `8`.
- Dans le `fold_left`, le premier composant de l'accumulateur est ignoré (`_`) : seul le cache voyage.
- Cache faux : `collatz 6 [(3, 100)]` → `(101, [(6, 101); (3, 100)])`.

---

## 7. Préfixes d'une liste

**Énoncé** : tous les préfixes d'une liste, du plus court (vide) au plus long (la liste entière).

```ocaml
let rec prefixes (l : 'a list) : 'a list list =
  match l with
  | [] -> [[]]
  | x :: r -> [] :: List.map (fun p -> x :: p) (prefixes r)
```

**Trace** `prefixes [1; 2]` : `prefixes [2]` = `[] :: List.map (fun p -> 2 :: p) [[]]` = `[[]; [2]]`.
Puis `[] :: List.map (fun p -> 1 :: p) [[]; [2]]` = `[[]; [1]; [1; 2]]`.

**Pièges**
- `prefixes [1; 2; 3]` → `[[]; [1]; [1; 2]; [1; 2; 3]]` ; `prefixes []` → `[[]]` (**un** préfixe : le mot vide, pas une liste vide de préfixes).
- `List.length (prefixes [1; 2; 3; 4])` → `5` : `n + 1` préfixes.
- `List.map List.rev (prefixes (List.rev [1; 2; 3]))` → `[[]; [3]; [2; 3]; [1; 2; 3]]` : ce sont les **suffixes**.
- `prefixes [[1]; [2]]` → `[[]; [[1]]; [[1]; [2]]]`, de type `int list list list` (le type des éléments ne change rien).

---

## 8. Suffixes et facteurs

**Énoncé** : un facteur est une suite d'éléments **contigus** : c'est un préfixe d'un suffixe.

```ocaml
let rec suffixes (l : 'a list) : 'a list list =
  l :: (match l with [] -> [] | _ :: r -> suffixes r)

let facteurs (l : 'a list) : 'a list list =
  List.concat_map prefixes (suffixes l)
```

(`prefixes` : exemple 7.)

**Trace** `facteurs [1; 2]` : `suffixes [1; 2]` = `[[1; 2]; [2]; []]` ; leurs préfixes : `[[]; [1]; [1; 2]]`, `[[]; [2]]`, `[[]]` ;
mis bout à bout : `[[]; [1]; [1; 2]; []; [2]; []]`.

**Pièges**
- `suffixes [1; 2; 3]` → `[[1; 2; 3]; [2; 3]; [3]; []]`.
- `facteurs [1; 2]` contient **trois** fois `[]` : la liste a des doublons.
- `List.length (facteurs [1; 2; 3])` → `10` (`4 + 3 + 2 + 1`) ; sans doublons (`List.sort_uniq compare`) → `7` ; pour `[1; 1; 1]` → `4`.
- `[1; 3]` n'est **pas** un facteur de `[1; 2; 3]` (c'est une sous-suite, pas contiguë).

---

## 9. Préfixe, facteur et préfixe commun

**Énoncé** : tester si un mot est préfixe ou facteur d'un autre ; calculer le plus long préfixe commun.

```ocaml
let rec est_prefixe (p : 'a list) (l : 'a list) : bool =
  match p, l with
  | [], _ -> true
  | _, [] -> false
  | x :: rp, y :: rl -> x = y && est_prefixe rp rl

let rec est_facteur (f : 'a list) (l : 'a list) : bool =
  est_prefixe f l || (match l with [] -> false | _ :: r -> est_facteur f r)

let rec prefixe_commun (a : 'a list) (b : 'a list) : 'a list =
  match a, b with
  | x :: ra, y :: rb when x = y -> x :: prefixe_commun ra rb
  | _ -> []
```

**Trace** `est_facteur [2; 3] [1; 2; 3; 4]` : `est_prefixe [2; 3] [1; ...]` → `2 = 1` faux ; on avance :
`est_prefixe [2; 3] [2; 3; 4]` → `2 = 2` et `est_prefixe [3] [3; 4]` → `3 = 3` et `est_prefixe [] [4]` → `true`.

**Pièges**
- `est_prefixe [1; 2] [1; 2; 3]` → `true` ; `est_prefixe [1; 2; 3] [1; 2]` → `false` ; `est_prefixe [] []` → `true`.
- `est_facteur [] []` → `true` ; `est_facteur [1; 3] [1; 2; 3]` → `false`.
- `prefixe_commun [1; 2; 3; 4] [1; 2; 5; 4]` → `[1; 2]` (le `4` final ne compte pas : on s'arrête au premier écart) ; `prefixe_commun [1; 2] [1; 2; 3]` → `[1; 2]` ; `prefixe_commun [1] [2]` → `[]`.
- Le cas `| [], _` doit venir **avant** `| _, []`, sinon `est_prefixe [] []` serait `false`.

---

## 10. Mots (`string`) et facteurs distincts

**Énoncé** : représenter un mot par une `char list`, puis lister ses facteurs distincts, triés (définitions des exemples 7 et 8).

```ocaml
let mot_en_liste (s : string) : char list = List.of_seq (String.to_seq s)
let liste_en_mot (l : char list) : string = String.of_seq (List.to_seq l)

let facteurs_distincts (s : string) : string list =
  List.sort_uniq compare (List.map liste_en_mot (facteurs (mot_en_liste s)))
```

**Trace** `facteurs_distincts "aba"` : les 10 facteurs (avec répétitions) sont `""`, `"a"`, `"ab"`, `"aba"`, `""`, `"b"`, `"ba"`, `""`, `"a"`, `""` ;
`sort_uniq` retire les doublons et trie selon l'ordre lexicographique : `["" ; "a"; "ab"; "aba"; "b"; "ba"]`.

**Pièges**
- `facteurs_distincts "aba"` → `[""; "a"; "ab"; "aba"; "b"; "ba"]` : `"ab" < "aba" < "b"` (un préfixe est plus petit).
- `facteurs_distincts "aaa"` → `[""; "a"; "aa"; "aaa"]` ; `facteurs_distincts ""` → `[""]` ; `List.length (facteurs_distincts "abc")` → `7`.
- `List.length (facteurs (mot_en_liste "aaa"))` → `10` : sans `sort_uniq`, on compte les doublons.
- `liste_en_mot (List.rev (mot_en_liste "abc"))` → `"cba"`.

---

## 11. Joindre des chaînes avec un séparateur

**Énoncé** : `joindre sep l` concatène les chaînes de `l` en les séparant par `sep`, sans séparateur en trop.

```ocaml
let joindre (sep : string) (l : string list) : string =
  match l with
  | [] -> ""
  | x :: r -> List.fold_left (fun acc s -> acc ^ sep ^ s) x r
```

**Trace** `joindre ", " ["a"; "b"; "c"]` : accumulateur initial `"a"` (le premier élément) ; `"a" ^ ", " ^ "b"` = `"a, b"` ; `"a, b" ^ ", " ^ "c"` = `"a, b, c"`.

**Pièges**
- `joindre ", " []` → `""` ; `joindre ", " ["seul"]` → `"seul"` ; `joindre "-" [""; ""]` → `"-"`.
- Version naïve : `List.fold_left (fun acc s -> acc ^ ", " ^ s) "" ["a"; "b"]` → `", a, b"` (séparateur en trop au début).
- Version `fold_right` naïve : `List.fold_right (fun s acc -> s ^ ", " ^ acc) ["a"; "b"] ""` → `"a, b, "` (séparateur en trop à la fin).
- `String.concat ", " ["a"; "b"; "c"] = joindre ", " ["a"; "b"; "c"]` → `true` : la bibliothèque fait déjà ce travail.

---

## 12. Dessiner et relire une rangée de cellules

**Énoncé** : afficher une rangée en `'#'` (vivante) et `'.'` (morte), et faire le chemin inverse. Les deux fonctions sont des plis.

```ocaml
let rendre (l : bool list) : string =
  List.fold_right (fun b acc -> (if b then "#" else ".") ^ acc) l ""

let lire (s : string) : bool list =
  String.fold_right (fun c acc -> (c = '#') :: acc) s []
```

**Trace** `rendre [true; false; true]` : `fold_right` part de la **droite** : `""` → `true` : `"#" ^ ""` = `"#"` → `false` : `"." ^ "#"` = `".#"` → `true` : `"#" ^ ".#"` = `"#.#"`.

**Pièges**
- `rendre []` → `""` ; `lire (rendre [true; false; true])` → `[true; false; true]` (aller-retour).
- `lire "#.x#"` → `[true; false; false; true]` : tout caractère autre que `'#'` est lu comme mort.
- Avec l'exemple 2 : `rendre (evoluer 1 [false; false; true; false; false])` → `".#.#."`.
- `String.concat "\n" (List.map rendre (historique 2 [false; false; true; false; false]))` → la chaîne `"..#..\n.#.#.\n#...#"` : `\n` est un seul caractère, et le toplevel l'affiche échappé.

---

## 13. Binaire : de la chaîne à l'entier et inversement

**Énoncé** : convertir une chaîne de `'0'` et `'1'` en entier avec un pli (méthode de Horner), et un entier en chaîne binaire.

```ocaml
let de_binaire (s : string) : int =
  String.fold_left (fun acc c -> 2 * acc + (if c = '1' then 1 else 0)) 0 s

let rec en_binaire (n : int) : string =
  if n < 2 then string_of_int n else en_binaire (n / 2) ^ string_of_int (n mod 2)
```

**Trace** `de_binaire "110"` : acc = 0 ; `'1'` → `2*0 + 1 = 1` ; `'1'` → `2*1 + 1 = 3` ; `'0'` → `2*3 + 0 = 6`.
`en_binaire 6` = `en_binaire 3 ^ "0"` = `(en_binaire 1 ^ "1") ^ "0"` = `"1" ^ "1" ^ "0"` = `"110"`.

**Pièges**
- `de_binaire ""` → `0` ; `de_binaire "0110"` → `6` (zéros de tête sans effet) ; `de_binaire "12"` → `2` (le `'2'` compte comme 0 : aucune validation).
- `en_binaire 0` → `"0"` ; `en_binaire 8` → `"1000"` ; `de_binaire (en_binaire 37)` → `37`.
- Si on écrit `string_of_int (n mod 2) ^ en_binaire (n / 2)` (l'ordre inversé), `6` donne `"011"` : le **reste** est le chiffre de droite, il doit être concaténé en dernier.

---

## 14. Itérer une fonction `n` fois

**Énoncé** : `iterer f n` retourne la fonction `x -> f (f (... (f x)))` avec `n` applications de `f`.

```ocaml
let rec iterer (f : 'a -> 'a) (n : int) : 'a -> 'a =
  if n <= 0 then Fun.id else fun x -> f (iterer f (n - 1) x)
```

**Trace** `iterer (fun x -> x * 2) 3 1` : `f (iterer f 2 1)` = `f (f (iterer f 1 1))` = `f (f (f (iterer f 0 1)))` = `f (f (f 1))`
= `f (f 2)` = `f 4` = `8`.

**Pièges**
- `iterer (fun x -> x * 2) 10 1` → `1024` ; `iterer succ 0 5` → `5` (zéro application : la fonction identité) ; `iterer succ (-2) 5` → `5`.
- `iterer succ 3` → `- : int -> int = <fun>` : sans le dernier argument, on obtient une fonction.
- `iterer (fun l -> 0 :: l) 3 []` → `[0; 0; 0]` ; `iterer (fun s -> s ^ "ab") 2 ""` → `"abab"`.
- `iterer (List.map succ) 2 [1; 2]` → `[3; 4]` (`List.map succ` est une fonction `int list -> int list`, donc `'a = int list`).

---

## 15. Composer une liste de fonctions : l'ordre compte

**Énoncé** : composer `[f1; f2; ...]` de deux façons, avec `fold_right` et avec `fold_left`.

```ocaml
let double (n : int) : int = n * 2
let incr1 (n : int) : int = n + 1

let composer_tout (fs : ('a -> 'a) list) : 'a -> 'a =
  List.fold_right (fun f acc -> fun x -> f (acc x)) fs Fun.id

let enchainer (fs : ('a -> 'a) list) : 'a -> 'a =
  List.fold_left (fun acc f -> fun x -> f (acc x)) Fun.id fs
```

**Trace** `composer_tout [double; incr1] 5` : `fold_right` traite `incr1` d'abord (à droite) : `acc1 = fun x -> incr1 (id x)` ;
puis `acc2 = fun x -> double (acc1 x)`. Donc `double (incr1 5)` = `double 6` = `12`.
`enchainer [double; incr1] 5` : `acc1 = fun x -> double (id x)` ; `acc2 = fun x -> incr1 (acc1 x)`. Donc `incr1 (double 5)` = `11`.

**Pièges**
- `composer_tout [double; incr1] 5` → `12` mais `enchainer [double; incr1] 5` → `11`.
- `composer_tout [] 7` → `7` (liste vide : l'identité).
- `enchainer [incr1; incr1; double] 0` → `4` (`0 → 1 → 2 → 4`) ; `composer_tout [incr1; incr1; double] 0` → `2` (`0 → 0 → 1 → 2`).
- Avec des chaînes : `composer_tout [(fun s -> s ^ "a"); (fun s -> s ^ "b")] ""` → `"ba"` ; `enchainer` des mêmes fonctions → `"ab"`.

---

## 16. Point fixe avec carburant

**Énoncé** : appliquer `f` jusqu'à ce que le résultat ne change plus (`f x = x`), mais abandonner après `carburant` essais pour garantir la terminaison.

```ocaml
let rec point_fixe (f : 'a -> 'a) (x : 'a) (carburant : int) : 'a option =
  if carburant < 0 then None
  else
    let y = f x in
    if y = x then Some x else point_fixe f y (carburant - 1)
```

**Trace** `point_fixe (fun x -> x / 2) 100 7` : `x` vaut `100, 50, 25, 12, 6, 3, 1` avec carburant `7, 6, 5, 4, 3, 2, 1` (aucun point fixe) ;
puis `x = 0`, carburant `0` : `y = 0 = x` → `Some 0`. Avec carburant `6`, on arriverait à `x = 0` avec carburant `-1` : `None`.

**Pièges**
- `point_fixe (fun x -> x / 2) 100 7` → `Some 0` ; avec `6` → `None` (le carburant est testé **avant** de regarder si on est déjà arrivé).
- `point_fixe succ 0 1000` → `None` (jamais stable) ; `point_fixe Fun.id "a" 0` → `Some "a"` ; `point_fixe (fun x -> x / 2) 0 (-1)` → `None` (carburant négatif dès le départ, même si `0` est déjà stable).
- Avec la forêt de l'exemple 3 : `point_fixe evoluer_foret [Arbre; Feu; Arbre] 2` → `Some [Cendre; Cendre; Cendre]` (`[Arbre; Feu; Arbre]` → `[Feu; Cendre; Feu]` → `[Cendre; Cendre; Cendre]`), mais avec carburant `1` → `None`.
- `y = x` compare la structure ; ça fonctionne sur des listes mais boucherait sur une valeur fonctionnelle (`compare: functional value`).

---

## 17. Chemins sur une grille (droite / bas)

**Énoncé** : tous les chemins qui vont de `(0, 0)` à `(w, h)` en ne faisant que des pas vers la droite ou vers le bas.

```ocaml
type pas = Droite | Bas

let rec chemins (w : int) (h : int) : pas list list =
  if w = 0 && h = 0 then [[]]
  else
    (if w > 0 then List.map (fun c -> Droite :: c) (chemins (w - 1) h) else [])
    @ (if h > 0 then List.map (fun c -> Bas :: c) (chemins w (h - 1)) else [])
```

**Trace** `chemins 1 1` : premier pas `Droite` : `Droite ::` chaque chemin de `chemins 0 1` = `[[Bas]]` → `[[Droite; Bas]]` ;
premier pas `Bas` : `Bas ::` chaque chemin de `chemins 1 0` = `[[Droite]]` → `[[Bas; Droite]]`. Résultat `[[Droite; Bas]; [Bas; Droite]]`.

**Pièges**
- `chemins 0 0` → `[[]]` (**un** chemin : ne pas bouger) ; `chemins 0 3` → `[[Bas; Bas; Bas]]` (un seul chemin).
- `chemins 2 1` → `[[Droite; Droite; Bas]; [Droite; Bas; Droite]; [Bas; Droite; Droite]]` ; `List.length (chemins 3 3)` → `20`.
- `chemins (-1) 0` → `[]` : aucun pas n'est permis et on n'est pas à `(0, 0)` ; la fonction termine quand même.
- L'ordre du résultat vient de l'ordre de `@` : tous les chemins qui commencent par `Droite` précèdent ceux qui commencent par `Bas`.

---

## 18. Mots binaires sans deux `1` consécutifs

**Énoncé** : énumérer tous les mots de longueur `n` sur `{0, 1}` où deux `1` ne se suivent jamais. On mémorise le dernier chiffre posé.

```ocaml
let rec sans_deux_uns (n : int) (dernier : int) : int list list =
  if n = 0 then [[]]
  else
    List.map (fun m -> 0 :: m) (sans_deux_uns (n - 1) 0)
    @ (if dernier = 1 then []
       else List.map (fun m -> 1 :: m) (sans_deux_uns (n - 1) 1))

let mots (n : int) : int list list = sans_deux_uns n 0
```

**Trace** `sans_deux_uns 2 1` (le chiffre précédent est un `1`) : on peut poser `0` : `0 ::` chaque mot de `sans_deux_uns 1 0` = `[[0]; [1]]` → `[[0; 0]; [0; 1]]` ;
on ne peut pas poser `1`. Résultat `[[0; 0]; [0; 1]]`.

**Pièges**
- `mots 3` → `[[0; 0; 0]; [0; 0; 1]; [0; 1; 0]; [1; 0; 0]; [1; 0; 1]]` (5 mots, dans l'ordre lexicographique).
- `List.map (fun n -> List.length (mots n)) [0; 1; 2; 3; 4; 5]` → `[1; 2; 3; 5; 8; 13]` : la suite de Fibonacci.
- `mots 0` → `[[]]` (le mot vide) ; `mots 1` → `[[0]; [1]]`.
- Le paramètre `dernier = 0` au départ signifie « pas de contrainte » : un `1` en première position est permis.

---

## 19. Parties d'une liste et combinaisons

**Énoncé** : tous les sous-ensembles d'une liste, puis seulement ceux de taille `k` (l'ordre des éléments est conservé).

```ocaml
let rec parties (l : 'a list) : 'a list list =
  match l with
  | [] -> [[]]
  | x :: r -> let p = parties r in p @ List.map (fun s -> x :: s) p

let rec combinaisons (k : int) (l : 'a list) : 'a list list =
  if k = 0 then [[]]
  else
    match l with
    | [] -> []
    | x :: r ->
      List.map (fun c -> x :: c) (combinaisons (k - 1) r) @ combinaisons k r
```

**Trace** `parties [1; 2]` : `parties [2]` = `[[]; [2]]` ; on garde ces parties **sans** `1`, puis on leur ajoute `1` en tête :
`[[]; [2]] @ [[1]; [1; 2]]` = `[[]; [2]; [1]; [1; 2]]`.
`combinaisons 2 [1; 2; 3]` : avec `1` : `1 ::` chaque élément de `combinaisons 1 [2; 3]` = `[[2]; [3]]` → `[[1; 2]; [1; 3]]` ; sans `1` : `combinaisons 2 [2; 3]` = `[[2; 3]]`.

**Pièges**
- `parties [1; 2; 3]` → `[[]; [3]; [2]; [2; 3]; [1]; [1; 3]; [1; 2]; [1; 2; 3]]` ; `parties []` → `[[]]` ; `List.length (parties [1; 2; 3; 4])` → `16`.
- `combinaisons 2 [1; 2; 3]` → `[[1; 2]; [1; 3]; [2; 3]]` ; `combinaisons 2 [1; 2; 3; 4]` a `6` éléments ; `combinaisons 4 [1; 2; 3]` → `[]`.
- `combinaisons 0 [1; 2]` → `[[]]` (une façon de ne rien choisir) ; `combinaisons (-1) [1]` → `[]`.
- `parties [[1]; [2]]` → `[[]; [[2]]; [[1]]; [[1]; [2]]]` : une liste de listes de listes.

---

## 20. Cases d'une grille et voisins

**Énoncé** : lister les cases d'une grille `w × h` (ligne par ligne), trouver les voisins orthogonaux valides d'une case, fabriquer un damier.

```ocaml
let cases (w : int) (h : int) : (int * int) list =
  List.concat_map (fun y -> List.init w (fun x -> (x, y))) (List.init h Fun.id)

let voisins (w : int) (h : int) ((x, y) : int * int) : (int * int) list =
  List.filter (fun (a, b) -> a >= 0 && a < w && b >= 0 && b < h)
    [(x - 1, y); (x + 1, y); (x, y - 1); (x, y + 1)]

let damier (w : int) (h : int) : bool list list =
  List.init h (fun y -> List.init w (fun x -> (x + y) mod 2 = 0))
```

**Trace** `voisins 3 3 (0, 0)` : candidats `(-1, 0)`, `(1, 0)`, `(0, -1)`, `(0, 1)` ; le filtre rejette ceux qui ont une coordonnée négative :
reste `[(1, 0); (0, 1)]`.

**Pièges**
- `cases 2 2` → `[(0, 0); (1, 0); (0, 1); (1, 1)]` : `x` varie le plus vite (la boucle intérieure est sur `x`) ; `cases 0 5` → `[]` ; `List.length (cases 3 4)` → `12`.
- `voisins 3 3 (1, 1)` → `[(0, 1); (2, 1); (1, 0); (1, 2)]` (4 voisins, dans l'ordre de la liste de candidats) ; `voisins 1 1 (0, 0)` → `[]` ; `voisins 3 3 (5, 5)` → `[]` (case elle-même hors grille : le filtre ne la rejette pas, seuls ses voisins sont testés).
- `damier 3 2` → `[[true; false; true]; [false; true; false]]` ; `List.map rendre (damier 3 2)` → `["#.#"; ".#."]` (avec `rendre` de l'exemple 12).
- `List.init 3 Fun.id` → `[0; 1; 2]` ; `List.init 0 Fun.id` → `[]`.

---

### Rappels rapides pour le QCM

- Une fonction mémoïsée sans effet secondaire **retourne** son cache avec son résultat ; il faut enfiler le **dernier** cache d'un appel au suivant.
- `fold_left` parcourt de gauche à droite, `fold_right` de droite à gauche : le sens change l'ordre d'application des fonctions et la position des séparateurs.
- Un facteur est contigu ; une sous-suite ne l'est pas.
- Toute énumération récursive a un cas de base qui retourne `[[]]` (un élément : le choix vide), pas `[]` (aucun élément).
- Une récursion sur `n` sans test `n <= 0` ne termine pas pour `n` négatif.
