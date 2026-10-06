(* Devoir 2 (INF6120, automne 2025) — solution d'entraînement.
   Auteur : Émile Brunelle — code permanent : à compléter.

   Partie 6 : programme principal.
   Usage : dune exec PolyominoGenerator AIRE [GRAINE] *)

open PolyominoGenerator

(* Le fichier produit, relatif au répertoire courant (celui de Run.sh). *)
let output_path : string = "Prolog/Polyomino.pl"

(* Contenu complet du fichier : en-tête (aire, graine), puis [to_prolog].
   Le « \n » final rend le fichier propre (dernière ligne terminée). *)
let file_content (n : int) (seed : int) (poly : Polyominos.polyominos) : string
    =
  Printf.sprintf "/*\nArea: %d\nSeed: %d\n*/\n\n%s\n" n seed
    (Polyominos.to_prolog poly)

(* Génère, écrit le fichier (écrasé s'il existe : [open_out] tronque) et
   affiche le même contenu. [Out_channel.with_open_text] ferme le canal
   même en cas d'exception : pas de [close_out] oublié.
   Piège : la graine doit être posée AVANT [build_random]. *)
let run (n : int) (seed : int) : unit =
  Random.init seed;
  let content = file_content n seed (RandomGenerations.build_random n) in
  Out_channel.with_open_text output_path (fun oc ->
      Out_channel.output_string oc content);
  print_string content

(* Graine par défaut imposée. Attention aux parenthèses : [|>] a une
   priorité plus faible que [mod]. *)
let default_seed () : int = (Unix.time () |> int_of_float) mod 1048576

(* Analyse des arguments par filtrage sur la LISTE des arguments
   ([Sys.argv] est un tableau : on le convertit tout de suite, le style du
   cours proscrit de manipuler des tableaux). [int_of_string_opt] évite une
   exception sur « abc » ; une aire < 1 est refusée.
   Piège : [Sys.argv] contient le nom du programme en premier élément. *)
let () =
  let positive (s : string) : int option =
    match int_of_string_opt s with Some n when n >= 1 -> Some n | _ -> None
  in
  match Sys.argv |> Array.to_list with
  | [ _; n ] -> (
      match positive n with
      | Some n -> run n (default_seed ())
      | None -> prerr_endline "Erreur : l'aire doit être un entier >= 1.")
  | [ _; n; s ] -> (
      match (positive n, int_of_string_opt s) with
      | Some n, Some seed -> run n seed
      | _ -> prerr_endline "Erreur : aire (entier >= 1) puis graine (entier).")
  | _ -> prerr_endline "Usage : PolyominoGenerator AIRE [GRAINE]"
