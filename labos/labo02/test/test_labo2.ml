open Labo2

let proche (x : float) (y : float) : bool = Float.abs (x -. y) < 1e-9

(* nombre de chiffres de n en base 2, et nombre de 1 *)
let rec chiffres (n : int) : int = if n = 0 then 0 else 1 + chiffres (n / 2)
let rec uns (n : int) : int = if n = 0 then 0 else (n mod 2) + uns (n / 2)

let () =
  assert (List.map fact [ 0; 1; 2; 3; 4; 5 ] = [ 1; 1; 2; 6; 24; 120 ]);
  assert (
    List.map fib [ 0; 1; 2; 3; 4; 5; 6; 7; 8; 9; 10; 11 ]
    = [ 0; 1; 1; 2; 3; 5; 8; 13; 21; 34; 55; 89 ]);
  assert (pgcd 1 1 = 1 && pgcd 20 30 = 10 && pgcd 77 34 = 1);
  assert (pgcd 0 7 = 7 && pgcd 12 12 = 12);
  assert (List.map (fun n -> ackermann n 1) [ 0; 1; 2; 3 ] = [ 2; 3; 5; 13 ]);
  assert (List.map (fun n -> ackermann n 2) [ 0; 1; 2; 3 ] = [ 3; 4; 7; 29 ]);
  assert (binom 0 0 = 1);
  assert (List.map (binom 4) [ 0; 1; 2; 3; 4 ] = [ 1; 4; 6; 4; 1 ]);
  assert (List.map (binom 3) [ 0; 1; 2; 3 ] = [ 1; 3; 3; 1 ]);
  assert (binom 2 5 = 0);
  assert binom_verifie;
  assert (
    List.map is_even [ 0; 1; 2; 3; 4; 5 ]
    = [ true; false; true; false; true; false ]);
  assert (
    List.map is_odd [ 0; 1; 2; 3; 4; 5 ]
    = [ false; true; false; true; false; true ]);
  assert (is_even 100000 && is_odd 100001);
  List.iter (fun n -> assert (fact n = fact' n)) [ 0; 1; 2; 10 ];
  List.iter (fun n -> assert (fib n = fib' n)) [ 0; 1; 2; 10 ];
  assert (fib' 80 = 23416728348467685);
  assert (exp' 2 10 = 1024 && exp 2 10 = 1024 && fast_exp 2 10 = 1024);
  assert (exp_nb 2 10 = (1024, 10));
  assert (fast_exp_nb 2 10 = (1024, 4));
  assert (fast_exp_nb 3 21 = (10460353203, 5));
  List.iter
    (fun n ->
      assert (exp 3 n = exp' 3 n && exp 3 n = fast_exp 3 n);
      assert (fst (exp_nb 3 n) = exp 3 n && snd (exp_nb 3 n) = n);
      assert (fst (fast_exp_nb 3 n) = exp 3 n);
      assert (snd (exp_mult 3 n) = n);
      assert (fst (fast_exp_mult 3 n) = exp 3 n);
      assert (snd (fast_exp_mult 3 n) = chiffres n + uns n))
    (List.init 30 Fun.id);
  assert (sum1 1 3 = 14 && sum1 0 10 = 440 && sum1 5 10 = 175 && sum1 5 3 = 0);
  assert (proche (sum2 0) 0.0 && proche (sum2 3) 1.5);
  assert (proche (sum2 5) 5.0 && proche (sum2 10) 22.5);
  assert (add 5 1 = 6 && addx 5 1 = 6 && add3 5 = 8 && (add 5) 1 = 6);
  print_endline "labo02 : tous les tests passent"
