# Révision Examen 1 : Théorie, λ-calcul et Pratique

Ce document cible les aspects critiques de la théorie (Chapitres 1 et 2) et applique ces concepts directement à des cas pratiques que vous retrouverez dans vos QCM.

---

## 1. Le λ-calcul et la β-réduction en pratique

Le λ-calcul est le modèle mathématique qui fonde la programmation fonctionnelle (contrairement à la machine de Turing pour l'impératif).

### Les 3 formes de base
1. **La variable :** `x`
2. **L'abstraction (fonction) :** `λx. t` (équivalent direct OCaml : `fun x -> t`)
3. **L'application (appel) :** `t u` (équivalent direct OCaml : `t u`)

### Pratique de la β-réduction (Bêta-réduction)
La β-réduction consiste à appliquer une fonction en remplaçant la variable par l'argument.
*Règle d'or : On ne remplace l'argument qu'une étape à la fois (un paramètre à la fois).*

**Exemple 1 : Évaluation simple**
*   Terme : `(λx. x * 2) 5`
*   β-réduction : on remplace `x` par `5`.
*   Résultat : `5 * 2 = 10`.

**Exemple 2 : Curryfication et fonctions à plusieurs paramètres**
Le λ-calcul ne prend **qu'un seul argument à la fois**. Pour faire `add(x,y)`, on écrit : `λx. (λy. x + y)`.
Évaluons `(λx. (λy. x + y)) 3 5` :
1.  Première β-réduction (sur `3`) : On remplace `x` par `3`. Le terme devient `(λy. 3 + y) 5`.
2.  Deuxième β-réduction (sur `5`) : On remplace `y` par `5`. Le terme devient `3 + 5`.
3.  Résultat final : `8`.

> 💡 **Le piège de l'examen :** Quand vous voyez `int -> int -> int` en OCaml, comprenez toujours `int -> (int -> int)`. L'application `add 3` renvoie `(λy. 3 + y)`. C'est **une nouvelle fonction**, pas une erreur.

---

## 2. Portée, Typage et Restriction aux valeurs (Pratique)

### A. La Portée Statique (Lexicale)
OCaml utilise une portée statique : une fonction capture les variables telles qu'elles sont définies **au moment de son écriture**, pas au moment de son appel.

**Exercice pratique :** Que retourne ce code ?
```ocaml
let x = 10
let f y = x + y
let x = 99
let () = print_int (f 5)
```
*   **Analyse :** La fonction `f` capture `x` au moment de sa définition (`x = 10`). Le `let x = 99` crée une nouvelle liaison qui masque l'ancienne pour la suite, mais la fermeture de `f` conserve le `10`.
*   **Résultat :** `15`. (Si OCaml utilisait la portée dynamique, le résultat serait `104`).

### B. Typage Fort et Statique
L'examen teste la compréhension des deux axes de typage :
*   **Statique/Dynamique (QUAND ?) :** Vérifié à la compilation (OCaml, Java) vs à l'exécution (Python, JS).
*   **Fort/Faible (COMMENT ?) :** Aucune conversion implicite (OCaml, Python) vs Conversions implicites (C, JS).

**Exemple d'examen :** 
L'évaluation de `1 = 1.0` 
*   **Mauvaise réponse :** `false`. 
*   **Bonne réponse :** *Erreur de typage à la compilation.* OCaml est fortement typé et exige que les deux opérandes de `=` soient du même type.

### C. La Restriction aux valeurs
Le polymorphisme (`'a`) est réservé aux **valeurs syntaxiques** (les `fun x -> x` ou constantes). Si l'expression est une **application** (un appel), elle reçoit un type faible (`'_weak1`).

**Exercice pratique :** Quel est le type de `(fun x -> x) (fun y -> y)` ?
*   **Analyse :** C'est une application de fonction. Le résultat ne sera pas généralisé.
*   **Bonne réponse :** `'_weak1 -> '_weak1`.
*   **Distracteur classique :** `'a -> 'a` (FAUX).

---

## 3. Pratique des Pièges Classiques de l'Examen

### L'Égalité Structurelle (`=`) vs Physique (`==`)
**Exemple pratique :** `[1; 2; 3] == [1; 2; 3]`
*   **Analyse :** `==` teste l'adresse mémoire (identité physique). Or, la notation `[...]` alloue de nouvelles listes en mémoire à chaque fois.
*   **Résultat :** `false`. (Utilisez `=` pour comparer le contenu structurel).

### La division
**Exemple pratique :** `7 / (-2)`
*   **Analyse :** La division entière OCaml tronque toujours **vers zéro**.
*   **Résultat :** `-3` (et non `-4` comme on l'aurait en Python avec `//` qui arrondit vers -∞).

### Identifier une Récursion Terminale (Tail-Call)
Pour qu'une fonction soit terminale, **rien ne doit rester à évaluer après le retour de l'appel récursif**.

**Exercice pratique :** Cette fonction est-elle terminale ?
```ocaml
let rec filter p l = match l with
| [] -> []
| x :: r -> if p x then x :: filter p r else filter p r
```
*   **Analyse :** Dans le cas `x :: filter p r`, après l'évaluation de `filter p r`, il reste l'opération `x :: ...` à exécuter pour construire la cellule de liste. La machine doit donc mémoriser ce contexte sur la pile.
*   **Résultat :** Non, ce n'est pas terminal. Pour la rendre terminale, il faudrait accumuler la liste en paramètre (ex: `acc_l`), puis inverser la liste à la fin avec `List.rev`.
