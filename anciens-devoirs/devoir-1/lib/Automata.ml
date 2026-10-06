(* Devoir 1 INF6120 (entraînement) — Émile Brunelle, code permanent à compléter
   Parties 4 et 6 : représentation et transformations des automates.

   Idée centrale : le ruban est bi-infini, donc on ne peut pas le stocker.
   On le représente par une FONCTION indice → valeur. Modifier le ruban,
   c'est construire une nouvelle fonction qui enveloppe l'ancienne : rien
   n'est muté, l'ancien automate reste intact (persistance). *)

type 'a automata = { ribbon : int -> 'a; evol : 'a * 'a * 'a -> 'a; void : 'a }

(* Q4.1 — Automate dont toutes les cases valent [void].
   Idée : le ruban est la fonction constante (fun _ -> void).
   Piège : { evol; void } est le raccourci de { evol = evol; void = void }
   (« punning ») ; tous les champs doivent être fournis. *)
let create (evol : 'a * 'a * 'a -> 'a) (void : 'a) : 'a automata =
  { ribbon = (fun _ -> void); evol; void }

(* Q4.2 — Valeur de la case [i] : il suffit d'appeler le ruban. *)
let get_value (aut : 'a automata) (i : int) : 'a = aut.ribbon i

(* Q6.4 (accesseur suggéré) — La fonction d'évolution de l'automate. *)
let evol (aut : 'a automata) : 'a * 'a * 'a -> 'a = aut.evol

(* Q4.3 — Nouvel automate où la case [i] vaut [x].
   Idée : nouvelle fonction qui répond x en i et délègue à l'ancien ruban
   ailleurs ; { aut with ... } copie les autres champs.
   Piège : appeler [get_value aut j] (l'ANCIEN automate) dans la fermeture,
   pas le nouveau, sinon récursion infinie. Chaque set_value ajoute une
   couche : une lecture traverse toutes les couches (coût linéaire). *)
let set_value (aut : 'a automata) (i : int) (x : 'a) : 'a automata =
  { aut with ribbon = (fun j -> if j = i then x else get_value aut j) }

(* Q6.1 — Décale le ruban de [k] pas vers la gauche.
   Idée : la nouvelle case i contient l'ancienne case i + k.
   Piège : le signe. Vers la gauche, ce qui était en k arrive en 0,
   donc on lit en i + k (et non i - k). Vérifié sur l'exemple : la valeur 4
   en 3 se retrouve en 0 après [shift aut 3]. *)
let shift (aut : 'a automata) (k : int) : 'a automata =
  { aut with ribbon = (fun i -> get_value aut (i + k)) }

(* Q6.2 — Miroir du ruban autour de la case 0 : la case i reçoit -i. *)
let mirror (aut : 'a automata) : 'a automata =
  { aut with ribbon = (fun i -> get_value aut (-i)) }

(* Q6.3 — Applique [f] à chaque case du ruban.
   Idée : composer f après le ruban (évaluation paresseuse : f n'est
   appelée que sur les cases lues).
   Piège : la valeur vide [void] reste inchangée ; seul le contenu du ruban
   est transformé (c'est ce que montre l'exemple, où toutes les cases
   passent à 1). *)
let map (f : 'a -> 'a) (aut : 'a automata) : 'a automata =
  { aut with ribbon = (fun i -> f (get_value aut i)) }
