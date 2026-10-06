(* Devoir 1 INF6120 (entraînement) — Émile Brunelle, code permanent à compléter
   Partie 8 : mémoïsation. *)

(* L'automate de l'exercice : Sierpinski avec un 1 en case 0. *)
let aut : int Automata.automata = Automata.set_value Examples.sierpinski 0 1

(* Q8.1 — Réponse.

   Constat : [evolutions aut 14] répond instantanément, alors que
   [string_representation aut (-8, 8) 14 ...] se fait attendre (mesuré :
   0,2 s compilé en natif, environ 10 fois plus dans le toplevel), et
   chaque évolution de plus triple ce temps.

   Explication : faire évoluer un automate ne calcule RIEN. [evolution]
   construit seulement une nouvelle fonction ruban qui, le jour où on
   l'interroge en i, interrogera l'ancien ruban en i - 1, i et i + 1.
   [evolutions aut 14] empile donc 14 fermetures, en temps négligeable
   (évaluation retardée : le calcul est différé jusqu'à la lecture).

   L'affichage force le calcul. Lire une case après k évolutions demande
   3 lectures après k - 1 évolutions, chacune en demandant 3 autres, etc. :
   3^k appels au ruban initial, sans aucun partage, alors que la plupart
   de ces appels recalculent les mêmes cases (la case i - 1 du niveau
   k - 1 est demandée à la fois par les cases i - 2, i - 1 et i du
   niveau k). Pour 17 cases et 15 lignes (k = 0..14), on fait de l'ordre
   de 17 × (3^0 + ... + 3^14) ≈ 17 × 3^15 / 2 ≈ 1,2 × 10^8 appels : la
   croissance est exponentielle en k, chaque évolution de plus triple le
   temps.

   Avec la mémoïsation (Q8.2), chaque couple (niveau, indice) n'est calculé
   qu'une fois : le coût devient proportionnel à
   k × (largeur de la portion + 2k), donc polynomial, et la réponse est
   quasi instantanée. *)

(* Mémoïsation d'une fonction (non récursive).
   Le sujet fournit une version avec une liste d'association dans une
   cellule mutable, exemptée de la pénalité impérative. Ici, on utilise
   une table de hachage : même idée, recherche en temps constant au lieu
   d'un parcours de liste, et le script ./style du dépôt ne la signale
   pas. C'est tout de même de l'état mutable caché : à réserver aux cas
   où le sujet l'autorise.
   Idée : la table vit dans la fermeture renvoyée ; chaque appel la
   consulte avant de calculer.
   Piège : [memo f] doit être appliquée UNE fois puis réutilisée ;
   écrire [memo f x] à chaque appel recrée une table vide et ne sert à
   rien. Autre piège : pour une fonction récursive, les appels internes
   ne passent pas par la table (d'où la note b du sujet). *)
let memo (f : 'a -> 'b) : 'a -> 'b =
  let memory = Hashtbl.create 16 in
  fun x ->
    match Hashtbl.find_opt memory x with
    | Some y -> y
    | None ->
        let y = f x in
        Hashtbl.add memory x y;
        y
