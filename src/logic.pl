writeln(X) :- write(X), nl.

print_turn([H]) :- write(H), !.
print_turn([H|T]) :- format('~w - ', [H]), print_turn(T).