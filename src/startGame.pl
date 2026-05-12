:- include('fakta.pl').

:- dynamic(kartu_meja/1).
:- dynamic(kartu_tangan/2). 
:- dynamic(urutan_pemain/1).
:- dynamic(tumpukan_deck/1).

/* startGame*/
startGame :-
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
    write('Kartu discard top: '),
    inisialisasiDiscard(DeckSisa, KartuMeja, DeckFinal),
    assertz(kartu_meja(KartuMeja)),
    assertz(tumpukan_deck(DeckFinal)),
    tampilkanKartu,

    cekGiliran,
    gantiGiliran.
    
/*Input pemain*/
jumlahPemainDiRange(N) :-
    N >= 2,
    N =< 4.

/*input jumlah pemain*/
jumlahPemain(N) :-
    repeat,
    write('Masukkan jumlah pemain: '),
    read(X),
    (jumlahPemainDiRange(X) -> N = X
    ; write('Mohon masukkan angka antara 2 - 4'), nl,
    jumlahPemain(N)).

/*fungsi pembantu untuk mendaftarkan pemain*/
daftarPemainkeList(Total, ListHasil) :-
    inputNama(1, Total, [], ListHasil).

inputNama(Current, Total, Akumulator, Akumulator) :-
    Current>Total, !.
inputNama(Current, Total, Akumulator, ListNama) :-
    Current =< Total,
    write('Masukkan nama pemain '), write(Current), write(': '),
    validasiNama(Nama, Akumulator),
    Next is Current+1,
    inputNama(Next, Total, [Nama|Akumulator], ListNama).

/*mengecek apakah suatu elemen merupakan bagian dari list*/
isMember(X, [X|_]) :- !.
isMember(X, [_|T]):- isMember(X, T).

/* memastikan nama yang dimasukkan unik */
validasiNama(Nama, ListLama) :-
    repeat,
    read(X),
    nl,
    (\+ isMember(X, ListLama) ->
    Nama = X, !
    ; write('Nama sudah digunakan. Masukkan nama lain: '),
    fail).

/*fungsi-fungsi pembantu*/
get_length(List, Length) :-
    length(List, Length).

get_index([Element|_], Element, 0).
get_index([_|Tail], Element, Index) :-
    get_index(Tail, Element, Index1),
    Index is Index1+1.

get_element([Element|_], 0, Element).
get_element([_|Tail], Index, Element) :-
    Index > 0,
    NewIndex is Index-1,
    get_element(Tail, NewIndex, Element).

delete_element([_|Tail], 0, Tail).
delete_element([Head|Tail], Index, [Head|UpdatedTail]) :-
    Index > 0,
    NewIndex is Index-1,
    delete_element(Tail, NewIndex, UpdatedTail).

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
    append(T, [H], ListUrutanBaru),
    assertz(urutan_pemain(ListUrutanBaru)).

/*Distribusi kartu secara acak*/
/*Inisialisasi Deck Kartu*/
inisialisasiDeck(Deck) :-
    buat_per_warna(merah, DeckMerah),
    buat_per_warna(kuning, DeckKuning),
    buat_per_warna(hijau, DeckHijau),
    buat_per_warna(biru, DeckBiru),
    append(DeckMerah, DeckKuning, Temp1),
    append(DeckHijau, DeckBiru, Temp2),
    append(Temp1, Temp2, DeckWarna),
    DeckHitam = [wild, wild, wild, wild, wild_draw_four, wild_draw_four, wild_draw_four, wild_draw_four],
    append(DeckWarna, DeckHitam, Deck).

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

ambilKartu(0, Deck, [], Deck) :- !.
ambilKartu(N, [H|T], [H|Diambil], Sisa) :-
    N > 0,
    N1 is N-1,
    ambilKartu(N1, T, Diambil, Sisa).

bagiKartu([], Deck, Deck).
bagiKartu([Pemain|SisaPemain], DeckLama, DeckFinal) :-
    ambilKartu(7, DeckLama, Tangan, DeckSisa),
    assertz(kartu_tangan(Pemain, Tangan)),
    bagiKartu(SisaPemain, DeckSisa, DeckFinal).

/*Inisialisasi Discard Pile*/
inisialisasiDiscard([kartu(Warna, Angka)|Sisa], kartu(Warna, Angka), Sisa) :-
    Warna \== hitam,
    angka(Angka), !.

inisialisasiDiscard([Head|Tail], Kartu, Deck) :-
    append(Tail, [Head], DeckBaru),
    inisialisasiDiscard(DeckBaru, Kartu, Deck).

tampilkanKartu :-
    kartu(W, J),
    write(W), write('-'), write(J), nl.