-module(lamporttime).

-export([zero/0, inc/1, merge/2, leq/2, startClocks/1, updateLamportTime/3, lowestLamportTime/1]).

zero() ->
  0.

inc(T) ->
  T + 1.

merge(Ti, Tj) ->
  if
    Ti < Tj -> Tj;
    true -> Ti
  end.

leq(Ti, Tj) ->
  Ti =< Tj.

%Die Uhrenverwaltung wird gestartet/initialisiert. Alle Worker werden mit ihrem Zeitstempel gespeichert.
startClocks(Nodes) -> lists:foldl(fun(Node, LamportClocks) -> [{Node, zero()} | LamportClocks] end, [], Nodes).

%Gibt die niedrigste Lamportzeit zurück
lowestLamportTime(LamportClocks) -> element(2, hd(lists:keysort(2, LamportClocks))).

%Es wird nach dem richtigen Element in der Uhrenverwaltung gesucht, dessen Zeitstempel wird dann aktualisiert
updateLamportTime(Node, Time, LamportClocks) -> lists:keyreplace(Node, 1, LamportClocks, {Node, Time}).
