open Labo5

let t1 : bintree = Node (1, Leaf, Leaf)
let t12 : bintree = bintree_insert t1 2
let t123 : bintree = bintree_insert t12 3
let t120 : bintree = bintree_insert t12 0

let () =
  let ex = example_tree in
  (* Compter *)
  assert (bintree_count_leaves ex = 9);
  assert (bintree_count_internal_nodes ex = 8);
  assert (bintree_count_nodes ex = 17);
  assert (bintree_count_right ex = 4);
  assert (bintree_count_left ex = 3);
  assert (bintree_count_leaves Leaf = 1 && bintree_count_nodes Leaf = 1);
  (* Propriétés *)
  assert (bintree_height ex = 4);
  assert (bintree_height Leaf = 0);
  assert (bintree_is_mirror Leaf Leaf);
  assert (bintree_is_mirror (Node (1, Leaf, Leaf)) (Node (2, Leaf, Leaf)));
  assert (
    bintree_is_mirror
      (Node (1, Leaf, Node (3, Leaf, Leaf)))
      (Node (2, Node (4, Leaf, Leaf), Leaf)));
  assert (
    not
      (bintree_is_mirror
         (Node (1, Leaf, Node (3, Leaf, Leaf)))
         (Node (2, Leaf, Node (4, Leaf, Leaf)))));
  assert (bintree_is_symmetric Leaf);
  assert (bintree_is_symmetric (Node (1, Leaf, Leaf)));
  assert (
    bintree_is_symmetric (Node (1, Node (2, Leaf, Leaf), Node (2, Leaf, Leaf))));
  assert (
    bintree_is_symmetric (Node (1, Node (2, Leaf, Leaf), Node (3, Leaf, Leaf))));
  assert (not (bintree_is_symmetric (Node (1, Node (2, Leaf, Leaf), Leaf))));
  assert (not (bintree_is_symmetric ex));
  (* Collectionner *)
  assert (bintree_collect_values ex = [ 2; 2; 6; 5; 6; 4; 1; 2 ]);
  assert (bintree_collect_level ex 0 = [ 2 ]);
  assert (bintree_collect_level ex 1 = [ 2; 4 ]);
  assert (bintree_collect_level ex 2 = [ 6; 1 ]);
  assert (bintree_collect_level ex 3 = [ 5; 6; 2 ]);
  assert (bintree_collect_level ex 4 = []);
  assert (bintree_collect_canopy ex = [ 0; 0; 1; 0; 1; 0; 0; 1; 1 ]);
  assert (bintree_collect_canopy Leaf = []);
  assert (bintree_collect_canopy t1 = [ 0; 1 ]);
  (* Visiter *)
  assert (bintree_visit_pre ex = [ 2; 2; 6; 5; 6; 4; 1; 2 ]);
  assert (bintree_visit_post ex = [ 5; 6; 6; 2; 2; 1; 4; 2 ]);
  assert (bintree_visit_in ex = [ 2; 5; 6; 6; 2; 4; 2; 1 ]);
  assert (bintree_pre ex = bintree_visit_pre ex);
  assert (bintree_post ex = bintree_visit_post ex);
  assert (bintree_in ex = bintree_visit_in ex);
  (* Rechercher *)
  assert (bintree_insert Leaf 1 = Node (1, Leaf, Leaf));
  assert (t12 = Node (1, Leaf, Node (2, Leaf, Leaf)));
  assert (t123 = Node (1, Leaf, Node (2, Leaf, Node (3, Leaf, Leaf))));
  assert (t120 = Node (1, Node (0, Leaf, Leaf), Node (2, Leaf, Leaf)));
  assert (bintree_insert t120 1 = t120);
  assert (bintree_search t120 0 && bintree_search t120 1);
  assert (bintree_search t120 2 && not (bintree_search t120 3));
  assert (not (bintree_search Leaf 0));
  (* un ABR bien construit se parcourt en ordre croissant *)
  let abr : bintree =
    List.fold_left bintree_insert Leaf [ 5; 3; 8; 1; 4; 7; 9; 3 ]
  in
  assert (bintree_visit_in abr = [ 1; 3; 4; 5; 7; 8; 9 ]);
  (* Modifier *)
  let double_attendu : bintree =
    Node
      ( 4,
        Node (4, Leaf, Node (12, Node (10, Leaf, Leaf), Node (12, Leaf, Leaf))),
        Node (8, Leaf, Node (2, Node (4, Leaf, Leaf), Leaf)) )
  in
  assert (bintree_double_direct ex = double_attendu);
  assert (bintree_double ex = double_attendu);
  assert (
    bintree_apply ex (fun x -> x + 1)
    = Node
        ( 3,
          Node (3, Leaf, Node (7, Node (6, Leaf, Leaf), Node (7, Leaf, Leaf))),
          Node (5, Leaf, Node (2, Node (3, Leaf, Leaf), Leaf)) ));
  assert (
    bintree_mirror ex
    = Node
        ( 2,
          Node (4, Node (1, Leaf, Node (2, Leaf, Leaf)), Leaf),
          Node (2, Node (6, Node (6, Leaf, Leaf), Node (5, Leaf, Leaf)), Leaf)
        ));
  assert (bintree_mirror (bintree_mirror ex) = ex);
  assert (
    bintree_sum_subtree ex
    = Node
        ( 28,
          Node (19, Leaf, Node (17, Node (5, Leaf, Leaf), Node (6, Leaf, Leaf))),
          Node (7, Leaf, Node (3, Node (2, Leaf, Leaf), Leaf)) ));
  (* Ordre supérieur *)
  assert (tree_map (fun x -> x * 2) ex = double_attendu);
  assert (map_tree (fun x -> x * 2) ex = double_attendu);
  assert (bintree_count_internal_nodes_fold ex = 8);
  assert (bintree_collect_internal_nodes ex = [ 2; 2; 6; 5; 6; 4; 1; 2 ]);
  (* fold_tree : la hauteur et la somme s'expriment aussi par repli *)
  assert (fold_tree (fun _ g d -> 1 + max g d) 0 ex = bintree_height ex);
  assert (fold_tree (fun v g d -> v + g + d) 0 ex = 28);
  print_endline "labo5 : tous les tests passent"
