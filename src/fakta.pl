/*Fakta*/
/*warna(X): berwarna X*/
warna(merah).
warna(kuning).
warna(hijau).
warna(biru).
warna(hitam).

/*jenis(X): berjenis X*/
jenis(angka).
jenis(skip).
jenis(reverse).
jenis(draw_two).
jenis(wild).
jenis(wild_draw_four).
jenis(mimic). /*bonus*/

/*angka(X): X angka yang valid untuk kartu*/
angka(0).
angka(1).
angka(2).
angka(3).
angka(4).
angka(5).
angka(6).
angka(7).
angka(8).
angka(9).

jenis_aksi(skip).
jenis_aksi(reverse).
jenis_aksi(draw_two).

jenis_spesial(wild).
jenis_spesial(wild_draw_four).
jenis_spesial(mimic).

/*validasi kartu*/
kartu(Warna, Jenis) :-
    warna(Warna),
    Warna \== hitam,
    angka(Jenis).

kartu(Warna, Jenis) :-
    warna(Warna),
    Warna \== hitam,
    jenis_aksi(Jenis).

kartu(hitam, Jenis) :-
    jenis_spesial(Jenis).