open Labo6

let () =
  (* append / rev *)
  assert (append [ 1; 2 ] [ 3 ] = [ 1; 2; 3 ]);
  assert (append [] [ 1 ] = [ 1 ] && append [ 1 ] [] = [ 1 ]);
  assert (rev [ 1; 2; 3 ] = [ 3; 2; 1 ] && rev [] = ([] : int list));
  (* le théorème : rev (append xs ys) = append (rev ys) (rev xs) *)
  assert (
    rev (append [ 1; 2 ] [ 3; 4; 5 ]) = append (rev [ 3; 4; 5 ]) (rev [ 1; 2 ]));
  (* filter / combine *)
  let pair (x : int) : bool = x mod 2 = 0 and grand (x : int) : bool = x > 3 in
  let l : int list = [ 1; 2; 3; 4; 5; 6 ] in
  assert (filter pair l = [ 2; 4; 6 ]);
  assert (filter (fun _ -> true) l = l);
  assert (filter (combine pair grand) l = [ 4; 6 ]);
  assert (filter (combine pair grand) l = filter pair (filter grand l));
  assert (
    filter pair (append l [ 7; 8 ])
    = append (filter pair l) (filter pair [ 7; 8 ]));
  (* fold / sum *)
  assert (fold_left ( - ) 10 [ 1; 2; 3 ] = 4);
  assert (fold_right ( - ) [ 1; 2; 3 ] 10 = -8);
  assert (fold_left (fun acc x -> x :: acc) [] [ 1; 2; 3 ] = [ 3; 2; 1 ]);
  assert (sum l = 21 && sum [] = 0);
  assert (fold_left ( + ) 0 l = sum l && fold_right ( + ) l 0 = sum l);
  (* fold_left f init (append xs ys) = fold_left f (fold_left f init xs) ys *)
  assert (
    fold_left ( - ) 100 (append [ 1; 2 ] [ 3; 4 ])
    = fold_left ( - ) (fold_left ( - ) 100 [ 1; 2 ]) [ 3; 4 ]);
  (* shadowing *)
  assert (shadowing = 3 && shadowing_renomme = 3);
  (* RLE *)
  assert (
    compress [ 1; 1; 1; 2; 2; 4; 4; 4; 2; 1; 3; 3 ]
    = [ (3, 1); (2, 2); (3, 4); (1, 2); (1, 1); (2, 3) ]);
  assert (
    decompress [ (1, true); (2, false); (3, true) ]
    = [ true; false; false; true; true; true ]);
  assert (compress [] = ([] : (int * int) list));
  assert (compress [ 1; 1; 1; 2 ] = [ (3, 1); (1, 2) ]);
  List.iter
    (fun (l : int list) ->
      assert (decompress (compress l) = l);
      assert (compress_fold l = compress l);
      assert (decompress_fold (compress l) = l))
    [ []; [ 1 ]; [ 1; 1 ]; [ 1; 2; 1 ]; [ 5; 5; 5; 5; 0; 0; 5 ] ];
  assert (decompress_fold [ (2, 'a'); (1, 'b') ] = [ 'a'; 'a'; 'b' ]);
  (* find, filter_map *)
  assert (find (fun x -> x > 3) l = Some 4);
  assert (find (fun x -> x > 30) l = None);
  assert (exemple_filter_map = [ 0; 1; 2; 3 ]);
  assert (
    filter_map (fun x -> if x > 2 then Some (x * x) else None) l
    = [ 9; 16; 25; 36 ]);
  (* listes associatives *)
  let d : (string, int) dict = extend "c" 3 (extend "b" 7 (extend "a" 5 [])) in
  assert (lookup "a" d = Some 5 && lookup "z" d = None);
  assert (lookup "a" (extend "a" 99 d) = Some 99);
  assert (dict_max d = Some "b");
  assert (dict_max ([] : (string, int) dict) = None);
  assert (values d = [ 3; 7; 5 ]);
  assert (dict_sum d = 15);
  (* iterate *)
  assert (
    List.of_seq (Seq.take 5 (iterate (fun x -> x + 1) 0)) = [ 0; 1; 2; 3; 4 ]);
  assert (List.of_seq (Seq.take 4 (iterate (fun x -> 2 * x) 1)) = [ 1; 2; 4; 8 ]);
  (* convert *)
  assert (exemple_convert = [ "3"; "oups"; "5" ]);
  (* JSON : juste vérifier que les valeurs se construisent et se filtrent *)
  assert (
    match exemple_json_liste with
    | JList [ JString "foo"; _; _; _ ] -> true
    | _ -> false);
  assert (
    match exemple_json_dict with JDict [ (_, _); (_, _) ] -> true | _ -> false);
  (* Intra été 2024 *)
  assert (stirling 0 0 = 1 && stirling 3 0 = 0 && stirling 0 3 = 0);
  assert (stirling 3 3 = 1 && stirling 4 2 = 7 && stirling 5 2 = 15);
  assert (stirling 5 3 = 25);
  assert (f_q3 1 2 = 5);
  assert (q4 = (3, 2));
  assert (q5 = [ 6; 7; 7; 7; 7 ]);
  assert (length [ 1; 2; 3 ] = 3 && length_terminale [ 1; 2; 3 ] = 3);
  assert (length_terminale (List.init 1_000_000 (fun _ -> 0)) = 1_000_000);
  assert (is_increasing [] && is_increasing [ 1 ] && is_increasing [ 1; 2; 5 ]);
  assert ((not (is_increasing [ 1; 1 ])) && not (is_increasing [ 3; 2 ]));
  assert (count_files exemple_fs = 2);
  assert (simplify (Times (Num 1, Num 7)) = Num 7);
  assert (simplify (Times (Num 7, Num 1)) = Num 7);
  assert (simplify (Plus (Num 0, Num 4)) = Num 4);
  assert (simplify (Plus (Num 4, Num 0)) = Num 4);
  assert (simplify (Divide (Num 9, Num 1)) = Num 9);
  assert (simplify (Minus (Num 0, Num 5)) = Num (-5));
  assert (simplify (Minus (Num 5, Num 0)) = Num 5);
  assert (
    simplify (Minus (Num 0, Plus (Num 1, Num 2)))
    = Minus (Num 0, Plus (Num 1, Num 2)));
  (* imbriqué : les enfants d'abord *)
  assert (
    simplify (Plus (Num 0, Times (Num 1, Minus (Num 0, Num 3)))) = Num (-3));
  assert (count 1 [ 1; 2; 1; 3; 1 ] = 3 && count_fold 1 [ 1; 2; 1; 3; 1 ] = 3);
  assert (count 9 [] = 0 && count_fold 9 [] = 0);
  (let t : int Tsil.t = Tsil.(snoc (snoc (snoc nil 1) 2) 3) in
   assert (Tsil.length t = 3 && Tsil.length Tsil.nil = 0);
   assert (
     Tsil.map (fun x -> x * 10) t
     = Tsil.Snoc (Tsil.Snoc (Tsil.Snoc (Tsil.Nil, 10), 20), 30)));
  (* exp x (m + n) = exp x m * exp x n *)
  List.iter
    (fun (m : int) ->
      List.iter
        (fun (n : int) -> assert (exp 3 (m + n) = exp 3 m * exp 3 n))
        [ 0; 1; 2; 5 ])
    [ 0; 1; 2; 5 ];
  print_endline "labo6 : tous les tests passent"
