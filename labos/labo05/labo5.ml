(* Laboratoire 5 : arbres binaires (résolution commentée pour la révision).

   Recette générale pour TOUTE fonction sur un arbre :
   - un `match` à deux cas : `Leaf` (cas de base) et `Node (v, g, d)` ;
   - on suppose que la fonction marche sur `g` et `d` (hypothèse d'induction,
     la même que pour les listes) et on recombine avec `v`.
   Piège typique : oublier le cas `Leaf`, ou mal choisir sa valeur de base
   (0 pour une somme ou un compte, [] pour une liste, true pour un « tous »). *)

(* Un arbre est soit vide (une feuille), soit un nœud portant un entier et
   deux sous-arbres. Les feuilles ne portent PAS de valeur. *)
type bintree = Leaf | Node of int * bintree * bintree

(* L'arbre de l'énoncé, reconstitué à partir des sorties attendues
   (par exemple `bintree_double example_tree`). Ses nœuds internes, en
   préfixe : 2; 2; 6; 5; 6; 4; 1; 2. *)
let example_tree : bintree =
  Node
    ( 2,
      Node (2, Leaf, Node (6, Node (5, Leaf, Leaf), Node (6, Leaf, Leaf))),
      Node (4, Leaf, Node (1, Node (2, Leaf, Leaf), Leaf)) )

(* ---------- Compter ---------- *)

