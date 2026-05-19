/* Menerapkan efek kartu */
terapkanEfek(skip) :-
    write('Pemain berikutnya kehilangan giliran.'), nl,
    gantiGiliran.
terapkanEfek(reverse) :-
    write('Arah permainan dibalik.'), nl,
    retract(urutan_pemain([H|T])),
    reverse_list(T, NewList),
    assertz(urutan_pemain([H|NewList])).
terapkanEfek(draw_two) :-
    write('Pemain berikutnya harus mengambil 2 kartu.'), nl.
terapkanEfek(wild) :-
    pilihWarna(WarnaBaru),
    retract(kartu_meja(_)),
    assertz(kartu_meja(kartu(WarnaBaru, wild))),
    write('Warna aktif sekarang: '),
    write(WarnaBaru), nl.
terapkanEfek(wild_draw_four) :-
    pilihWarna(WarnaBaru),
    retract(kartu_meja(_)),
    assertz(kartu_meja(kartu(WarnaBaru, wild_draw_four))),
    write('Pemain berikutnya mengambil 4 kartu.'), nl.
terapkanEfek(_) :- true.