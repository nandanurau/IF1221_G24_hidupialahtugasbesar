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
    urutan_pemain([_, PemainBerikutnya|_]),
    write('Pemain berikutnya mengambil 2 kartu dan kehilangan giliran.'), nl.
    % ambilKartuDariDeck(PemainBerikutnya, 2).
    % gantiGiliran.
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
    urutan_pemain([_, PemainBerikutnya|_]),
    write('Pemain berikutnya mengambil 4 kartu dan kehilangan giliran.'), nl.
    % ambilKartuDariDeck(PemainBerikutnya, 4).
    % gantiGiliran.
terapkanEfek(_) :- true.