(* Idée : une feuille compte 1 ; un nœud vaut la somme de ses deux côtés.
   Piège : ne pas ajouter 1 pour le nœud lui-même (il n'est pas une feuille). *)
let rec bintree_count_leaves (t : bintree) : int =
  match t with
  | Leaf -> 1
  | Node (_, g, d) -> bintree_count_leaves g + bintree_count_leaves d

(* Idée : l'inverse. Cas de base 0 ; chaque nœud compte 1 en plus des côtés. *)
let rec bintree_count_internal_nodes (t : bintree) : int =
  match t with
  | Leaf -> 0
  | Node (_, g, d) ->
      1 + bintree_count_internal_nodes g + bintree_count_internal_nodes d

(* Nœuds = internes + feuilles (les feuilles comptent ici comme des nœuds,
   d'où 17 = 8 + 9). *)
let bintree_count_nodes (t : bintree) : int =
  bintree_count_internal_nodes t + bintree_count_leaves t

(* Idée : une arête droite entre deux nœuds internes existe quand le fils
   droit est lui-même un `Node`. On regarde le fils (un match imbriqué) puis
   on récurse des deux côtés. Piège : une arête vers une feuille ne compte
   pas ; il faut compter l'arête, pas le nœud. *)
let rec bintree_count_right (t : bintree) : int =
  match t with
  | Leaf -> 0
  | Node (_, g, d) ->
      let arete : int = match d with Leaf -> 0 | Node _ -> 1 in
      arete + bintree_count_right g + bintree_count_right d

(* Symétrique de la précédente, avec le fils gauche. *)
let rec bintree_count_left (t : bintree) : int =
  match t with
  | Leaf -> 0
  | Node (_, g, d) ->
      let arete : int = match g with Leaf -> 0 | Node _ -> 1 in
      arete + bintree_count_left g + bintree_count_left d

(* ---------- Propriétés ---------- *)

(* Idée : 1 + le plus haut des deux côtés. Cas de base : une feuille a
   hauteur 0 (c'est ce qui donne 4 pour l'exemple : la racine est à
   profondeur 0 et ses feuilles les plus basses à profondeur 4).
   Piège : écrire `+` au lieu de `max`. *)
let rec bintree_height (t : bintree) : int =
  match t with
  | Leaf -> 0
  | Node (_, g, d) -> 1 + max (bintree_height g) (bintree_height d)

(* Idée : deux arbres sont miroirs si leurs formes se correspondent en
   croisant : gauche de l'un avec droite de l'autre. On ignore les valeurs
   (`_`). Cas de base : deux feuilles. Piège : le cas `Leaf` contre `Node`
   (dans un sens ou l'autre) doit donner false ; le `_, _` final l'attrape. *)
let rec bintree_is_mirror (t1 : bintree) (t2 : bintree) : bool =
  match (t1, t2) with
  | Leaf, Leaf -> true
  | Node (_, g1, d1), Node (_, g2, d2) ->
      bintree_is_mirror g1 d2 && bintree_is_mirror d1 g2
  | _, _ -> false

(* Symétrique = miroir de soi-même : il suffit de comparer les deux
   sous-arbres de la racine (c'est équivalent à `is_mirror t t`). *)
let bintree_is_symmetric (t : bintree) : bool =
  match t with Leaf -> true | Node (_, g, d) -> bintree_is_mirror g d

(* ---------- Visiter ---------- *)

(* Préfixe : la racine d'abord, puis le gauche, puis le droit.
   Piège : `@` est en O(taille de la liste de gauche) ; acceptable ici. *)
let rec bintree_visit_pre (t : bintree) : int list =
  match t with
  | Leaf -> []
  | Node (v, g, d) -> (v :: bintree_visit_pre g) @ bintree_visit_pre d

(* Suffixe : gauche, droit, puis la racine À LA FIN. *)
let rec bintree_visit_post (t : bintree) : int list =
  match t with
  | Leaf -> []
  | Node (v, g, d) -> bintree_visit_post g @ bintree_visit_post d @ [ v ]

(* Infixe : gauche, racine, droit. Sur un arbre de recherche, donne la
   liste TRIÉE (bon truc d'examen). *)
let rec bintree_visit_in (t : bintree) : int list =
  match t with
  | Leaf -> []
  | Node (v, g, d) -> bintree_visit_in g @ (v :: bintree_visit_in d)

(* Les noms de l'énoncé (texte) ; les exemples utilisent `bintree_visit_*`. *)
let bintree_pre : bintree -> int list = bintree_visit_pre
let bintree_post : bintree -> int list = bintree_visit_post
let bintree_in : bintree -> int list = bintree_visit_in

(* ---------- Collectionner ---------- *)

(* « Ordre quelconque » : le préfixe fait l'affaire. *)
let bintree_collect_values (t : bintree) : int list = bintree_visit_pre t

(* Idée : on descend en décrémentant le niveau ; à 0, on est au bon niveau
   et on prend la valeur du nœud (sans descendre plus bas). Cas de base :
   feuille -> [] (niveau inexistant, comme le niveau 4 de l'exemple).
   Piège : ne pas continuer à descendre une fois le niveau 0 atteint. *)
let rec bintree_collect_level (t : bintree) (niveau : int) : int list =
  match t with
  | Leaf -> []
  | Node (v, g, d) ->
      if niveau = 0 then [ v ]
      else
        bintree_collect_level g (niveau - 1)
        @ bintree_collect_level d (niveau - 1)

(* Idée : chaque feuille doit savoir de quel côté elle pend, donc la
   fonction auxiliaire reçoit l'orientation de l'arête qu'on vient de
   suivre (0 = gauche, 1 = droite). Une feuille produit son orientation ;
   un nœud transmet 0 au gauche et 1 au droit. Piège : la racine seule
   (`Leaf`) n'a pas d'orientation, on renvoie []. *)
let bintree_collect_canopy (t : bintree) : int list =
  let rec aux (orientation : int) (t : bintree) : int list =
    match t with Leaf -> [ orientation ] | Node (_, g, d) -> aux 0 g @ aux 1 d
  in
  match t with Leaf -> [] | Node (_, g, d) -> aux 0 g @ aux 1 d

(* ---------- Rechercher (arbre binaire de recherche) ---------- *)

(* Idée : comparer à la racine, descendre du bon côté, et à la feuille
   créer le nouveau nœud. Les doublons sont ignorés (l'énoncé met les
   valeurs égales ni à gauche ni à droite : « inférieur » / « strictement
   supérieur » ; on choisit l'ensemble sans répétition).
   Piège : reconstruire le nœud avec le sous-arbre modifié, les arbres sont
   immuables. *)
let rec bintree_insert (t : bintree) (x : int) : bintree =
  match t with
  | Leaf -> Node (x, Leaf, Leaf)
  | Node (v, g, d) ->
      if x < v then Node (v, bintree_insert g x, d)
      else if x > v then Node (v, g, bintree_insert d x)
      else t

(* Idée : même descente ; trouvé -> true, feuille -> false. *)
let rec bintree_search (t : bintree) (x : int) : bool =
  match t with
  | Leaf -> false
  | Node (v, g, d) ->
      if x = v then true
      else if x < v then bintree_search g x
      else bintree_search d x

(* ---------- Modifier ---------- *)

(* Version directe : on reconstruit la même forme avec 2 * v. *)
let rec bintree_double_direct (t : bintree) : bintree =
  match t with
  | Leaf -> Leaf
  | Node (v, g, d) ->
      Node (2 * v, bintree_double_direct g, bintree_double_direct d)

(* Généralisation : la transformation devient un paramètre (ordre
   supérieur), comme `List.map`. Même forme, valeurs transformées. *)
let rec bintree_apply (t : bintree) (f : int -> int) : bintree =
  match t with
  | Leaf -> Leaf
  | Node (v, g, d) -> Node (f v, bintree_apply g f, bintree_apply d f)

(* Réécriture demandée : double = apply avec (fun x -> 2 * x). *)
let bintree_double (t : bintree) : bintree = bintree_apply t (fun x -> 2 * x)

(* Miroir : on échange les sous-arbres ET on miroite récursivement chacun.
   Piège : échanger sans récurser ne miroite que le premier niveau. *)
let rec bintree_mirror (t : bintree) : bintree =
  match t with
  | Leaf -> Leaf
  | Node (v, g, d) -> Node (v, bintree_mirror d, bintree_mirror g)

(* Idée : on calcule d'abord les sous-arbres transformés ; la valeur du
   nœud est alors v + (valeur à la racine de chaque sous-arbre transformé)
   puisque celle-ci contient déjà la somme de tout son sous-arbre.
   Piège : additionner les valeurs d'origine obligerait à reparcourir. *)
let bintree_sum_subtree (t : bintree) : bintree =
  let valeur_racine (t : bintree) : int =
    match t with Leaf -> 0 | Node (v, _, _) -> v
  in
  let rec aux (t : bintree) : bintree =
    match t with
    | Leaf -> Leaf
    | Node (v, g, d) ->
        let g' : bintree = aux g and d' : bintree = aux d in
        Node (v + valeur_racine g' + valeur_racine d', g', d')
  in
  aux t

(* ---------- Fonctions d'ordre supérieur ---------- *)

(* L'énoncé écrit `map_tree` puis `tree_map` ; l'exemple appelle
   `tree_map f t` (fonction d'abord, contrairement à bintree_apply). *)
let tree_map (f : int -> int) (t : bintree) : bintree = bintree_apply t f
let map_tree : (int -> int) -> bintree -> bintree = tree_map

(* Repli d'arbre : `fold_tree f x t` remplace chaque `Leaf` par `x` et
   chaque `Node (v, g, d)` par `f v (résultat de g) (résultat de d)`.
   Sur l'exemple : f 2 (f 2 x (f 6 ...)) (f 4 x ...) etc.
   Piège : `f` reçoit la valeur ET les DEUX résultats récursifs (pas les
   sous-arbres eux-mêmes). *)
let rec fold_tree (f : int -> 'a -> 'a -> 'a) (x : 'a) (t : bintree) : 'a =
  match t with
  | Leaf -> x
  | Node (v, g, d) -> f v (fold_tree f x g) (fold_tree f x d)

(* Compte des nœuds internes par repli : feuille -> 0 ; nœud -> 1 + les deux.
   (Même nom que plus haut dans l'énoncé ; suffixe _fold pour coexister.) *)
let bintree_count_internal_nodes_fold (t : bintree) : int =
  fold_tree (fun _ g d -> 1 + g + d) 0 t

(* Valeurs des nœuds internes par repli : feuille -> [] ; nœud -> v, puis
   les listes de gauche et de droite (ordre préfixe, comme l'énoncé). *)
let bintree_collect_internal_nodes (t : bintree) : int list =
  fold_tree (fun v g d -> (v :: g) @ d) [] t
