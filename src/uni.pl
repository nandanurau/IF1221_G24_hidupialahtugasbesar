:- dynamic(status_uni/2).

:- include('fakta.pl').
:- include('rules.pl').

/*Uni*/
uni(NomorUrutKartuDiTangan) :-
    urutan_pemain([PemainAktif|_]),
    kartu_tangan(PemainAktif, Hand),
    get_length(Hand, Jumlah),
    ( (NomorUrutKartuDiTangan < 1; NomorUrutKartuDiTangan > Jumlah) ->
        write('Nomor urut tidak valid'), nl, fail
    ;   getNomorKartu(NomorUrutKartuDiTangan, Hand, KartuDipilih, Index),
        kartu_meja(KartuMeja),
        ( kartuValid(KartuDipilih, KartuMeja) ->
        (   KartuDipilih = kartu(hitam, wild_draw_four), punyaKartuCocok(PemainAktif, KartuMeja) ->
                write('Kartu tidak valid. Kamu masih punya kartu lain yang cocok di tangan.'), nl, fail
                ;   (Jumlah == 2 ->
                    KartuDipilih = kartu(W, J),
                    format('~w memainkan kartu ~w-~w.~n', [PemainAktif, W, J]),
                    format('~w menyerukan UNI!', [PemainAktif]), nl,
                    
                    delete_element(Hand, Index, NewHand),
                    retract(kartu_tangan(PemainAktif, _)),
                    assertz(kartu_tangan(PemainAktif, NewHand)),
                    
                    (   W == hitam ->
                        true
                    ;   retract(kartu_meja(_)),
                        assertz(kartu_meja(KartuDipilih))
                    ),

                    retractall(status_uni(PemainAktif, _)),
                    assertz(status_uni(PemainAktif, sudah)),

                    terapkanEfek(J),
                    gantiGiliran,
                    cekGiliran, !
                ;
                    write('Perintah tidak valid.'), nl,
                    format('~w mendapatkan 1 kartu acak sebagai penalti.', [PemainAktif]),

                    retract(tumpukan_deck(DeckLama)),
                    ambilNKartu(1, DeckLama, [KartuPenalti], DeckSisa),
                    assertz(tumpukan_deck(DeckSisa)),
                    retract(kartu_tangan(PemainAktif, _)),
                    assertz(kartu_tangan(PemainAktif, [KartuPenalti|Hand])),

                    gantiGiliran,
                    cekGiliran, !
                )
            )
        ;   write('Kartu tidak valid. Pilih kartu lain.'), nl, fail
        )
    ).
