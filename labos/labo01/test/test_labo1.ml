open Labo1

let proche (x : float) (y : float) : bool = Float.abs (x -. y) < 1e-9
let pi = acos (-1.0)

let () =
  assert (proche (aire_disque 1.0) pi);
  assert (proche (aire_disque 2.0) (4.0 *. pi));
  (let p, a, v = cylindre 1.0 2.0 in
   assert (proche p (2.0 *. pi));
   assert (proche a (6.0 *. pi));
   assert (proche v (2.0 *. pi)));
  assert (maximum 3 7 = 7 && maximum 7 3 = 7 && maximum 4 4 = 4);
  assert (minimum3 1 2 3 = 1 && minimum3 3 1 2 = 1 && minimum3 2 3 1 = 1);
  assert (minimum3 (-5) 0 5 = -5);
  assert (etiquette 9 = "small" && etiquette 10 = "large");
  assert (
    List.map plafond_moitie [ 0; 1; 2; 3; 4; -1; -2; -3; -4 ]
    = [ 0; 1; 1; 2; 2; 0; -1; -1; -2 ]);
  assert (expression 3 5 6 = 10 && expression 3 5 7 = 9);
  assert (expression (-4) 2 3 = 17);
  assert (double 21 = 42 && double (-3) = -6);
  assert (average 1 2 3 = 2 && average 1 2 4 = 2);
  assert (proche (average_float 1.0 2.0 4.0) (7.0 /. 3.0));
  assert (implies false false && implies false true && implies true true);
  assert (not (implies true false));
  assert (inv_fst_snd (1, "a") = ("a", 1) && inv (1, "a") = ("a", 1));
  assert (inv_int (1, 2) = (2, 1));
  assert (f_one () = 1);
  assert (sign (-7) = -1 && sign 0 = 0 && sign 9 = 1);
  print_endline "labo01 : tous les tests passent"
