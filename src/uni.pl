:- dynamic(status_uni/2).

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
            (   KartuDipilih = kartu(hitam, wild_draw_four), adaKartuCocok(PemainAktif, KartuMeja) ->
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
                    format('~w mendapatkan 1 kartu acak sebagai penalti.', [PemainAktif]), nl,

                    retract(tumpukan_deck(DeckLama)),
                    ambilNKartu(1, DeckLama, [KartuPenalti], DeckSisa),
                    assertz(tumpukan_deck(DeckSisa)),
                    retract(kartu_tangan(PemainAktif, _)),
                    assertz(kartu_tangan(PemainAktif, [KartuPenalti|Hand])),

                    gantiGiliran,
                    !
                )
            )
        ;   write('Kartu tidak valid. Pilih kartu lain.'), nl, fail
        )
    ).

/* Tangkap */
tangkap(NamaPemain) :-
    urutan_pemain([PemainAktif|_]),
    kartu_tangan(NamaPemain, Hand),
    get_length(Hand, JumlahKartu),
    (
        JumlahKartu is 1, \+ (status_uni(NamaPemain, sudah)) -> 
        (
            format('~w tertangkap tidak menyerukan UNI.',[NamaPemain]), nl, 
            ambilKartuDariDeck(NamaPemain,2), format('~w mendapatkan 2 kartu penalti.',[NamaPemain])
        )
        ; 
        (
            write('Tidak valid!'), nl, 
            ambilKartuDariDeck(PemainAktif,1), 
            format('~w mendapatkan 1 kartu penalti.',[PemainAktif]), nl
        )
    ),
    nl,
    gantiGiliran.