(* Squelette : le main sert d'auto-test (`dune test`). *)

let rec somme = function [] -> 0 | x :: r -> x + somme r

let () =
  assert (somme [] = 0);
  assert (somme [ 1; 2; 3 ] = 6);
  print_endline "tp1 : ok"
