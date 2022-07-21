-module(test).

-export([run/2]).

run(Sleep, Jitter) ->
    Log = mylogger:start([einstein, euler, curie, turing]),
    A = worker:start(einstein, Log, Sleep, Jitter),
    B = worker:start(euler, Log, Sleep, Jitter),
    C = worker:start(curie, Log, Sleep, Jitter),
    D = worker:start(turing, Log, Sleep, Jitter),
    worker:peers(A, [B, C, D]),
    worker:peers(B, [A, C, D]),
    worker:peers(C, [A, B, D]),
    worker:peers(D, [A, B, C]),
    timer:sleep(5000),
    mylogger:stop(Log),
    worker:stop(A),
    worker:stop(B),
    worker:stop(C),
    worker:stop(D).