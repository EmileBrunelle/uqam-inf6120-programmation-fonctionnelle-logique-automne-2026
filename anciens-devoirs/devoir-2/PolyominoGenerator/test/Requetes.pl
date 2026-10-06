% Requêtes de l'énoncé (partie 7), toutes solutions d'un coup.
% Usage (depuis PolyominoGenerator, avec le polyomino 10 dans Prolog/Polyomino.pl) :
%   swipl -q -s Prolog/Analysis.pl -s test/Requetes.pl -g run10 -g halt
% Pour le polyomino 131 : dune exec PolyominoGenerator 24 131, puis -g run131.

show(Goal, V) :- findall(V, Goal, L), format("?- ~q.~n   ~q~n", [Goal, L]).
run10 :-
  show(add_squares(square(2,1), square(-4,5), S), S),
  show(add_squares(square(2,1), S, square(-4,5)), S),
  show(neighbor(S, square(0,0)), S),
  show(neighbor(square(2,3), S), S),
  show(filled_neighbor(square(0,0), S), S),
  show(filled_neighbor(square(7,-2), S), S),
  show(filled_list([]), ok),
  show(filled_list([square(1,0), square(5,0), square(7,1)]), ok),
  show(filled_list([square(1,0), square(5,0), square(-2,2), square(7,1)]), ok),
  show(pattern_position([square(0,0), square(-1,1)], S), S),
  show(pattern_position([square(0,0), square(0,1), square(0,2)], S), S),
  show(area(A), A),
  show(elementary_path(square(0,0), square(1,0), P), P),
  show(elementary_path(square(0,-1), square(4,0), P), P),
  print_information.
run131 :-
  show(filled_neighbor(square(0,0), S), S),
  show(pattern_position([square(0,0), square(-1,1)], S), S),
  show(pattern_position([square(0,0), square(0,1), square(0,2)], S), S),
  show(area(A), A),
  print_information.
