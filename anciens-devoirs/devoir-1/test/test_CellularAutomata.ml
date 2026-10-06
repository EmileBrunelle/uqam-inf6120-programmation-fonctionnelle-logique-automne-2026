(* Devoir 1 INF6120 (entraînement) — Émile Brunelle, code permanent à compléter
   Tests : tous les exemples de l'énoncé, plus quelques cas limites.
   Chaque test est un couple (nom, résultat booléen) ; on liste les
   échecs et on sort avec le code 1 s'il y en a (dune test devient rouge). *)

open Cellular_automata
open Tools
open Automata
open Bunches
open Evolutions
open Examples

(* Automate de l'exemple récurrent des parties 5 et 6. *)
let aut1 : int automata =
  set_value (set_value (create (fun (a, b, c) -> a + b + c) 0) 3 4) (-1) 2

(* Automate de Pascal de la partie 1 : f(a, b, c) = a + b. *)
let pascal : int automata = set_value (create (fun (a, b, _) -> a + b) 0) 0 1
let dot_star (x : int) : string = if x = 0 then "." else "*"
let wb_to_string (x : wb) : string = if x = Black then "*" else "."

let tools_tests : (string * bool) list =
  [
    ("interval 0 8", interval 0 8 = [ 0; 1; 2; 3; 4; 5; 6; 7; 8 ]);
    ("interval 2 5", interval 2 5 = [ 2; 3; 4; 5 ]);
    ("interval 3 3", interval 3 3 = [ 3 ]);
    ("interval -5 2", interval (-5) 2 = [ -5; -4; -3; -2; -1; 0; 1; 2 ]);
    ("interval 9 3", interval 9 3 = []);
    ("list_to_string int", list_to_string string_of_int [ 0; 1; 2 ] = "012");
    ("list_to_string vide", list_to_string string_of_int [] = "");
    ( "list_to_string bool",
      list_to_string string_of_bool [ true; false; true ] = "truefalsetrue" );
    ("list_to_string f", list_to_string dot_star [ 2; 0; 101; 0; 0 ] = "*.*..");
    ("compose_iter +1", compose_iter (fun x -> x + 1) 0 5 = [ 0; 1; 2; 3; 4; 5 ]);
    ( "compose_iter neg",
      compose_iter (fun x -> -x) 8 6 = [ 8; -8; 8; -8; 8; -8; 8 ] );
    ( "compose_iter ^",
      compose_iter (fun u -> u ^ "a") "b" 5
      = [ "b"; "ba"; "baa"; "baaa"; "baaaa"; "baaaaa" ] );
    ("compose_iter 0", compose_iter (fun u -> u) "a" 0 = [ "a" ]);
    ("prefix 1", is_prefix_lists [ 2; 1; 2; 3 ] [ 2; 1; 2; 3; 6; 2; 7 ]);
    ("prefix 2", is_prefix_lists [] [ 2; 1; 2; 3 ]);
    ("prefix 3", not (is_prefix_lists [ 2; 1 ] []));
    ("prefix 4", is_prefix_lists [] []);
    ("prefix 5", is_prefix_lists [ 'a'; 'b'; 'b' ] [ 'a'; 'b'; 'b' ]);
    ("prefix 6", not (is_prefix_lists [ 2; 1; 3 ] [ 2; 1; 2; 3; 6; 2; 7 ]));
    ("factor 1", is_factor_lists [ 2; 1; 3 ] [ 4; 2; 1; 3; 4 ]);
    ("factor 2", is_factor_lists [ 2; 1; 3 ] [ 2; 1; 3; 4 ]);
    ("factor 3", is_factor_lists [ 2; 1; 3 ] [ 4; 2; 1; 3 ]);
    ("factor 4", not (is_factor_lists [ 'a'; 'a' ] [ 'a'; 'b'; 'a' ]));
    ("factor 5", is_factor_lists [] [ 'a' ]);
    ("factor 6", is_factor_lists [] []);
    ("subword 1", is_subword_lists [ 1; 3; 5 ] [ 1; 2; 3; 4; 5 ]);
    ("subword 2", not (is_subword_lists [ 1; 5; 3 ] [ 1; 2; 3; 4; 5 ]));
    ("subword 3", is_subword_lists [ 'a'; 'b' ] [ 'a'; 'b'; 'c' ]);
    ("subword 4", is_subword_lists [] [ 'a' ]);
    ("subword 5", is_subword_lists [] []);
    ("dup 1", is_duplicate_free [ 1; 2; 3 ]);
    ("dup 2", not (is_duplicate_free [ 1; 2; 1 ]));
    ("dup 3", not (is_duplicate_free [ 1; 2; 1; 1; 2 ]));
    ("dup 4", is_duplicate_free [ 3 ]);
    ("dup 5", is_duplicate_free []);
  ]

let automata_tests : (string * bool) list =
  let a1 = create (fun (a, b, c) -> a + b + c) 0 in
  let a2 = create (fun (_, b, _) -> b) true in
  let a3 = set_value a1 16 4 in
  [
    ("create void int", a1.void = 0);
    ("create void bool", a2.void);
    ("create void string", (create (fun (a, b, c) -> a ^ b ^ c) "").void = "");
    ("get_value 0", get_value a1 0 = 0);
    ("get_value 1024", get_value a1 1024 = 0);
    ("get_value -2048", get_value a2 (-2048));
    ("set_value 15", get_value a3 15 = 0);
    ("set_value 16", get_value a3 16 = 4);
    ("set_value persistant", get_value a1 16 = 0);
  ]

let bunches_tests : (string * bool) list =
  let a = set_value aut1 5 9 in
  [
    ( "get_bunch_values",
      get_bunch_values aut1 (-2, 6) = [ 0; 2; 0; 0; 0; 4; 0; 0; 0 ] );
    ("to_string int", to_string aut1 (-2, 6) string_of_int = "020004000");
    ("to_string f", to_string aut1 (-2, 6) dot_star = ".*...*...");
    ("has_factor 1", has_factor a (1, 8) [ 4; 0; 9; 0 ]);
    ("has_factor 2", not (has_factor a (1, 5) [ 4; 0; 9; 0 ]));
    ("has_subword 1", has_subword a (1, 8) [ 4; 9 ]);
    ("has_subword 2", not (has_subword a (7, 8) [ 4; 9 ]));
  ]

let transformation_tests : (string * bool) list =
  let s a b = to_string a b string_of_int in
  [
    ("shift 3", s (shift aut1 3) (-2, 6) = "004000000");
    ("shift -4", s (shift aut1 (-4)) (-2, 6) = "000002000");
    ("shift -4 large", s (shift aut1 (-4)) (-2, 12) = "000002000400000");
    ("avant mirror", s aut1 (-8, 8) = "00000002000400000");
    ("mirror", s (mirror aut1) (-8, 8) = "00000400020000000");
    ("map", s (Automata.map (fun x -> x + 1) aut1) (-8, 8) = "11111113111511111");
    ( "evolution",
      s (evolution (set_value aut1 2 1)) (-8, 8) = "00000022215540000" );
    ("evolutions longueur", List.length (evolutions pascal 4) = 5);
    ( "evolutions_bunch Pascal",
      evolutions_bunch pascal (-1, 5) 4
      = [
          [ 0; 1; 0; 0; 0; 0; 0 ];
          [ 0; 1; 1; 0; 0; 0; 0 ];
          [ 0; 1; 2; 1; 0; 0; 0 ];
          [ 0; 1; 3; 3; 1; 0; 0 ];
          [ 0; 1; 4; 6; 4; 1; 0 ];
        ] );
    ( "string_representation",
      string_representation pascal (-1, 5) 4 string_of_int
      = "0100000\n0110000\n0121000\n0133100\n0146410" );
    ("resurgent (-1,-1)", is_resurgent pascal (-1, -1) 4);
    ("resurgent (-1,0)", is_resurgent pascal (-1, 0) 4);
    ("resurgent (-1,1)", not (is_resurgent pascal (-1, 1) 4));
  ]

let sierpinski_expected : string =
  String.concat "\n"
    [
      "00000000100000000";
      "00000001110000000";
      "00000010101000000";
      "00000110101100000";
      "00001000100010000";
      "00011101110111000";
      "00101000100010100";
      "01101101110110110";
      "10000000100000001";
    ]

let chaos_expected : string =
  String.concat "\n"
    [
      "........*........";
      ".......***.......";
      "......**..*......";
      ".....**.****.....";
      "....**..*...*....";
      "...**.****.***...";
      "..**..*....*..*..";
      ".**.****..******.";
      "**..*...***.....*";
    ]

(* f de l'énoncé, partie 8, pour vérifier que memo ne change pas le
   résultat. *)
let half_sum (x : int) (y : int) : int = (x + y) / 2

let example_tests : (string * bool) list =
  let f_mem = Memoization.memo half_sum in
  [
    ( "sierpinski",
      string_representation (set_value sierpinski 0 1) (-8, 8) 8 string_of_int
      = sierpinski_expected );
    ( "chaos",
      string_representation (set_value chaos 0 Black) (-8, 8) 8 wb_to_string
      = chaos_expected );
    ("memo 1 8", (half_sum 1 8, f_mem 1 8) = (4, 4));
    ("memo 10 20", (half_sum 10 20, f_mem 10 20) = (15, 15));
    (* Sans mémoïsation, 60 évolutions demanderaient ~3^60 appels : ce test
       ne termine en temps raisonnable que si Q8.2 est en place. *)
    ( "mémoïsation rapide (60 évolutions)",
      String.length
        (string_representation Memoization.aut (-8, 8) 60 string_of_int)
      = (61 * 17) + 60 );
  ]

let () =
  let tests =
    List.concat
      [
        tools_tests;
        automata_tests;
        bunches_tests;
        transformation_tests;
        example_tests;
      ]
  in
  let failures = List.filter (fun (_, ok) -> not ok) tests in
  List.iter (fun (name, _) -> Printf.printf "ÉCHEC : %s\n" name) failures;
  Printf.printf "%d/%d tests réussis\n"
    (List.length tests - List.length failures)
    (List.length tests);
  if failures <> [] then exit 1
