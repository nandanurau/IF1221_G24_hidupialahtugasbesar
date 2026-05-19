:- dynamic(last_action/3).

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
        write('1. ambilKartu'), nl,
        write('2. tangkap'), nl,
        write('3. uni'), nl
        ;
        /* Kalo giliran biasa */
        nl,
        write('Aksi utama yang tersedia:'), nl,
        write('1. mainkanKartu'), nl,
        write('2. ambilKartu'), nl,
        write('3. tangkap'), nl
    ),
    nl,
    write('Aksi pendukung yang tersedia:'), nl,
    write('1. lihatCommand'), nl,
    write('2. lihatKartu'), nl,
    write('3. cekInfo'), nl.

% lihatCommand :-
%     nl,
%     write('Aksi utama yang tersedia:'), nl,
%     write('1. mainkanKartu'), nl,
%     write('2. ambilKartu'), nl,
%     write('3. tantang'), nl,
%     nl,
%     write('Aksi pendukung yang tersedia:'), nl,
%     write('1. lihatCommand'), nl,
%     write('2. lihatKartu'), nl,
%     write('3. cekInfo'), nl.


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


/* Debugging */
skip :-
    gantiGiliran.

sub :-
    urutan_pemain([Pemain|_]),
    kartu_tangan(Pemain, Hand),
    (   Hand == [] ->
        write('DEBUG: Kartu sudah kosong, tidak bisa dikurangi lagi.'), nl
    ;   % Ambil kartu pertama (Head) dan sisakan sisanya (Tail)
        Hand = [_|Tail],
        retract(kartu_tangan(Pemain, _)),
        assertz(kartu_tangan(Pemain, Tail)),
        format('DEBUG: 1 Kartu milik ~w berhasil dihapus.', [Pemain]), nl,
        % Langsung pindah giliran setelah kartu dikurangi
        gantiGiliran
    ).