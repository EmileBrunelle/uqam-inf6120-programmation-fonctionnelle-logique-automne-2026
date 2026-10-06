(* Devoir 2 (INF6120, automne 2025) — solution d'entraînement.
   Auteur : Émile Brunelle — code permanent : à compléter.

   Les exemples utop de l'énoncé, transformés en assertions. Un échec
   arrête le programme avec la ligne fautive ; sinon on affiche « OK ». *)

open PolyominoGenerator

let sq1 : Squares.squares = Squares.make 0 1
let sq2 : Squares.squares = Squares.make 1 0
let sq3 : Squares.squares = Squares.make (-1) 2
let sq4 : Squares.squares = Squares.make (-2) 8
let p : Polyominos.polyominos = Polyominos.make [ sq1; sq2; sq3; sq4 ]

(* Polyomino des questions 4.8 et 4.9. *)
let q48 : Polyominos.polyominos =
  Polyominos.make
    Squares.[ make 0 0; make 1 0; make 2 0; make (-1) (-1); make 1 1 ]

(* Dessin de [build_random n] après [Random.init seed]. *)
let drawing (seed : int) (n : int) : string =
  Random.init seed;
  RandomGenerations.build_random n |> Polyominos.to_string

let () =
  (* Partie 3 *)
  assert (Squares.make 2 4 = Squares.Square (2, 4));
  assert (Squares.origin = Squares.Square (0, 0));
  assert (Squares.x_coordinate (Squares.make 2 4) = 2);
  assert (Squares.y_coordinate (Squares.make 2 4) = 4);
  (* Partie 4 *)
  let sorted = Squares.[ make (-2) 8; make (-1) 2; make 0 1; make 1 0 ] in
  assert (
    Polyominos.make [ sq1; sq2; sq2; sq1; sq4; sq3; sq4 ]
    = Polyominos.Polyomino sorted);
  assert (Polyominos.origin = Polyominos.Polyomino [ Squares.origin ]);
  assert (Polyominos.squares p = sorted);
  assert (Polyominos.is_filled_square sq1 p);
  assert (not (Polyominos.is_filled_square (Squares.make 0 2) p));
  assert (Polyominos.area p = 4);
  assert (
    Polyominos.add_square (Squares.make 0 3) p
    = Polyominos.Polyomino
        Squares.[ make (-2) 8; make (-1) 2; make 0 1; make 0 3; make 1 0 ]);
  assert (Polyominos.add_square sq2 p = p);
  assert (
    Polyominos.bounding_box p = Some (Squares.make (-2) 0, Squares.make 1 8));
  assert (Polyominos.bounding_box (Polyominos.make []) = None);
  assert (Polyominos.to_string q48 = "··O·\n·XOO\nO···");
  assert (
    Polyominos.to_prolog q48
    = "/*\n··O·\n·XOO\nO···\n*/\n\n" ^ "filled(square(-1, -1)).\n"
      ^ "filled(square(0, 0)).\n" ^ "filled(square(1, 0)).\n"
      ^ "filled(square(1, 1)).\n" ^ "filled(square(2, 0)).");
  (* Partie 5 *)
  let s03 = Squares.make 0 3 in
  assert (RandomGenerations.adjacent_square s03 Up = Squares.make 0 4);
  assert (RandomGenerations.adjacent_square s03 Down = Squares.make 0 2);
  assert (RandomGenerations.adjacent_square s03 Left = Squares.make (-1) 3);
  assert (RandomGenerations.adjacent_square s03 Right = Squares.make 1 3);
  assert (drawing 0 12 = "OOO·\n·OOO\n·O·O\nOO··\nOX··");
  assert (drawing 1 12 = "·OO··\n·OO··\n·OOOX\nOO···\nOO···");
  assert (
    drawing 0 64
    = String.concat "\n"
        [
          "··············O··";
          "············OOOO·";
          "············OOOOO";
          "············OOOOO";
          "···O···OOOOOOO···";
          "··OO·OOO···OOX···";
          "··O··OO··········";
          "··O··O···········";
          "··OOOO···········";
          "··OOOO···········";
          "·OOOOO···········";
          "·OOOOO···········";
          "OOOOOO···········";
          "·O·OOO···········";
        ]);
  assert (RandomGenerations.build_random 1 = Polyominos.origin);
  print_endline "OK : tous les exemples de l'énoncé passent."
