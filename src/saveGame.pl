:- include('fakta.pl').
:- include('rules.pl').

/* saveGame */
saveGame :-
    last_action(_, kartu(hitam, wild_draw_four), _), !,
    write('Penggunaan saveGame tidak dapat dilakukan saat ini.'), nl.
saveGame :-
    last_action(_, kartu(_, draw_two), _), !,
    write('Penggunaan saveGame tidak dapat dilakukan saat ini.'), nl.
saveGame :-
    write('Masukkan nama file penyimpanan: '),
    read(NamaFile),
    buatNamaFile(NamaFile, FileTXT),
    open(FileTXT, write, File),
    saveUrutan(File),
    saveGiliran(File),
    saveDiscardTop(File),
    saveWarnaAktif(File),
    saveArahPermainan(File),
    saveStatusUNI(File),
    saveKartuAksiTerakhir(File), % bonus mimic card
    saveSemuaKartu(File),
    close(File), nl,
    write('Status permainan berhasil disimpan ke '),
    write(FileTXT),
    write('.'), nl.

/* menambah .txt format ASCII untuk nama file */
buatNamaFile(NamaFile, FileTXT) :-
    name(NamaFile, ListASCII),
    append_list(ListASCII, [46,116,120,116], UpdatedList), % .txt
    name(FileTXT, UpdatedList).

/* menyimpan seluruh data permainan */
saveUrutan(File) :-
    urutan_pemain(List),
    write(File, 'urutan_pemain:'),
    write(File, List),
    write(File, '.'),
    nl(File).

saveGiliran(File) :-
    giliran(Pemain),
    write(File, 'giliran:'),
    write(File, Pemain),
    write(File, '.'),
    nl(File).

saveDiscardTop(File) :-
    kartu_meja(kartu(Warna, Jenis)),
    write(File, 'discard_top:'),
    write(File, Warna),
    write(File, '-'),
    write(File, Jenis),
    write(File, '.'),
    nl(File).

saveWarnaAktif(File) :-
    warna_aktif(Warna),
    write(File, 'warna_aktif:'),
    write(File, Warna),
    write(File, '.'),
    nl(File).

saveArahPermainan(File) :-
    arah_permainan(Arah),
    write(File, 'arah_permainan:'),
    write(File, Arah),
    write(File, '.'),
    nl(File).

saveStatusUNI(File) :-
    status_UNI(List),
    write(File, 'status_UNI:'),
    write(File, List),
    write(File, '.'),
    nl(File).

saveKartuAksiTerakhir(File) :- % bonus mimic card
    kartu_aksi_terakhir(Kartu),
    write(File, 'kartu_aksi_terakhir:'),
    write(File, Kartu),
    write(File, '.'),
    nl(File), !.
saveKartuAksiTerakhir(File) :-
    write(File, 'kartu_aksi_terakhir:none.'),
    nl(File).

saveSemuaKartu(File) :-
    urutan_pemain(List),
    saveKartuPemain(File, List).

saveKartuPemain(_, []).
saveKartuPemain(File, [Pemain|Sisa]) :-
    kartu_tangan(Pemain, Hand),
    write(File, 'kartu('),
    write(File, Pemain),
    write(File, '):['),
    write_list(File, Hand),
    write(File, '].'),
    nl(File),
    saveKartuPemain(File, Sisa).

write_list(_, []).
write_list(File, [kartu(Warna, Jenis)]) :-
    write(File, Warna), write(File, '-'), write(File, Jenis).
write_list(File, [kartu(Warna, Jenis)|Tail]) :-
    write(File, Warna), write(File, '-'), write(File, Jenis), write(File, ','),
    write_list(File, Tail).