/* menghitung nilai setiap jenis kartu */
nilaiKartu(kartu(_, N), N) :-
    angka(N).
nilaiKartu(kartu(_, J), 10) :-
    (J == skip ; J == reverse ; J == draw_two).
nilaiKartu(kartu(_, J), 20) :-
    (J == wild ; J == wild_draw_four ; J == mimic).

/* menghitung total poin yang diperoleh */
hitungPoin([], 0).
hitungPoin([Kartu|Tail], Total) :-
    nilaiKartu(Kartu, N),
    hitungPoin(Tail, Total1),
    Total is N + Total1.

jumlahKartu([], 0).
jumlahKartu([_|Tail], Jumlah) :-
    jumlahKartu(Tail, Jumlah1),
    Jumlah is Jumlah1 + 1.

/* menampilkan seluruh sisa kartu pemain */
printCard([]).
printCard([kartu(W, J)|Tail]) :-
    write(W), write('-'), write(J),
    (   Tail \== [] -> write(' + ')
    ;   true
    ),
    printCard(Tail).

/* menampilkan total poin yang diperoleh */
printTotal([]).
printTotal([Kartu|Tail]) :-
    nilaiKartu(Kartu, N),
    write(N),
    (   Tail \== [] -> write(' + ')
    ;   true
    ),
    printTotal(Tail).

printResult([]).
printResult([Pemain|Tail]) :-
    kartu_tangan(Pemain, Kartu),
    write(Pemain), write(': '),
    (   Kartu == [] ->
        write('kartu habis = 0 poin')
    ;
        printCard(Kartu),
        write(' = '),
        printTotal(Kartu),
        hitungPoin(Kartu, Poin),
        write(' = '), write(Poin), write(' poin')
    ),
    nl,
    printResult(Tail).

/* menentukan urutan peringkat */
buatUrutan([], []).
buatUrutan([Pemain|Tail], Urutan) :-
    buatUrutan(Tail, Urutan1),
    kartu_tangan(Pemain, Kartu),
    hitungPoin(Kartu, Poin),
    jumlahKartu(Kartu, Jumlah),
    urutan(hasil(Pemain, Poin, Jumlah), Urutan1, Urutan).
urutan(H, [], [H]).
urutan(hasil(P1, Poin1, J1), [hasil(P2, Poin2, J2)|Tail], [hasil(P1, Poin1, J1), hasil(P2, Poin2, J2)|Tail]) :-
    (   Poin1 < Poin2
    ;
        Poin1 =:= Poin2,
        J1 < J2
    ), !.
urutan(N, [H|Tail], [H|Hasil]) :-
    urutan(N, Tail, Hasil).

/* menampilkan peringkat pemain */
printRank([], _).
printRank([hasil(Pemain, Poin, _)|Tail], N) :-
    write(N), write('. '), write(Pemain), write(' ('), write(Poin), write(' poin)'), nl,
    N1 is N + 1,
    printRank(Tail, N1).

/* endGame */
endGame :-
    \+ game_started, !,
    write('Permainan belum dimulai. Gunakan "startGame" untuk memulai.'), nl.
endGame :-
    kartu_tangan(Pemain, []),
    write('Permainan selesai! '), write(Pemain), write(' menghabiskan semua kartunya!'), nl, nl,
    write('Berikut perhitungan poin sisa kartu.'), nl,
    urutan_pemain(List),
    printResult(List), nl,
    buatUrutan(List, Urutan),
    write('Urutan pemenang:'), nl,
    printRank(Urutan, 1), nl,
    write('Selamat, '), write(Pemain), write(' menjadi pemenang!'), nl.