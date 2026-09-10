(* Squelette : le main sert d'auto-test (`dune test`).
   Les points d'arrêt ne tiennent que sur un corps de fonction — le code
   d'initialisation d'un module ne produit pas d'événement de débogage. *)

let rec somme lst =
  match lst with
  | [] -> 0
  | x :: reste ->
      let suite = somme reste in
      x + suite

let () =
  assert (somme [] = 0);
  assert (somme [ 1; 2; 3 ] = 6);
  print_endline "tp1 : ok"
