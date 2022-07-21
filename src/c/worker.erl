-module(worker).
-export([start/4, stop/1, peers/2]).

start(Name, Logger, Sleep, Jitter) ->
  spawn_link(fun() -> init(Name, Logger, Sleep, Jitter) end).

stop(Worker) ->
  Worker ! stop.

% startet den Loop mit dem Aufruf der loop()-Methode und gibt Initialwerte mit
init(Name, Log, Sleep, Jitter) ->
  receive
    {peers, Peers} ->
      loop(Name, Log, Peers, Sleep, Jitter, lamporttime:zero());
    stop ->
      ok
end.

%sendet die Nachricht an den übergebenen Worker
peers(Wrk, Peers) ->
  Wrk ! {peers, Peers}.


loop(Name, Log, Peers, Sleep, Jitter, Lamporttime) ->
  Wait = rand:uniform(Sleep),
  % es wird auf Nachrichten gewartet / Nachrichten werden empfangen
  receive
    {msg, Time, Msg} ->
      NewLamporttime = lamporttime:inc(lamporttime:merge(Time, Lamporttime)),
      Log ! {log, Name, NewLamporttime, {received, Msg}},
      loop(Name, Log, Peers, Sleep, Jitter, NewLamporttime);
    stop ->
          ok;
    Error ->
      Log ! {log, Name, time, {error, Error}}
    after Wait ->
      Selected = select(Peers),
      NewLamporttime = lamporttime:inc(Lamporttime),
      Message = {hello, rand:uniform(100)},
      Selected ! {msg, NewLamporttime, Message},
      jitter(Jitter),
      % die Nachricht wird versendet
        Log ! {log, Name, NewLamporttime, {sending, Message}},
        loop(Name, Log, Peers, Sleep, Jitter, NewLamporttime)
end.

select(Peers) ->
  lists:nth(rand:uniform(length(Peers)), Peers).

jitter(0) -> ok;
% es wird zufällig bestimmt wie stark verzögert eine Nachricht verschickt wird
jitter(Jitter) -> timer:sleep(rand:uniform(Jitter)).
