/* lihatKartu */
lihatKartu :-
    urutan_pemain([P|_]),
    kartu_tangan(P, List),
    (   List == [] -> 
        write('Kartu kamu sudah habis!'), nl
        ;
        write('Berikut kartu yang anda miliki.'), nl,
        printCardList(List, 1)
    ), !.
    

printCardList([], _).
printCardList([kartu(W, J)|T], No) :-
    format('~d. ~w-~w~n', [No, W, J]),
    !,
    N1 is No + 1, 
    printCardList(T, N1).
printCardList([H|T], No) :-
    format('~d. ~w~n', [No, H]),
    N1 is No + 1,
    printCardList(T, N1).

/* cekInfo */
cekInfo :-
    kartu_meja(kartu(W, J)),
    format('Kartu discard top: ~w-~w.~n', [W, J]),
    urutan_pemain(L),
    write('Urutan pemain: '), tulisUrutan(L), nl,
    printPlayerDetail(L, 1).

printPlayerDetail([], _).
printPlayerDetail([P|T], Idx) :-
    (
        kartu_tangan(P, List) -> get_length(List, Total)
    ;
        Total = 0
    ),
    format('~nNama pemain ~d: ~w~n', [Idx, P]),
    format('Jumlah kartu : ~d~n', [Total]),
    NewIdx is Idx + 1,
    printPlayerDetail(T, NewIdx).

/* for testing */
skip :-
    gantiGiliran.