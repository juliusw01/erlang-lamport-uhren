
-module(mylogger).
-export([start/1, stop/1]).

start(Nodes) ->
  spawn_link(fun() -> init(Nodes) end).

stop(Logger) ->
  Logger ! stop.

%initialisiert den Loop
init(_) ->
  loop().

% ankommende Nachrichten/Logs werden an die log()-Methode weitergegeben
loop() ->
  %Nachricht wird empfangen
  receive {log, From, Time, Msg} ->
      log(From, Time, Msg),
      %Methode ruft sich selbst wieder auf
      loop();
    stop ->
      ok
end.

% gibt die Nachrichten/Logs auf dem Standard-Output aus (Konsole)
log(From, Time, Msg) ->
  io:format("log: ~w ~w ~p~n", [Time, From, Msg]).