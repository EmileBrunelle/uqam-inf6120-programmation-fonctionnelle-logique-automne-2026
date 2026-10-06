open Labo4

let () =
  assert (f_sum square 2 3 = 13 && f_sum (fun x -> x + 1) 2 3 = 7);
  assert (f_sum_function square 2 3 = 13);
  assert (f1 2 3 = 5 && f2 (fun x -> x + 5) = 5 && f3 square 4 = 16);
  assert (f4 (fun x -> x + 1) 0 = 2 && f5 (fun h -> h 1) = 2);
  assert (squares = [ 9; 144; 9; 1600; 36; 16; 36; 0 ]);
  assert (doubles = [ 6; 24; 6; 80; 12; 8; 12; 0 ]);
  assert (make_list (fun () -> 0) 8 = [ 0; 0; 0; 0; 0; 0; 0; 0 ]);
  assert (make_list (fun () -> 0) 0 = []);
  assert (List.length random_bools = 64 && List.length random_ints = 16);
  assert (List.for_all (fun x -> 0 <= x && x < 128) random_ints);
  assert (longueurs = [ 6; 7; 8; 8; 9; 6; 8 ]);
  assert (
    List.map (fun s -> s) majuscules
    = [
        "WOMBAT";
        "AXOLOTL";
        "PANGOLIN";
        "SURICATE";
        "PARESSEUX";
        "QUOKKA";
        "LEMURIEN";
      ]);
  assert (en_minuscules = [ "pangolin"; "suricate"; "quokka"; "lemurien" ]);
  assert (
    longueur_paire = [ "Wombat"; "pangolin"; "suricate"; "quokka"; "lemurien" ]);
  assert (
    pair_impair
    = [
        (2, "pair");
        (5, "impair");
        (7, "impair");
        (3, "impair");
        (12, "pair");
        (4, "pair");
        (9, "impair");
        (2, "pair");
        (11, "impair");
      ]);
  assert (List.map List.length n_fois_n = entiers && n_fois_n <> []);
  assert (commence_par_s && not tous_2_mod_5);
  assert (sum [ 1; 2; 3 ] = 6 && sum [] = 0);
  assert (size [ 'a'; 'b' ] = 2 && size [] = 0);
  assert (last [ 1; 2; 3 ] = 3 && last [ 9 ] = 9);
  assert (
    try
      ignore (last []);
      false
    with EmptyList -> true);
  assert (nb_occ 3 [ 3; 1; 3 ] = 2 && nb_occ 3 [] = 0);
  assert (max_list [ 1; 7; 3 ] = 7);
  assert (
    try
      ignore (max_list []);
      false
    with EmptyList -> true);
  assert (average [ 1; 2; 3; 4 ] = 2.5);
  let pair x = x mod 2 = 0 in
  List.iter
    (fun f -> assert (f pair [] && f pair [ 2; 4 ] && not (f pair [ 2; 3 ])))
    [ my_for_all; my_for_all2; my_for_all3 ];
  assert (my_exists pair [ 1; 2 ] && not (my_exists pair [ 1; 3 ]));
  assert (not (my_exists pair []));
  assert (none pair [ 1; 3 ] && none pair [] && not (none pair [ 1; 2 ]));
  assert (not_all pair [ 2; 3 ] && not (not_all pair [ 2; 4 ]));
  assert (not (not_all pair []));
  assert (ordered ( < ) [ 1; 2; 3 ] && not (ordered ( < ) [ 1; 4; 3 ]));
  assert (ordered (fun x y -> x + y >= 1) [ 1; 4; -3; 6 ]);
  assert (not (ordered (fun x y -> x + y >= 1) [ 1; 4; -5; 6 ]));
  assert (ordered ( < ) [] && ordered ( < ) [ 5 ]);
  assert (filter2 ( < ) [ 2; 2; 3 ] [ 1; 4; 5 ] = [ (2, 4); (3, 5) ]);
  assert (perm [ 1; 2 ] = [ [ 1; 2 ]; [ 2; 1 ] ]);
  assert (
    perm [ 1; 2; 3 ]
    = [
        [ 1; 2; 3 ];
        [ 2; 1; 3 ];
        [ 2; 3; 1 ];
        [ 1; 3; 2 ];
        [ 3; 1; 2 ];
        [ 3; 2; 1 ];
      ]);
  assert (List.length (perm [ 1; 2; 3; 4 ]) = 24);
  assert (List.mem [ 1; 2; 3; 4 ] (perm [ 1; 2; 3; 4 ]));
  assert (List.length (List.sort_uniq compare (perm [ 1; 2; 3; 4; 5 ])) = 120);
  assert (perm [] = [ [] ]);
  print_endline "labo4 : ok"
