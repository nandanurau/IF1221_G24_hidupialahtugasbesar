:- dynamic(game_started/0).
:- dynamic(pemain/1).
:- dynamic(kartu_tangan/2).
:- dynamic(kartu_meja/1).
:- dynamic(urutan_pemain/1).
:- include('logic.pl').
:- include('command.pl').
:- include('fakta.pl').

main :-
    nl,
    writeln('--- WELCOME TO UNI ---'),
    startGame.

startGame :-
    game_started,
    !,
    writeln('Game is already started').

startGame :-
    retractall(pemain(_)),
    retractall(kartu_tangan(_, _)),
    retractall(kartu_meja(_)),
    retractall(urutan_pemain(_)),

    /* Input pemain's Name */
    write('Masukkan jumlah pemain: '),
    read(N),
    get_all_names(N, [], NameList),
    assertz(pemain(NameList)),

    /* Randomize Turn */
    get_length(NameList, Len),
    random(0, Len, StartIdx),
    assertz(urutan_pemain(StartIdx)),

    /* Initial Card Distribution */
    card_distribution(NameList),
    random_card(K),
    assertz(kartu_meja(K)),

    nl,
    write('Urutan pemain: '),
    print_turn(NameList),
    nl,
    writeln('Setiap pemain mendapatkan 7 kartu acak.'),
    K = kartu(W, J),
    format('Kartu discard top: ~w-~w. ~n', [W, J]),
    get_element(NameList, StartIdx, FirstName),
    format('Giliran ~w.~n', [FirstName]),

    assertz(game_started),
    game_loop.
    

game_loop :-
    repeat,
    read(Command),
    (
        Command == exit -> !,
        writeln('Game ended.'),
        retractall(game_started),
        retractall(pemain(_)),
        retractall(urutan_pemain(_)),
        retractall(kartu_tangan(_, _)),
        retractall(kartu_meja(_))
    ;
        (call(Command) -> true ; writeln('Command not found')), 
        fail
    ).