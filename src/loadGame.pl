:- include('saveGame.pl').

/* loadGame */
loadGame :-
    write('Masukkan nama file yang akan dimuat: '),
    read(NamaFile),
    buatNamaFile(NamaFile, FileTXT),
    (   exists_file(FileTXT) ->
        resetGame,
        open(FileTXT, read, File),
        repeat,
        read_term(File, Term, []),
        (   Term == end_of_file -> !
        ;   restore_term(Term),
            fail
        ),
        close(File), nl,
        write('Status permainan berhasil dimuat dari '),
        write(FileTXT),
        write('.'), nl,
        giliran(Pemain),
        write('Melanjutkan giliran '),
        write(Pemain),
        write('.'), nl
    ;   write('File tidak ditemukan.'), nl
    ).

/* pattern matching dengan restore_term/1 */
restore_term(urutan_pemain:List) :-
    assertz(urutan_pemain(List)).

restore_term(giliran:Pemain) :-
    assertz(giliran(Pemain)).

restore_term(discard_top:Warna-Jenis) :-
    assertz(kartu_meja(kartu(Warna, Jenis))).

restore_term(warna_aktif:Warna) :-
    assertz(warna_aktif(Warna)).

restore_term(arah_permainan:Arah) :-
    assertz(arah_permainan(Arah)).

restore_term(status_UNI:List) :-
    assertz(status_UNI(List)).

restore_term(kartu_aksi_terakhir:none) :- !. % bonus mimic card
restore_term(kartu_aksi_terakhir:Kartu) :- 
    retractall(kartu_aksi_terakhir(_)),
    assertz(kartu_aksi_terakhir(Kartu)).

restore_term(kartu(Pemain):ListKartu) :-
    konversiKartu(ListKartu, Hand),
    assertz(kartu_tangan(Pemain, Hand)).

/* mengkonversi format kartu dari saveGame */
konversiKartu([], []).
konversiKartu([Warna-Jenis|Tail], [kartu(Warna, Jenis)|Sisa]) :-
    konversiKartu(Tail, Sisa).

/* reset game */
resetGame :-
    retractall(jumlahPemain(_)),
    retractall(namaPemain(_, _)),
    retractall(urutan_pemain(_)),
    retractall(giliran(_)),
    retractall(warna_aktif(_)),
    retractall(arah_permainan(_)),
    retractall(status_UNI(_)),
    retractall(kartu_tangan(_, _)),
    retractall(kartu_meja(_)),
    retractall(tumpukan_deck(_)),
    retractall(kartu_aksi_terakhir(_)). % bonus mimic card