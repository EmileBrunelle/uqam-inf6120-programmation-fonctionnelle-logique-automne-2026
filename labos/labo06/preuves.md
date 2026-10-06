# Labo 6 — Preuves (révision)

Toutes les preuves sont **par induction structurelle sur une liste** (ou sur
`m` pour la dernière). Recette : (1) choisir la variable sur laquelle la
fonction récurse, (2) cas de base `[]`, (3) cas `x :: t` avec l'hypothèse
d'induction (HI) sur `t`, (4) on déroule la définition, on applique la HI,
on conclut. Chaque étape cite sa raison : « déf. » = on dépliant la
définition, « HI » = hypothèse d'induction.

Définitions de référence :

```ocaml
let rec append l1 l2 = match l1 with [] -> l2 | h :: t -> h :: append t l2
let rec rev l = match l with [] -> [] | h :: t -> append (rev t) [h]
let rec filter p l = match l with
  | [] -> [] | h :: t -> if p h then h :: filter p t else filter p t
let combine f g = fun x -> f x && g x
let rec fold_left f acc l = match l with [] -> acc | h :: t -> fold_left f (f acc h) t
let rec fold_right f l init = match l with [] -> init | h :: t -> f h (fold_right f t init)
let rec sum l = match l with [] -> 0 | h :: t -> h + sum t
```

## Théorèmes sur append

**T1. `append [] xs = xs`.** Directement par la définition (premier cas du
`match`) : `append [] xs = xs`. Pas d'induction.

**T2. `append xs [] = xs`.** Induction sur `xs`.
- Base : `append [] [] = []` (déf.).
- Pas : supposons `append t [] = t` (HI).
  `append (h :: t) []` = `h :: append t []` (déf.) = `h :: t` (HI). ∎

*Piège* : T1 est gratuit, T2 non, car `append` récurse sur son premier
argument.

**Lemme (associativité) `append (append xs ys) zs = append xs (append ys zs)`.**
Induction sur `xs`.
- Base : `append (append [] ys) zs` = `append ys zs` (déf.) = `append [] (append ys zs)` (déf.).
- Pas : `append (append (h :: t) ys) zs` = `append (h :: append t ys) zs` (déf.)
  = `h :: append (append t ys) zs` (déf.) = `h :: append t (append ys zs)` (HI)
  = `append (h :: t) (append ys zs)` (déf.). ∎

**T3. `rev (append xs ys) = append (rev ys) (rev xs)`.** Induction sur `xs`.
- Base : `rev (append [] ys)` = `rev ys` (déf.). D'autre part
  `append (rev ys) (rev [])` = `append (rev ys) []` (déf. de rev) = `rev ys` (T2). ✔
- Pas : HI : `rev (append t ys) = append (rev ys) (rev t)`.
  `rev (append (h :: t) ys)` = `rev (h :: append t ys)` (déf. append)
  = `append (rev (append t ys)) [h]` (déf. rev)
  = `append (append (rev ys) (rev t)) [h]` (HI)
  = `append (rev ys) (append (rev t) [h])` (associativité)
  = `append (rev ys) (rev (h :: t))` (déf. rev). ∎

## Théorèmes sur filter

**T4. `filter (fun _ -> true) l = l`.** Induction sur `l`.
- Base : `filter _ [] = []`.
- Pas : `filter (fun _ -> true) (h :: t)` = `h :: filter (fun _ -> true) t`
  (le prédicat vaut `true`) = `h :: t` (HI). ∎

**T5. `filter (combine f g) l = filter f (filter g l)`** (pour des prédicats
totaux et sans effets secondaires). Induction sur `l`.
- Base : les deux côtés valent `[]`.
- Pas : HI : `filter (combine f g) t = filter f (filter g t)`. Quatre cas
  selon `f h` et `g h`.
  - `g h` vrai et `f h` vrai : à gauche, `combine f g h = true`, donc
    `h :: filter (combine f g) t`. À droite, `filter g (h :: t) = h :: filter g t`,
    puis `filter f` garde `h` : `h :: filter f (filter g t)`. Égaux par HI.
  - `g h` vrai, `f h` faux : à gauche, `combine = false`, donc
    `filter (combine f g) t`. À droite : `filter f (h :: filter g t)` =
    `filter f (filter g t)` (h rejeté). Égaux par HI.
  - `g h` faux (peu importe `f h`) : à gauche, `combine = false`
    (`f h && false`), donc `filter (combine f g) t`. À droite,
    `filter g (h :: t) = filter g t`, donc `filter f (filter g t)`. Égaux par HI. ∎

