:- include('startGame.pl').

:- dynamic(kartu_meja/1).
:- dynamic(kartu_tangan/2).
:- dynamic(urutan_pemain/1).
:- dynamic(tumpukan_deck/1).

/* Mengecek kartu valid */
kartuValid(kartu(W, _), kartu(W, _)) :-
    W \== hitam.
kartuValid(kartu(_, J), kartu(_, J)) :-
    J \== wild,
    J \== draw_two.
kartuValid(kartu(hitam, wild), _).
kartuValid(kartu(hitam, wild_draw_four), kartu(_, J)) :- 
    J \== wild_draw_four.

/* Mengambil nomor kartu */
getNomorKartu(Nomor, Hand, Kartu, Index) :-
    Index is Nomor - 1,
    get_element(Hand, Index, Kartu).

/* Mengganti giliran */
gantiGiliran :-
    retract(urutan_pemain([Pemain|Sisa])),
    append(Sisa, [Pemain], UrutanBaru),
    assertz(urutan_pemain(UrutanBaru)).

/* Mengambil N kartu dari deck */
ambilKartuDariDeck(Pemain, N) :-
    retract(tumpukan_deck(Deck)),
    ambilKartu(N, Deck, KartuBaru, DeckSisa),
    assertz(tumpukan_deck(DeckSisa)),
    retract(kartu_tangan(Pemain, TanganLama)),
    append(TanganLama, KartuBaru, TanganBaru),
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
    retract(urutan_pemain(List)),
    reverse(List, NewList),
    assertz(urutan_pemain(NewList)).
terapkanEfek(draw_two) :-
    urutan_pemain([_, PemainBerikutnya|_]),
    write('Pemain berikutnya mengambil 2 kartu dan kehilangan giliran.'), nl,
    ambilKartuDariDeck(PemainBerikutnya, 2),
    gantiGiliran.
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
    write('Pemain berikutnya mengambil 4 kartu dan kehilangan giliran.'), nl,
    ambilKartuDariDeck(PemainBerikutnya, 4),
    gantiGiliran.
terapkanEfek(_) :- true.

adaKartuCocok(Pemain, KartuMeja) :-
    kartu_tangan(Pemain, Hand),
    member(K, Hand),
    K \= kartu(hitam, wild_draw_four),
    kartuValid(K, KartuMeja), !.

/* mainkanKartu */
mainkanKartu(NomorUrutKartuDiTangan) :-
    urutan_pemain([Pemain|_]),
    kartu_tangan(Pemain, Hand),
    get_length(Hand, Len),

    (   (NomorUrutKartuDiTangan < 1 ; NomorUrutKartuDiTangan > Len) ->
        write('Nomor urut tidak valid. Coba lagi.'), nl, fail
    ;   getNomorKartu(NomorUrutKartuDiTangan, Hand, KartuDipilih, Index),
        kartu_meja(KartuMeja),

        (   kartuValid(KartuDipilih, KartuMeja) ->
            (   KartuDipilih = kartu(hitam, wild_draw_four), punyaKartuCocok(Pemain, KartuMeja) ->
                write('Kartu tidak valid. Kamu masih punya kartu lain yang cocok di tangan.'), nl, fail
            ;   KartuDipilih = kartu(W, J),
                write(Pemain), write(' memainkan kartu: '), write(W), write('-'), write(J), nl,

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
                cekGiliran, !
            )
        ;   write('Kartu tidak valid. Pilih kartu lain.'), nl, fail
        )
    ).