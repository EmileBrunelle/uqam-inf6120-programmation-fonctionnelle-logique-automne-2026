# Revue Adversariale : Examen 1 (OCaml)

Ce document complète vos fiches de révision en exposant les **pièges exacts et cas pratiques** tirés de l'Intra de l'été 2024 et du Labo 06. Le format a été optimisé pour être facilement consultable (Ctrl+F) la veille de l'examen.

## Sommaire rapide
1. [Shadowing profond par paramètres (Q4)](#1-shadowing-profond-par-parametres-q4)
2. [La restriction stricte de `function` (Q3)](#2-la-restriction-stricte-de-function-q3)
3. [Gymnastique d'évaluation mentale (Q5)](#3-gymnastique-devaluation-mentale-q5)
4. [Types `Option` et `Result` (Labo 06)](#4-types-option-et-result-labo-06)
5. [Filtrage de motifs sur AST (Q9)](#5-filtrage-de-motifs-sur-ast-q9)
6. [Induction mathématique vs structurelle (Q12)](#6-induction-mathematique-vs-structurelle-q12)

---

## 1. Shadowing profond par paramètres (Q4)
**Mots-clés :** `shadowing`, `masquage`, `portée lexicale`, `fun`, `fermeture`, `paramètre`

Vos fiches expliquent bien le *shadowing* (masquage) avec des liaisons locales (`let x = ... in let x = ...`). L'examen corse la difficulté en utilisant des fermetures imbriquées.

**L'énoncé de l'examen :** Évaluer `let f = fun x -> (fun y -> (fun x -> (x, y))) in f 1 2 3`.

> [!WARNING]
> **La trace mentale :**
> - L'appel `f 1` lie le premier `x` à `1`.
> - L'appel `f 1 2` lie `y` à `2`.
> - L'appel `f 1 2 3` lie le **deuxième `x` à `3`**.
> Le deuxième `x` masque définitivement le premier dans le corps de la dernière fonction. **Le résultat est `(3, 2)`** (et non `(1, 2)`). C'est un test impitoyable de portée lexicale.

---

## 2. La restriction stricte de `function` (Q3)
**Mots-clés :** `function`, `fun`, `sucre syntaxique`, `filtrage implicite`, `paramètre unique`

La Fiche 02 mentionne que `fun x y ->` est du sucre syntaxique pour une suite de `function`. L'examen exige de faire la traduction inverse exacte.

**L'énoncé de l'examen :** Réécrire `let f x y = x + (2 * y)` avec la forme `let f = function ??? -> ???`.

> [!IMPORTANT]
> **Le piège :** Le mot-clé `function` ne permet de définir une fonction **qu'à un seul argument** (il effectue un filtrage implicite sur cet unique argument). 
> **La bonne réponse :** `let f = function x -> function y -> x + (2 * y)` (ou alternativement `let f = function x -> fun y -> x + (2 * y)`). Vous ne pouvez pas écrire `function x y ->`.

---

## 3. Gymnastique d'évaluation mentale (Q5)
**Mots-clés :** `application partielle`, `map`, `filter`, `min`, `max`, `évaluation`

Vous devez être capable de simuler l'interpréteur OCaml dans votre tête sans vous tromper sur l'application partielle de fonctions standard.

**L'énoncé de l'examen :** Évaluer `List.filter (fun x -> x > 5) (List.map (min 7) [1; 2; 3; 4; 5; 6; 7; 8; 9; 10])`.

> [!TIP]
> **Comment ne pas trébucher :**
> 1. Analysez le `map` d'abord : l'application partielle `min 7` renvoie la plus petite valeur entre 7 et l'élément.
> 2. Pour les nombres > 7 (c.-à-d. 8, 9, 10), `min 7 x` renvoie `7`.
> 3. La liste intermédiaire devient : `[1; 2; 3; 4; 5; 6; 7; 7; 7; 7]`.
> 4. Le `filter (fun x -> x > 5)` s'applique et conserve : `[6; 7; 7; 7; 7]`.

---

## 4. Types `Option` et `Result` (Labo 06)
**Mots-clés :** `option`, `Some`, `None`, `result`, `Ok`, `Error`, `gestion d'erreurs`

Vos fiches principales traitent des listes, mais le Labo 06 montre que vous serez testé sur la gestion des erreurs fonctionnelles. OCaml préfère ces types algébriques pour éviter les exceptions et les *nulls*.

**Ce qu'il faut maîtriser :**
- **Type option :** Utilisé pour des recherches qui peuvent échouer (`find`, `lookup`).
  ```ocaml
  type 'a option = None | Some of 'a
  (* Exemple de filtrage *)
  match lookup k dict with
  | Some v -> v
  | None -> 0
  ```
- **Type result :** Utilisé pour des opérations pouvant échouer avec une raison (`convert`).
  ```ocaml
  type ('a, 'b) result = Ok of 'a | Error of 'b
  ```
  Soyez prêt à utiliser ces constructeurs dans vos `match`.

---

## 5. Filtrage de motifs sur AST (Q9)
**Mots-clés :** `AST`, `type algébrique`, `simplification`, `filtrage imbriqué`, `constructeur`

La Fiche 04 couvre le filtrage basique, mais l'examen vous demande de manipuler des Arbres de Syntaxe Abstraite (AST) avec des filtrages profonds.

**L'énoncé de l'examen :** Simplifier l'AST défini par `type expr = Plus of expr * expr | Minus of expr * expr | Num of int`. Il faut par exemple simplifier `0 + x` en `x`.

> [!NOTE]
> Il faut maîtriser le filtrage imbriqué pour attraper des sous-structures spécifiques directement dans le motif, plutôt que de faire des `if` dans les branches :
> ```ocaml
> let rec simplify e = match e with
> | Plus (Num 0, x) -> simplify x
> | Plus (x, Num 0) -> simplify x
> | Plus (x, y) -> Plus (simplify x, simplify y)
> | _ -> e
> ```

---

## 6. Induction mathématique vs structurelle (Q12)
**Mots-clés :** `preuve`, `induction mathématique`, `récursion`, `théorème`

Votre fiche 04 détaille l'induction *structurelle* (sur les constructeurs d'une liste ou d'un arbre). Toutefois, l'intra de l'été 2024 contient une preuve d'induction **mathématique classique sur un entier**.

**L'énoncé de l'examen :** Prouver que `exp x (m + n) = exp x m * exp x n` (par induction sur `m`).

> **Les 3 étapes exigées à rédiger :**
> 1. **Cas de base :** Définir le cas où `m = 0` et le prouver.
> 2. **Hypothèse d'induction (HI) :** Supposer que la propriété est vraie pour un `m` arbitraire (`exp x (m + n) = exp x m * exp x n`).
> 3. **Cas d'hérédité (Pas inductif) :** Prouver la propriété pour `m + 1` en utilisant l'HI et la définition de la fonction `exp`.
