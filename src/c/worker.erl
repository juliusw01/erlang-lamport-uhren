-module(worker).
-export([start/4, stop/1, peers/2]).

start(Name, Logger, Sleep, Jitter) ->
  spawn_link(fun() -> init(Name, Logger, Sleep, Jitter) end).

stop(Worker) ->
  Worker ! stop.

init(Name, Log, Sleep, Jitter) ->
  receive
    {peers, Peers} ->
      loop(Name, Log, Peers, Sleep, Jitter, lamporttime:zero());
    stop ->
      ok
end.

peers(Wrk, Peers) ->
  Wrk ! {peers, Peers}.

loop(Name, Log, Peers, Sleep, Jitter, Lamporttime) ->
  Wait = rand:uniform(Sleep),
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
        Log ! {log, Name, NewLamporttime, {sending, Message}},
        loop(Name, Log, Peers, Sleep, Jitter, NewLamporttime)
end.

select(Peers) ->
  lists:nth(rand:uniform(length(Peers)), Peers).

jitter(0) -> ok;
jitter(Jitter) -> timer:sleep(rand:uniform(Jitter)).
