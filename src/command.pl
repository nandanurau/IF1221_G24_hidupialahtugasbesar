/* Command: lihatKartu */
lihatKartu :-
    urutan_pemain([P|T]),
    writeln('Berikut kartu yang anda miliki.'),
    kartu_tangan(P, List),
    print_card_list(List, 1).

print_card_list([], _).
print_card_list([kartu(W, J)|T], No) :-
    format('~d. ~w-~w~n', [No, W, J]),
    N1 is No + 1, 
    print_card_list(T, N1).

/* Command: cekInfo */
cekInfo :-
    kartu_meja(kartu(W, J)),
    format('Kartu discard top: ~w-~w.~n', [W, J]),
    urutan_pemain(L),
    write('Urutan pemain: '), tulisUrutan(L), nl,
    print_player_detail(L, 1).

print_player_detail([], _).
print_player_detail([P|T], Idx) :-
    (
        kartu_tangan(P, List) -> get_length(List, Total)
    ;
        Total = 0
    ),
    format('~nNama pemain ~d: ~w~n', [Idx, P]),
    format('Jumlah kartu : ~d~n', [Total]),
    NewIdx is Idx + 1,
    print_player_detail(T, NewIdx).

skip :-
    gantiGiliran,
    cekGiliran.