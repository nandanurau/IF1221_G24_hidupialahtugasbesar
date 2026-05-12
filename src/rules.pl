get_length([], 0).
get_length([_|T], N) :-
    get_length(T, N1),
    N is N1+1.

append_list([], L, L).
append_list([Head|Tail], List, [Head|UpdatedList]) :-
    append_list(Tail, List, UpdatedList).

get_index([Element|_], Element, 0).
get_index([_|Tail], Element, Index) :-
    get_index(Tail, Element, Index1),
    Index is Index1+1.

get_element([Element|_], 0, Element).
get_element([_|Tail], Index, Element) :-
    Index > 0,
    NewIndex is Index-1,
    get_element(Tail, NewIndex, Element).

delete_element([_|Tail], 0, Tail).
delete_element([Head|Tail], Index, [Head|UpdatedTail]) :-
    Index > 0,
    NewIndex is Index-1,
    delete_element(Tail, NewIndex, UpdatedTail).

reverse_list([], []).
reverse_list([Head|Tail], Reversed) :-
    reverse_list(Tail, Temp),
    append_list(Temp, [Head], Reversed).

