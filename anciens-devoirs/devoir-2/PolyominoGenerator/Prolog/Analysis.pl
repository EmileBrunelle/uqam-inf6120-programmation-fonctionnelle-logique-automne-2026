/*
Devoir 2 (INF6120, automne 2025) — solution d'entraînement.
Auteur : Émile Brunelle — code permanent : à compléter.

Partie 7 : propriétés du polyomino courant, décrit par les faits filled/1
de Polyomino.pl (fichier produit par le programme OCaml).
*/

:- use_module(library(clpfd)).
:- consult("Polyomino.pl").

% add_squares(S1, S2, S3) : S3 = S1 + S2, coordonnée par coordonnée.
% Idée : #= (CLP(FD)) au lieu de is/2. is/2 exige un côté droit connu,
% alors que #= marche dans tous les sens : add_squares(A, S, B) trouve S,
% c'est-à-dire fait une soustraction (deuxième exemple de l'énoncé).
% Piège : avec is/2, add_squares(square(2,1), S, square(-4,5)) lève une
% erreur d'instanciation.
add_squares(square(X1, Y1), square(X2, Y2), square(X3, Y3)) :-
    X3 #= X1 + X2,
    Y3 #= Y1 + Y2.

% neighbor(S1, S2) : S2 est S1 décalée d'un pas dans une des quatre
% directions. Idée : member/2 énumère les quatre décalages (backtracking :
% une réponse par décalage) et add_squares fait le calcul dans les deux
% sens, d'où les deux usages neighbor(S, s(0,0)) et neighbor(s(2,3), S).
% L'ordre de la liste fixe l'ordre des réponses (celui de l'énoncé).
neighbor(S1, S2) :-
    member(Shift, [square(0, 1), square(0, -1), square(1, 0), square(-1, 0)]),
    add_squares(S1, Shift, S2).

% filled_neighbor(S1, S2) : S2 voisine de S1 ET remplie. Conjonction de
% deux buts : neighbor/2 propose, filled/1 filtre (générer puis tester).
% Piège : seule S2 doit être remplie, pas S1.
filled_neighbor(S1, S2) :-
    neighbor(S1, S2),
    filled(S2).

% filled_list(L) : toutes les cases de L sont remplies. maplist/2 applique
% filled/1 à chaque élément ; la liste vide réussit (vrai par vacuité).
filled_list(Squares) :-
    maplist(filled, Squares).

% pattern_position(Pat, S) : le motif Pat (liste de décalages, origine en
% tête) a une occurrence en position S. Méthode de l'énoncé :
%  1. filled(S) énumère les positions candidates (backtracking) ;
%  2. maplist(add_squares(S), Pat, Moved) translate le motif en S —
%     add_squares(S) est une application PARTIELLE : maplist ajoute les
%     deux derniers arguments ;
%  3. filled_list vérifie que toutes les cases translatées sont remplies.
% Piège : commencer par translater avec S libre ferait travailler CLP(FD)
% sur des variables ; lier S d'abord garde tout concret.
pattern_position(Pat, S) :-
    filled(S),
    maplist(add_squares(S), Pat, Moved),
    filled_list(Moved).

% count_pattern(Pat, N) : N occurrences du motif. findall/3 collecte toutes
% les solutions du backtracking dans une liste, length/2 la compte.
% (Prédicat ajouté : il sert à area/1 et à print_information/0.)
count_pattern(Pat, N) :-
    findall(S, pattern_position(Pat, S), Positions),
    length(Positions, N).

% area(A) : une case remplie = une occurrence du motif à une case.
area(A) :-
    count_pattern([square(0, 0)], A).

% elementary_path(Start, End, Path) : Path va de Start à End dans le
% polyomino sans repasser par une case. On part avec OPEN = toutes les
% cases remplies (findall), puis on délègue à elementary_path/4.
elementary_path(Start, End, Path) :-
    findall(S, filled(S), Open),
    elementary_path(Start, End, Open, Path).

% elementary_path(Start, End, Open, Path) : idem, et toutes les cases de
% Path sont dans Open (les cases encore permises).
% Idée : à chaque pas, select/3 RETIRE la case courante de Open ; on ne
% peut donc jamais y revenir : c'est ce qui rend le chemin élémentaire et
% garantit que la recherche termine (Open diminue strictement).
% - Clause 1 (arrêt) : on est arrivé, le chemin est [End].
% - Clause 2 (pas) : on quitte Start vers une voisine remplie et on
%   continue récursivement ; le backtracking essaie toutes les voisines.
% Si End est libre, la clause 1 l'unifie avec chaque case atteinte : on
% énumère alors tous les chemins partant de Start (voir print_information).
% Piège : sans Open (simple filled_neighbor récursif), la recherche
% boucle à l'infini entre deux cases voisines.
elementary_path(End, End, Open, [End]) :-
    memberchk(End, Open).
elementary_path(Start, End, Open, [Start | Path]) :-
    select(Start, Open, Rest),
    filled_neighbor(Start, Next),
    elementary_path(Next, End, Rest, Path).

% print_information : les statistiques demandées. Les motifs sont ceux de
% (7.1) : domino M1, anti-domino M2, diagonal M3, anti-diagonal M4.
% Effet secondaire (affichage) via format/2 ; ~w écrit le terme, ~n saute
% une ligne. Les chemins depuis l'origine : End reste libre, donc un
% chemin par extrémité possible, y compris le chemin [square(0, 0)].
% aggregate_all(count, ...) compte sans stocker les chemins (findall +
% length les garderait tous en mémoire). Le nombre de chemins reste
% exponentiel en l'aire : au-delà d'une trentaine de cases, c'est long.
print_information :-
    area(A),
    count_pattern([square(0, 0), square(1, 0)], Domino),
    count_pattern([square(0, 0), square(0, 1)], AntiDomino),
    count_pattern([square(0, 0), square(1, 1)], Diagonal),
    count_pattern([square(0, 0), square(-1, 1)], AntiDiagonal),
    aggregate_all(count, elementary_path(square(0, 0), _, _), NbPaths),
    format("Area: ~w~n", [A]),
    format("Domino patterns: ~w~n", [Domino]),
    format("Anti-domino patterns: ~w~n", [AntiDomino]),
    format("Diagonal patterns: ~w~n", [Diagonal]),
    format("Anti-diagonal patterns: ~w~n", [AntiDiagonal]),
    format("Paths from the origin: ~w~n", [NbPaths]).
