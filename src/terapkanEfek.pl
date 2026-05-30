:- dynamic(kartu_aksi_terakhir/1).

/* Menerapkan efek kartu */
terapkanEfek(skip) :-
    kartu_meja(kartu(Warna, _)),
    retractall(kartu_aksi_terakhir(_)),
    assertz(kartu_aksi_terakhir(kartu(Warna, skip))),
    % printKartuAksi,
    write('Pemain berikutnya kehilangan giliran.'), nl,
    gantiGiliran.
terapkanEfek(reverse) :-
    write('Arah permainan dibalik.'), nl,
    (
        kartu_meja(kartu(Warna, _)),
        retractall(kartu_aksi_terakhir(_)),
        assertz(kartu_aksi_terakhir(kartu(Warna, reverse))),
        % printKartuAksi,
        total_pemain(2) ->
        gantiGiliran
        ;
        retract(urutan_pemain([H|T])),
        reverse_list(T, NewList),
        assertz(urutan_pemain([H|NewList]))
    ).
terapkanEfek(draw_two) :-
    kartu_meja(kartu(Warna, _)),
    retractall(kartu_aksi_terakhir(_)),
    assertz(kartu_aksi_terakhir(kartu(Warna, draw_two))),
    % printKartuAksi,
    write('Pemain berikutnya harus mengambil 2 kartu.'), nl.
terapkanEfek(wild) :-
    pilihWarna(WarnaBaru),
    retract(kartu_meja(_)),
    assertz(kartu_meja(kartu(WarnaBaru, wild))),
    retractall(kartu_aksi_terakhir(_)),
    assertz(kartu_aksi_terakhir(kartu(WarnaBaru, wild))),
    % printKartuAksi,
    write('Warna aktif sekarang: '),
    write(WarnaBaru), nl.
terapkanEfek(wild_draw_four) :-
    pilihWarna(WarnaBaru),
    retract(kartu_meja(_)),
    assertz(kartu_meja(kartu(WarnaBaru, wild_draw_four))),
    retractall(kartu_aksi_terakhir(_)),
    assertz(kartu_aksi_terakhir(kartu(WarnaBaru, wild_draw_four))),
    % printKartuAksi,
    write('Pemain berikutnya mengambil 4 kartu.'), nl.
terapkanEfek(mimic) :-
    nl, write('Menelusuri riwayat permainan . . .'), nl,
    (
        (\+ (kartu_aksi_terakhir(kartu(_, _)))) ->
        nl, write('Belum ada kartu aksi yang dimainkan.'), nl,
        nl, write('Kartu mimic menyalin efek wild!'), nl,
        terapkanEfek(wild)
        ;
        kartu_aksi_terakhir(kartu(W,J)),
        nl, write('Kartu aksi terakhir yang dimainkan: '), write(W), write('-'), write(J), nl,
        write('Kartu mimic menyalin efek '), write(J), write('!'), nl,
        (
            (J == wild) ->
            terapkanEfek(wild)
            ;
            (J == wild_draw_four) ->
            terapkanEfek(wild_draw_four)
            ;
            terapkanEfek(wild),
            terapkanEfek(J)
        )
    ).
terapkanEfek(_) :- true.
printKartuAksi :- % Debug
    kartu_aksi_terakhir(kartu(W,J)),
    nl,
    write('Kartu aksi terakhir: '), write(W), write('-'), write(J),
    nl.