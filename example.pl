#!/afs/cats.ucsc.edu/courses/cmps112-wm/usr/gprolog/bin/gprolog --consult-file
:- initialization(main).

get_to(From, To) :-
        get_to_time(From, To, time(0,0)).

get_to_time(X, X, _):-
        print('done.'),
        nl.

get_to_time(From, To, time(HourA, MinA)) :-
        flight(From, X, time(HourB, MinB)),
        A is HourA + MinA/60,
        B is HourB + MinB/60,
        A < B,
        get_to_time(X, To, time(HourB, MinB)),
        print(From), print(' to '),print(X),print(' at '),print(HourB),print(':'),print(MinB),
        nl.

main :-
        [database],
        get_to(lax,sjc),
        halt.
