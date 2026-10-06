open Labo3

let () =
  let c r s = { rank = r; suit = s } in
  assert (card_compare (c (Num 5) Heart) (c (Num 5) Spade) = 0);
  assert (card_compare (c (Num 10) Club) (c Jack Club) = -1);
  assert (card_compare (c King Club) (c Queen Heart) = 1);
  assert (card_compare (c Jack Club) (c (Num 2) Club) = 1);
  let pi = acos (-1.0) in
  assert (surface (Rectangle (2., 3.)) = 6.);
  assert (Float.abs (surface (Circle 2.) -. (4. *. pi)) < 1e-9);
  assert (surface (Rhombus (4., 6.)) = 12.);
  assert (integers_1 8 = [ 8; 7; 6; 5; 4; 3; 2; 1; 0 ]);
  assert (integers_2 8 = [ 0; 1; 2; 3; 4; 5; 6; 7; 8 ]);
  assert (integers_3 8 = List.rev (integers_1 8));
  assert (integers_1_terminal 8 = integers_1 8);
  assert (size (integers_3 100_000) = 100_001);
  assert (size (integers_1_terminal 1_000_000) = 1_000_001);
  assert (three_or_more [] = false && three_or_more [ 1; 1; 1; 1; 1 ]);
  assert (not (three_or_more [ 1; 2 ]));
  assert (size [] = 0 && size [ 3; 1; 4; 5; 2 ] = 5);
  assert (last [ 1 ] = 1 && last [ 3; 1; 4; 5; 2 ] = 2);
  assert (
    try
      ignore (last []);
      false
    with EmptyList -> true);
  assert (is_increasing [] && not (is_increasing [ 3; 1; 4; 5; 2 ]));
  assert (is_increasing [ 1; 3; 5; 5; 7 ]);
  assert (even_odd [] && even_odd [ 1; 4; 3; 6; 9; 2 ]);
  assert (not (even_odd [ 2; 3; 3 ]));
  assert (even_odd [ 1 ] && (not (even_odd [ 2 ])) && even_odd [ -3; 2 ]);
  assert ((not (find 3 [])) && find 3 [ 1; 2; 3 ] && not (find 3 [ 2; 4; 6 ]));
  assert (member 3 [] = []);
  assert (member 3 [ 1; 2; 3; 4; 3; 5 ] = [ 3; 4; 3; 5 ]);
  assert (member 3 [ 2; 4; 6 ] = []);
  assert (member_last 3 [ 1; 2; 3; 4; 3; 5 ] = [ 3; 5 ]);
  assert (member_last 3 [ 2; 4; 6 ] = []);
  assert (member_last 3 [ 3 ] = [ 3 ]);
  assert (nb_occ 3 [] = 0 && nb_occ 3 [ 1; 2; 3; 4; 3; 5 ] = 2);
  assert (nb_occ 3 [ 2; 4; 6 ] = 0);
  assert (nth 3 [ 1; 2; 3; 4; 3; 5 ] = 3 && nth 3 [ 2; 4; 6 ] = 6);
  assert (nth 1 [ 7 ] = 7);
  assert (
    try
      ignore (nth 4 [ 2; 4; 6 ]);
      false
    with EmptyList -> true);
  assert (max_list [ 1; 2; 3; 0; 3; 0 ] = 3 && max_list [ 2; 4; 6 ] = 6);
  assert (
    try
      ignore (max_list []);
      false
    with EmptyList -> true);
  assert (nb_max [ 1; 2; 3; 0; 3; 0 ] = 2 && nb_max [ 2; 4; 6 ] = 1);
  assert (nb_max [ 5; 5; 1; 5 ] = 3);
  assert (average [ 5.; 8.5; 11.5; 15. ] = 10.);
  assert (
    try
      ignore (average []);
      false
    with EmptyList -> true);
  assert (size_in_range 0 0 [] && size_in_range 1 3 [ 0; 0 ]);
  assert (not (size_in_range 1 3 [ 0; 0; 0; 0 ]));
  assert (size_in_range 3 1 [ 0; 0 ]);
  assert (find_pattern [] [ 1; 2 ] && not (find_pattern [ 1; 1 ] [ 1; 2; 1 ]));
  assert (find_pattern [ 1; 1 ] [ 1; 2; 1; 1 ]);
  assert (list_copy [ 1; 2; 3 ] = [ 1; 2; 3 ] && list_copy [] = ([] : int list));
  let r = random_list 50 2 in
  assert (size r = 50 && List.for_all (fun x -> x = 0 || x = 1) r);
  assert (reverse [ 1; 2; 3 ] = [ 3; 2; 1 ] && reverse [] = ([] : int list));
  assert (
    flatten_list [ [ 1; 2 ]; []; [ 3; 4; 5 ]; [ 6 ] ] = [ 1; 2; 3; 4; 5; 6 ]);
  assert (fibo 10 = [ 0; 1; 1; 2; 3; 5; 8; 13; 21; 34 ] && fibo 0 = []);
  assert (
    without_duplicates [ 0; 0; 1; 2; 3; 3; 3; 3; 4; 5; 5; 6; 8; 8 ]
    = [ 0; 1; 2; 3; 4; 5; 6; 8 ]);
  assert (records [ 0; 2; 3; 2; 6; 3; 2; 7; 4; 8; 4 ] = [ 0; 2; 3; 6; 7; 8 ]);
  assert (records [] = []);
  assert (
    look_and_say 6
    = [
        [ 3; 1; 2; 2; 1; 1 ];
        [ 1; 1; 1; 2; 2; 1 ];
        [ 1; 2; 1; 1 ];
        [ 2; 1 ];
        [ 1; 1 ];
        [ 1 ];
      ]);
  assert (frequences [ 0; 0; 1; 1; 0; 1; 1; 0; 0; 0 ] = [ (0, 6); (1, 4) ]);
  let l =
    [
      58;
      37;
      58;
      72;
      19;
      58;
      18;
      41;
      58;
      86;
      94;
      59;
      92;
      35;
      40;
      47;
      92;
      6;
      42;
      95;
    ]
  in
  let sorted = List.sort compare l in
  let a, b = f_split l in
  assert (abs (size a - size b) <= 1 && List.sort compare (a @ b) = sorted);
  assert (f_merge [ 1; 4; 6 ] [ 2; 3; 7; 8 ] = [ 1; 2; 3; 4; 6; 7; 8 ]);
  assert (fusion_sort l = sorted && fusion_sort [] = []);
  assert (
    q_split l
    = ( List.filter (fun x -> x < 58) l,
        [ 58; 58; 58; 58 ],
        List.filter (fun x -> x > 58) l ));
  assert (q_merge [ 1 ] [ 2; 2 ] [ 3 ] = [ 1; 2; 2; 3 ]);
  assert (quick_sort l = sorted && quick_sort [] = []);
  let big = random_list 2000 100 in
  assert (fusion_sort big = List.sort compare big);
  assert (quick_sort big = List.sort compare big);
  print_endline "labo3 : ok"
