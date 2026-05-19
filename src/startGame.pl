:- dynamic(kartu_meja/1).
:- dynamic(kartu_tangan/2). 
:- dynamic(urutan_pemain/1).
:- dynamic(tumpukan_deck/1).
:- dynamic(total_pemain/1).
:- dynamic(game_started/0).

/* startGame*/
startGame :-
    game_started, !,
    write('Permainan sudah dimulai.'), nl.

startGame :-
    retractall(urutan_pemain(_)),
    retractall(kartu_tangan(_, _)),
    retractall(kartu_meja(_)),
    retractall(tumpukan_deck(_)),
    retractall(last_action(_, _, _)),
    retractall(total_pemain(_)),

    assertz(game_started),

    jumlahPemain(TotalPemain),
    daftarPemainkeList(TotalPemain, ListPemain),

    urutkanPemain(ListPemain, ListUrutan),
    assertz(urutan_pemain(ListUrutan)),
    write('Urutan pemain: '),
    tulisUrutan(ListUrutan), nl,

    inisialisasiDeck(Deck),
    randomCard(Deck, DeckHasil),
    bagiKartu(ListUrutan, DeckHasil, DeckSisa),
    write('Setiap pemain mendapatkan 7 kartu acak.'), nl,
    % write('Kartu discard top: '),
    inisialisasiDiscard(DeckSisa, KartuMeja, DeckFinal),
    assertz(kartu_meja(KartuMeja)),
    assertz(tumpukan_deck(DeckFinal)),
    % tampilkanKartu,
    KartuMeja = kartu(WM, JM),
    format('Kartu discard top: ~w-~w~n', [WM, JM]),

    gameLoop.
    % gantiGiliran.
    
/*Input pemain*/
jumlahPemainDiRange(N) :-
    N >= 2,
    N =< 4.

/*input jumlah pemain*/
jumlahPemain(N) :-
    repeat,
    write('Masukkan jumlah pemain: '),
    read(X),
    (   number(X) ->  
        (
            jumlahPemainDiRange(X) -> N = X, 
            assertz(total_pemain(X)),
            !
        ; 
            write('Mohon masukkan angka antara 2 - 4'), nl, fail
        )
    ; write('Input harus berupa angka'), nl, fail
    ).

/*fungsi pembantu untuk mendaftarkan pemain*/
daftarPemainkeList(Total, ListHasil) :-
    inputNama(1, Total, [], ListHasil).

inputNama(Current, Total, Akumulator, Akumulator) :-
    Current>Total, !.
inputNama(Current, Total, Akumulator, ListNama) :-
    Current =< Total,
    write('Masukkan nama pemain '), write(Current), write(': '),
    validasiNama(Nama, Akumulator),
    !,
    Next is Current+1,
    inputNama(Next, Total, [Nama|Akumulator], ListNama).

/*mengecek apakah suatu elemen merupakan bagian dari list*/
isMember(X, [X|_]) :- !.
isMember(X, [_|T]):- isMember(X, T).

/* memastikan nama yang dimasukkan unik */
validasiNama(Nama, ListLama) :-
    % repeat,
    read(X),
    nl,
    (\+ isMember(X, ListLama) ->
        Nama = X, !
    ; 
        write('Nama sudah digunakan. Masukkan nama lain: '),
        validasiNama(Nama, ListLama)
    ).

/*Urutan Pemain
  untuk menentukan urutan pemain*/
urutkanPemain([],[]).
urutkanPemain(ListNama, [Element|SisaUrutan]) :-
    get_length(ListNama, Length),
    Length > 0,
    random(0, Length, Index),
    get_element(ListNama, Index, Element),
    delete_element(ListNama, Index, UpdatedList),
    urutkanPemain(UpdatedList, SisaUrutan).

tulisUrutan([H]) :-
    write(H), write('.'), !.

tulisUrutan([H|T]) :-
    write(H), write(' - '),
    tulisUrutan(T).

/*Menentukan Giliran*/
cekGiliran :-
    urutan_pemain([Pemain|_]),
    write('Giliran '),
    write(Pemain), nl.

gantiGiliran :-
    retract(urutan_pemain([H|T])),
    append_list(T, [H], ListUrutanBaru),
    assertz(urutan_pemain(ListUrutanBaru)).