**T6. `filter f (append xs ys) = append (filter f xs) (filter f ys)`.**
Induction sur `xs`.
- Base : `filter f (append [] ys)` = `filter f ys` ; et
  `append (filter f []) (filter f ys)` = `append [] (filter f ys)` = `filter f ys`. ✔
- Pas : `filter f (append (h :: t) ys)` = `filter f (h :: append t ys)`.
  - Si `f h` : `h :: filter f (append t ys)` = `h :: append (filter f t) (filter f ys)` (HI)
    = `append (h :: filter f t) (filter f ys)` (déf. append)
    = `append (filter f (h :: t)) (filter f ys)`. ✔
  - Sinon : `filter f (append t ys)` = `append (filter f t) (filter f ys)` (HI)
    = `append (filter f (h :: t)) (filter f ys)` car `h` est rejeté. ∎

## Théorèmes sur fold

**T7. `fold_right (+) 0 xs = sum xs`.** Induction sur `xs`.
- Base : `fold_right (+) [] 0 = 0 = sum []`.
- Pas : `fold_right (+) (h :: t) 0` = `h + fold_right (+) t 0` (déf.)
  = `h + sum t` (HI) = `sum (h :: t)` (déf.). ∎

**T8. `fold_left (+) 0 xs = sum xs`.** L'induction directe échoue : dans le
pas on obtient `fold_left (+) (0 + h) t`, et la HI parle de `fold_left (+) 0 t`
(l'accumulateur a changé). On **généralise** :

> Lemme : pour tout `a` et tout `xs`, `fold_left (+) a xs = a + sum xs`.

Induction sur `xs`, `a` quelconque (la HI vaut pour tout accumulateur).
- Base : `fold_left (+) a [] = a = a + 0 = a + sum []`.
- Pas : `fold_left (+) a (h :: t)` = `fold_left (+) (a + h) t` (déf.)
  = `(a + h) + sum t` (HI avec l'accumulateur `a + h`)
  = `a + (h + sum t)` (associativité de +) = `a + sum (h :: t)`. ∎

Puis on instancie `a = 0` : `fold_left (+) 0 xs = 0 + sum xs = sum xs`. ∎

**T9. `fold_left f init (append xs ys) = fold_left f (fold_left f init xs) ys`.**
L'énoncé du site écrit `fold_left f init xs ++ fold_left f init ys`, ce qui
est **faux** en général (types incompatibles : le résultat est un `'b`, pas
une liste ; même pour `f = (+)`, `init = 1`, ça ferait compter `init` deux
fois). La bonne propriété est la ci-dessus : replier `xs`, puis continuer avec
le résultat sur `ys`. Induction sur `xs`, `init` quelconque.
- Base : `fold_left f init (append [] ys)` = `fold_left f init ys` ; et
  `fold_left f (fold_left f init []) ys` = `fold_left f init ys`. ✔
- Pas : `fold_left f init (append (h :: t) ys)` = `fold_left f init (h :: append t ys)`
  = `fold_left f (f init h) (append t ys)` (déf.)
  = `fold_left f (fold_left f (f init h) t) ys` (HI, accumulateur `f init h`)
  = `fold_left f (fold_left f init (h :: t)) ys` (déf.). ∎

## Q12 de l'intra : `exp x (m + n) = exp x m * exp x n`

```ocaml
let rec exp x n = if n = 0 then 1 else x * exp x (n - 1)
```

Induction sur `m` (pour `n ≥ 0` fixé et `x` quelconque).

1. **Cas à prouver** : `m = 0` (base) et `m = k + 1` (pas), en supposant
   la propriété pour `m = k`.
2. **Hypothèse d'induction** : `exp x (k + n) = exp x k * exp x n`.
3. **Preuve**
   - Base `m = 0` : `exp x (0 + n)` = `exp x n`. D'autre part
     `exp x 0 * exp x n` = `1 * exp x n` (déf., car n = 0) = `exp x n`. ✔
   - Pas `m = k + 1` : `(k + 1) + n = (k + n) + 1 ≠ 0`, donc
     `exp x ((k + 1) + n)` = `x * exp x (k + n)` (déf.)
     = `x * (exp x k * exp x n)` (HI)
     = `(x * exp x k) * exp x n` (associativité de *)
     = `exp x (k + 1) * exp x n` (déf. de `exp x (k + 1)`, car `k + 1 ≠ 0`). ∎
