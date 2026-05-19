/* Mengecek kartu valid */
kartuValid(kartu(W, _), kartu(W, _)) :-
    W \== hitam, !.
kartuValid(kartu(_, J), kartu(_, J)) :-
    J \== wild,
    J \== wild_draw_four,
    J \== draw_two, !.
kartuValid(kartu(hitam, wild), _).
kartuValid(kartu(hitam, wild_draw_four), _).

/* Mengambil nomor kartu */
getNomorKartu(Nomor, Hand, Kartu, Index) :-
    Index is Nomor - 1,
    get_element(Hand, Index, Kartu).

/* Mengambil N kartu dari deck */
ambilKartuDariDeck(Pemain, N) :-
    retract(tumpukan_deck(Deck)),
    ambilNKartu(N, Deck, KartuBaru, DeckSisa),
    assertz(tumpukan_deck(DeckSisa)),
    retract(kartu_tangan(Pemain, TanganLama)),
    append_list(TanganLama, KartuBaru, TanganBaru),
    assertz(kartu_tangan(Pemain, TanganBaru)).

/* Meminta pemain pilih warna baru */
pilihWarna(Warna) :-
    repeat,
    write('Pilih warna (merah/kuning/hijau/biru): '),
    read(Input),
    ( warna(Input), Input \== hitam ->
        Warna = Input, !
    ; write('Warna tidak valid. Pilih: merah/kuning/hijau/biru: '),
        fail
    ).

/* Menerapkan efek kartu */
terapkanEfek(skip) :-
    write('Pemain berikutnya kehilangan giliran.'), nl,
    gantiGiliran.
terapkanEfek(reverse) :-
    write('Arah permainan dibalik.'), nl,
    (
        total_pemain(2) ->
        gantiGiliran
        ;
        retract(urutan_pemain([H|T])),
        reverse_list(T, NewList),
        assertz(urutan_pemain([H|NewList]))
    ).
terapkanEfek(draw_two) :-
    urutan_pemain([_, PemainBerikutnya|_]),
    write('Pemain berikutnya mengambil 2 kartu dan kehilangan giliran.'), nl.
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
terapkanEfek(_) :- true.

adaKartuCocok(Pemain, KartuMeja) :-
    kartu_tangan(Pemain, Hand),
    member(K, Hand),
    K \= kartu(hitam, wild_draw_four),
    kartuValid(K, KartuMeja), !.

/* mainkanKartu */
/* Cek apakah mainkanKartu bisa dilakukan atau engga (jika last cardnya wild_draw_four atau draw_two) */
mainkanKartu(_) :-
    last_action(_, kartu(_, J), _),
    (J == wild_draw_four ; J == draw_two), 
    !,
    write('Kamu tidak bisa memainkan kartu!'), nl, fail.
mainkanKartu(NomorUrutKartuDiTangan) :-
    urutan_pemain([Pemain|_]),
    kartu_tangan(Pemain, Hand),
    get_length(Hand, Len),

    (   (NomorUrutKartuDiTangan < 1 ; NomorUrutKartuDiTangan > Len) ->
        write('Nomor urut tidak valid. Coba lagi.'), nl
    ;   getNomorKartu(NomorUrutKartuDiTangan, Hand, KartuDipilih, Index),
        !,
        kartu_meja(KartuMeja),

        (   kartuValid(KartuDipilih, KartuMeja) ->
            (   
                KartuDipilih = kartu(W, J),
                write(Pemain), write(' memainkan kartu: '), write(W), write('-'), write(J), nl,

                retractall(last_action(_, _, _)),
                assertz(last_action(Pemain, KartuDipilih, KartuMeja)),

                delete_element(Hand, Index, NewHand),
                retract(kartu_tangan(Pemain, _)),
                assertz(kartu_tangan(Pemain, NewHand)),

                (   W == hitam ->
                    true
                ;   retract(kartu_meja(_)),
                    assertz(kartu_meja(KartuDipilih))
                ),

                terapkanEfek(J),
                gantiGiliran,
                !
            )
        ;   write('Kartu tidak valid. Pilih kartu lain.'), nl
        )
    ), !.