/*Distribusi kartu secara acak*/
/*Inisialisasi Deck Kartu*/
inisialisasiDeck(Deck) :-
    buat_per_warna(merah, DeckMerah),
    buat_per_warna(kuning, DeckKuning),
    buat_per_warna(hijau, DeckHijau),
    buat_per_warna(biru, DeckBiru),
    append_list(DeckMerah, DeckKuning, Temp1),
    append_list(DeckHijau, DeckBiru, Temp2),
    append_list(Temp1, Temp2, DeckWarna),
    DeckHitam = [kartu(hitam, wild), kartu(hitam, wild), kartu(hitam, wild), kartu(hitam, wild), kartu(hitam, wild_draw_four), kartu(hitam, wild_draw_four), kartu(hitam, wild_draw_four), kartu(hitam, wild_draw_four)],
    append_list(DeckWarna, DeckHitam, Deck).

buat_per_warna(Warna, [kartu(Warna, 0)|Sisa]) :-
    generate_double(Warna, 1, Sisa).

generate_double(Warna, 10, Sisa) :-
    generate_efek(Warna, Sisa).
generate_double(Warna, N, [kartu(Warna, N)|Sisa]) :-
    N =< 9,
    N1 is N+1,
    generate_double(Warna, N1, Sisa).

generate_efek(Warna, [kartu(Warna, skip), kartu(Warna, skip), kartu(Warna, reverse), kartu(Warna, reverse), kartu(Warna, draw_two), kartu(Warna, draw_two)]).
    
/*Acak kartu*/
randomCard([], []) :- !.
randomCard(Hand, [Element|SisaHand]) :-
    get_length(Hand, Length),
    Length>0,
    random(0, Length, Index),
    get_element(Hand, Index, Element),
    delete_element(Hand, Index, UpdatedList),
    randomCard(UpdatedList, SisaHand).

ambilNKartu(0, Deck, [], Deck) :- !.
ambilNKartu(N, [H|T], [H|Diambil], Sisa) :-
    N > 0,
    N1 is N-1,
    ambilNKartu(N1, T, Diambil, Sisa).

bagiKartu([], Deck, Deck).
bagiKartu([Pemain|SisaPemain], DeckLama, DeckFinal) :-
    ambilNKartu(7, DeckLama, Tangan, DeckSisa),
    assertz(kartu_tangan(Pemain, Tangan)),
    bagiKartu(SisaPemain, DeckSisa, DeckFinal).

/*Inisialisasi Discard Pile*/
inisialisasiDiscard([kartu(Warna, Angka)|Sisa], kartu(Warna, Angka), Sisa) :-
    Warna \== hitam,
    angka(Angka), !.

inisialisasiDiscard([Head|Tail], Kartu, Deck) :-
    append_list(Tail, [Head], DeckBaru),
    inisialisasiDiscard(DeckBaru, Kartu, Deck).

tampilkanKartu :-
    kartu(W, J),
    format('~w - ~w.~n', [W, J]).

gameLoop :-
    repeat,
    (
        /* if endGame */
        kartu_tangan(_, []) ->
        endGame,
        retractall(urutan_pemain(_)),
        retractall(kartu_tangan(_, _)),
        retractall(kartu_meja(_)),
        retractall(tumpukan_deck(_)),
        retractall(last_action(_, _, _)), 
        retractall(total_pemain(_)),
        retractall(game_started),
        !
        ;
        nl,
        cekGiliran,
        write('>> '),
        read(Command),
        (
            /* Action Command */
            Command = mainkanKartu(N) -> mainkanKartu(N), fail
            ;
            Command == ambilKartu -> ambilKartu, fail
            ;
            Command = tangkap(N) -> tangkap(N), fail
            ;

            /* Specific Action Command */
            Command = uni(N) -> uni(N), fail
            ;
            Command == tantang -> tantang, fail
            ;

            /* Supporting Command */
            Command == lihatCommand -> lihatCommand, fail
            ;
            Command == lihatKartu -> lihatKartu, fail
            ;
            Command == cekInfo -> cekInfo, fail
            ;
            write('Command not found'), nl, fail
        )
    ).