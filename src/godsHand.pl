/* godsHand */
godsHand :-
    semuaPemainSatuKartu, !,
    write('God''s Hand tidak dapat dijalankan karena seluruh pemain hanya memiliki satu kartu.'), nl.
godsHand :-
    random(0, 100, R),
    % probabilitas 20 persen
    (   R < 20
        ->
        urutan_pemain(ListPemain),
        get_length(ListPemain, JumlahPemain),
        random(0, JumlahPemain, IndexAsal),
        get_element(ListPemain, IndexAsal, PemainAsal),
        kartu_tangan(PemainAsal, HandAsal),
        get_length(HandAsal, JumlahKartu),
        random(0, JumlahKartu, IndexKartu),
        get_element(HandAsal, IndexKartu, KartuDipilih),
        pilihTujuanAcak(ListPemain, PemainAsal, PemainTujuan),
        pindahkanKartuGodsHand(PemainAsal, PemainTujuan, KartuDipilih),
        write('Tuhan telah berkehendak.'), nl,
        KartuDipilih = kartu(Warna, Jenis),
        format('Kartu ~w-~w milik ~w berpindah ke tangan ~w!~n', [Warna, Jenis, PemainAsal, PemainTujuan])
        ;
        write('Tuhan belum berkehendak.'), nl
    ),
    gantiGiliran,
    cekGiliran.

/* mengecek jika kartu semua pemain sisa satu */
semuaPemainSatuKartu :-
    urutan_pemain(ListPemain),
    sisaSatuKartu(ListPemain).

sisaSatuKartu([]).
sisaSatuKartu([Pemain|T]) :-
    kartu_tangan(Pemain, Hand),
    get_length(Hand, 1),
    sisaSatuKartu(T).

pilihTujuanAcak(ListPemain, PemainAsal, PemainTujuan) :-
    hapusPemain(PemainAsal, ListPemain, Kandidat),
    get_length(Kandidat, Jumlah),
    random(0, Jumlah, Index),
    get_element(Kandidat, Index, PemainTujuan).

hapusPemain(_, [], []).
hapusPemain(X, [X|T], T) :- !.
hapusPemain(X, [H|T], [H|R]) :-
    hapusPemain(X, T, R).

/* memindahkan kartu */
pindahkanKartuGodsHand(PemainAsal, PemainTujuan, Kartu) :-
    kartu_tangan(PemainAsal, HandAsal),
    kartu_tangan(PemainTujuan, HandTujuan),
    get_index(HandAsal, Kartu, Index),
    delete_element(HandAsal, Index, HandBaruAsal),
    append_list(HandTujuan, [Kartu], HandBaruTujuan),
    retract(kartu_tangan(PemainAsal, _)),
    assertz(kartu_tangan(PemainAsal, HandBaruAsal)),
    retract(kartu_tangan(PemainTujuan, _)),
    assertz(kartu_tangan(PemainTujuan, HandBaruTujuan)).