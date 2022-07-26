-module(mylogger).
-export([start/1, stop/1]).


start(Nodes) ->
  spawn_link(fun() -> init(Nodes) end).

stop(Logger) ->
  Logger ! stop.

%initialisiert den Loop
init(Nodes) ->
  %Die initialisierte Uhrenverwaltung und eine leere Liste/Messagequeu wird mitgegeben
  loop(lamporttime:startClocks(Nodes), []).

loop(Clocks, HoldBackQueue) ->

  receive

    {log, From, Time, Msg} ->

        %Kommt eine Nachricht an, wird die dazugehörige Uhr in der Uhrenverwaltung mit einem neuen Zeitstempel hinterlegt
        UpdatedClockList = lamporttime:updateLamportTime(From, Time, Clocks),
        %Es wird nach der niedrigsten Zeit in der Uhrenverwaltung geschaut
        CheckedTimestamp = lamporttime:lowestLamportTime(UpdatedClockList),

        if
          %Da der niedrigste Wert in der Uhrenverwaltung 1 ist, können alle Elemente mit dem Zeitstempel 1 problemlos ausgegeben werden
          Time =:= 1 ->
                SortedQueue = lists:keysort(2, HoldBackQueue),
                log(From, Time, Msg);
            %Ansonsten muss überprüft werden, welche Elemente geloggt werden können und welche nicht
            true ->
                SortedQueue = lists:keysort(2, HoldBackQueue ++ [{From, Time, Msg}])
        end,

        %Die Uhrenverwaltung wird in zwei Listen unterteilt. Eine Liste mit Nachrichten die ausgegeben werden können (MsgQueue) und Nachrichten, die noch warten müssen (Temp)
        {MsgQueue, Temp} = lists:splitwith(fun({_, Timestamp, _}) -> 
          lamporttime:leq(Timestamp, CheckedTimestamp)
          end,
        SortedQueue),

        %Es wird über alle Elemente in der MswQueue iteriert
        lists:foreach(
          fun({Sender, Timestamp, Message}) -> 
            log(Sender, Timestamp, Message)
          end,
        MsgQueue),
  
        %Die Funktion ruft sich selber auf mit den neuen Listen
        loop(UpdatedClockList, Temp);

    stop ->
        ok

  end.

%Ausgabe auf der Konsole
log(From, Time, Msg) ->
  io:format("log: ~w ~w ~p~n", [Time, From, Msg]). 