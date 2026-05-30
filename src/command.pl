:- dynamic(last_action/3).
:- dynamic(kartu_tersembunyi/2).

/* lihatKartu */
lihatKartu :-
    urutan_pemain([P|_]),
    kartu_tangan(P, List),
    (   List == [] -> 
        write('Kartu kamu sudah habis!'), nl
        ;
        write('Berikut kartu yang anda miliki.'), nl,
        printCardList(List, 1)
    ), !.

printCardList([], _).
printCardList([kartu(W, J)|T], No) :-
    format('~d. ~w-~w~n', [No, W, J]),
    !,
    N1 is No + 1, 
    printCardList(T, N1).
printCardList([H|T], No) :-
    format('~d. ~w~n', [No, H]),
    N1 is No + 1,
    printCardList(T, N1).


/* cekInfo */
cekInfo :-
    kartu_meja(kartu(W, J)),
    format('Kartu discard top: ~w-~w.~n', [W, J]),
    urutan_pemain(L),
    write('Urutan pemain: '), tulisUrutan(L), nl,
    printPlayerDetail(L, 1).

printPlayerDetail([], _).
printPlayerDetail([P|T], Idx) :-
    (
        kartu_tangan(P, List) -> get_length(List, Total)
    ;
        Total = 0
    ),
    format('~nNama pemain ~d: ~w~n', [Idx, P]),
    format('Jumlah kartu : ~d~n', [Total]),
    NewIdx is Idx + 1,
    printPlayerDetail(T, NewIdx).


/* lihatCommand */
lihatCommand :-
    (
        /* Kalo kartu sebelumnya adalah wild_draw_four */
        last_action(_, kartu(hitam, wild_draw_four), _) ->
        nl,
        write('Aksi utama yang tersedia:'), nl,
        write('1. ambilKartu'), nl,
        write('2. tantang'), nl
        ;
        /* Kalo kartu sebelumnya adalah draw_two */
        last_action(_, kartu(_, draw_two), _) ->
        nl,
        write('Aksi utama yang tersedia:'), nl,
        write('1. ambilKartu'), nl
        ;
        /* Kalo kartu di tangan sisa 2 */
        urutan_pemain([PemainAktif|_]),
        kartu_tangan(PemainAktif, Hand),
        get_length(Hand, Jumlah),
        Jumlah == 2 -> 
        nl,
        write('Aksi utama yang tersedia:'), nl,
        write('1. mainkanKartu'), nl,
        write('2. ambilKartu'), nl,
        write('3. tangkap'), nl,
        write('4. uni'), nl
        write('5. godsHand'), nl
        ;
        /* Kalo giliran biasa */
        nl,
        write('Aksi utama yang tersedia:'), nl,
        write('1. mainkanKartu'), nl,
        write('2. ambilKartu'), nl,
        write('3. tangkap'), nl,
        write('4. sembunyikanKartu'), nl,
        write('5. tampilkanKartu'), nl
        write('6. godsHand'), nl
    ),
    nl,
    write('Aksi pendukung yang tersedia:'), nl,
    write('1. lihatCommand'), nl,
    write('2. lihatKartu'), nl,
    write('3. cekInfo'), nl.


/* ambilKartu */
/* Mengambil 1 kartu dari deck dan melanjutkan ke giliran selanjutnya */
ambilKartu :-
    urutan_pemain([Pemain|_]),
    (
        last_action(_, kartu(hitam, wild_draw_four), _) ->
        format('~w mengambil 4 kartu dan skip giliran.', [Pemain]), nl,
        ambilKartuDariDeck(Pemain, 4),
        retractall(last_action(_, _, _)),
        gantiGiliran
        ;
        last_action(_, kartu(_, draw_two), _) ->
        format('~w mengambil 2 kartu dan skip giliran.', [Pemain]), nl,
        ambilKartuDariDeck(Pemain, 2),
        retractall(last_action(_, _, _)),
        gantiGiliran
        ;
        format('~w mengambil 1 kartu dari deck.', [Pemain]), nl,
        ambilKartuDariDeck(Pemain, 1),
        gantiGiliran
    ).


/* tantang */
tantang :-
    urutan_pemain([Penantang|_]),
    (
        last_action(PemainSebelum, kartu(hitam, wild_draw_four), KartuMejaSebelum),
        write('Tantangan dilakukan!'), nl,
        format('Memeriksa kartu ~w...', [Penantang]), nl,
        (
            adaKartuCocok(PemainSebelum, KartuMejaSebelum) ->
            format('Tantangan berhasil. ~w mendapatkan 4 kartu acak sebagai konsekuensi.', [PemainSebelum]), nl,
            ambilKartuDariDeck(PemainSebelum, 4),
            retractall(last_action(_, _, _))
            ;
            format('Tantangan gagal. ~w mendapatkan 6 kartu acak.', [Penantang]), nl,
            ambilKartuDariDeck(Penantang, 6),
            retractall(last_action(_, _, _)),
            gantiGiliran
        )
        ;
        write('Tidak ada kartu wild draw four yang dapat ditantang.'), nl
    ), !.


/* sembunyikan kartu */
sembunyikanKartu(NomorUrut) :-
    urutan_pemain([PemainAktif|_]),
    kartu_tangan(PemainAktif, Hand),
    get_length(Hand, L),
    ( L =< 1 ->
        write('Kartu tidak berhasil disembunyikan, kamu hanya memiliki 1 kartu.'), nl, fail
    ;   
        getNomorKartu(NomorUrut, Hand, KartuDipilih, Index),
        delete_element(Hand, Index, HandBaru),
        retract(kartu_tangan(PemainAktif, _)),
        assertz(kartu_tangan(PemainAktif, HandBaru)),
        assertz(kartu_tersembunyi(PemainAktif, KartuDipilih)),
        KartuDipilih = kartu(W, J),
        format('Kartu ~w-~w berhasil disembunyikan.~n', [W, J]),
        gantiGiliran,
        cekGiliran
    ). 

/* tampilkan kartu */
tampilkanKartu :-
    urutan_pemain([PemainAktif|_]),
    ( kartu_tersembunyi(PemainAktif, Kartu) ->
        retract(kartu_tangan(PemainAktif, HandLama)),
        NewHand = [Kartu|HandLama],
        assertz(kartu_tangan(PemainAktif, NewHand)),
        retract(kartu_tersembunyi(PemainAktif, Kartu)),
        Kartu = kartu(W, J),
        format('Kartu ~w-~w berhasil ditampilkan kembali.~n', [W, J]),
        gantiGiliran,
        cekGiliran
    ;   
        write('Tidak ada kartu yang sedang disembunyikan.'), nl, fail
    ). 