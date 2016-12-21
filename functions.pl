#!/afs/cats.ucsc.edu/courses/cmps112-wm/usr/gprolog/bin/gprolog --consult-file

%Aman Mangalore aamangal@ucsc.edu, Rajvee Tibrewala ratibrew@ucsc.edu

:- include('database.pl').

not(X) :- X, !, fail.
not(_).

distance( Airport1, Airport2, DistanceMiles ) :-
   airport( Airport1, _, Latitude1, Longitude1 ),
   airport( Airport2, _, Latitude2, Longitude2 ),
   to_degree( Latitude1, Latdegrees1 ),
   to_degree( Latitude2, Latdegrees2 ),
   to_degree( Longitude1, Longdegrees1 ),
   to_degree( Longitude2, Longdegrees2 ),
   pythag( Latdegrees1, Longdegrees1, Latdegrees2, Longdegrees2,
               DistanceDegrees ),
   DistanceMiles is 69 * DistanceDegrees. 

to_degree( degmin( Degrees, Minutes ), Degreesonly ) :-
   Degreesonly is Degrees + Minutes / 60.

pythag( X1, Y1, X2, Y2, Hypotenuse ) :-
   DeltaX is X1 - X2,
   DeltaY is Y1 - Y2,
   Hypotenuse is sqrt( DeltaX * DeltaX + DeltaY * DeltaY ).

mins_to_hours(Mins, Hours):-
   Hours is Mins / 60.

hours_to_mins(Mins, Hours) :-
   Mins is Hours * 60.

hours_only( time( Hours, Mins) , Hoursonly ) :-
   Hoursonly is Hours + Mins / 60.

digits_printed( Digits ) :-
   Digits < 10, print( 0 ), print( Digits ).

digits_printed( Digits ) :-
   Digits >= 10, print( Digits ).

print_time( Hoursonly ) :-
   Minsonly is floor( Hoursonly * 60 ),
   Hours is Minsonly // 60,
   Mins is Minsonly mod 60,
   digits_printed( Hours ),
   print( ':' ),
   digits_printed( Mins ).

flight_time(Airport1, Airport2, FlightTime) :-
   distance(Airport1, Airport2, DistanceMiles),
   FlightTime is DistanceMiles / 500.

arrival_time(flight(Airport1, Airport2, time(DH,DM)), ArrivalTime) :-
   flight_time(Airport1, Airport2, FlightTime),
   hours_only(time(DH,DM), DepartureTime),
   ArrivalTime is DepartureTime + FlightTime.

writepath( [] ).

writepath( [flight(Depart,Arrive,DTimeHM)|List]) :-
   airport( Depart, Depart_name, _, _ ),
   airport( Arrive, Arrive_name, _, _),
   hours_only(DTimeHM, DepartTime), 
   arrival_time(flight(Depart,Arrive,DTimeHM), ArrivalTime), 
   write('depart  '), write( Depart ), 
      write('  '), write( Depart_name ), 
      write('  '), print_time( DepartTime),
   nl,
   write('arrive  '), write( Arrive ), 
      write('  '), write( Arrive_name ), 
      write('  '), print_time( ArrivalTime),
   nl,
   writepath( List ). 

sanetime(H1, T2) :-
   hours_only(T2, H2),
   hours_to_mins(M1, H1),
   hours_to_mins(M2, H2),
   M1 + 29 < M2.

sanearrival(flight(Dep,Arriv,DepTime)) :-
   arrival_time(flight(Dep,Arriv,DepTime), ArrivTime),
   ArrivTime < 24.

listpath( Node, End, [flight(Node, Next, NDep)|Outlist] ) :-
   not(Node = End), 
   flight(Node, Next, NDep),
   listpath( Next, End, [flight(Node, Next, NDep)], Outlist ).

listpath( Node, Node, _, [] ).
listpath( Node, End,
   [flight(PDep,PArr,PDepTime)|Tried], 
   [flight(Node, Next, NDep)|List] ) :-
   flight(Node, Next, NDep), % Find a potential flight.
   arrival_time(flight(PDep,PArr,PDepTime), PArriv), % Get PrevArrivalTime.
   sanetime(PArriv, NDep), % Is this transfer possible?
   sanearrival(flight(Node,Next,NDep)),
   Tried2 = append([flight(PDep,PArr,PDepTime)], Tried),
   not( member( Next, Tried2 )), % Is this flight in our path already?
   not(Next = PArr),
   listpath( Next, End, 
   [flight(Node, Next, NDep)|Tried2], 
      List ). 

time_for_travel([flight(Dep, Arr, DTimeHM)|List], Length) :-
   length(List, 0),
   hours_only(DTimeHM,DTimeH), 
   arrival_time(flight(Dep, Arr, DTimeHM), ArrivalTime),
   Length is ArrivalTime - DTimeH.

time_for_travel([flight(Dep, Arr, DTimeHM)|List], Length) :-
   length(List, L),
   L > 0,
   time_for_travel(flight(Dep, Arr, DTimeHM), List, Length).
   

time_for_travel(flight(_, _, DTimeHM), [Head|List], Length) :-
   length(List, 0),
   hours_only(DTimeHM, DTimeH),
   arrival_time(Head, ArrivalTime),
   Length is ArrivalTime - DTimeH.

time_for_travel(flight(Dep, Arr, DTimeHM), [_|List], Length) :-
   length(List, L),
   L > 0,
   time_for_travel(flight(Dep, Arr, DTimeHM), List, Length).
   

shortest(Depart, Arrive, List) :-
   listpath(Depart, Arrive, List),
   noshorter(Depart, Arrive, List).

noshorter(Depart, Arrive, List) :-
   listpath(Depart, Arrive, List2),
   time_for_travel(List, Length1),
   time_for_travel(List2, Length2),
   Length1 > Length2,
   !, fail.

noshorter(_, _, _).


fly( Depart, Arrive ) :-
   shortest(Depart, Arrive, List),
   nl,
   writepath(List),!.

fly( Depart, Depart ) :-
   write('Error: Departure and arrival airports are the same.'),
   !, fail.

fly( Depart, _ ) :-
   \+ airport(Depart, _, _, _),
   write('Departure airport was invalid.'),
   !, fail.

fly( _, Arrive ) :-
   \+ airport(Arrive, _, _, _),
   write('Arrival airport was invalid.'),
   !, fail.

fly( Depart, Arrive ) :- 
   \+shortest(Depart, Arrive, _),
   write('Error: Did not find a valid itinerary.'),
   !, fail.
