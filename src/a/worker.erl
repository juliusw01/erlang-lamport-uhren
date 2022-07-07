-module(worker).
-export([start/4, stop/1, peers/2]).

start(Name, Logger, Sleep, Jitter)->
    spawn_link(fun() -> init(Name, Logger, Sleep, Jitter) end ).

stop (Worker) ->
    Worker ! stop.

init(Name, Log, Sleep, Jitter) ->
    receive
        {peers, Peers} ->
            loop(Name, Log, Peers, Sleep, Jitter);
            stop ->
                ok
end.

peers(Wrk, Peers) ->
    Wrk ! {peers, Peers}.

loop(Name, Log, Peers, Sleep, Jitter) ->
    Wait = rand:uniform(Sleep),
    receive
        {msg, Time, Msg} ->
            Log ! {log, Name, Time, {received, Msg}},
            loop(Name, Log, Peers, Sleep, Jitter);
            stop->
                ok;

        Error ->
            Log ! {log, Name, time, {error, Error}}
after Wait ->
    Selected = select(Peers),
    Time = erlang:system_time(millisecond),
    Message = {hello, rand:uniform(100)},
    Selected ! {msg, Time, Message},
    jitter(Jitter),
        Log ! {log, Name, Time, {sending, Message}},
        loop(Name, Log, Peers, Sleep, Jitter)
end.

select(Peers) ->
    lists:nth(rand:uniform(length(Peers)), Peers).

jitter(0) -> ok;
jitter(Jitter) -> timer:sleep(rand:uniform(Jitter)).
