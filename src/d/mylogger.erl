-module(mylogger).
-export([start/1, stop/1]).

start(Nodes) ->
    spawn_link(fun() ->init(Nodes) end).

stop(Logger)->
    Logger ! stop.

init(_) ->
    ListSend = [],
    ListRec = [],
    loop(ListSend, ListRec).

loop(ListSend, ListRec) ->
    receive
        {log, From, Msg, Lamp} ->
          {A,B} = Msg,
          if
            A =:= sending -> log(From, Msg, Lamp), NewSend = ListSend ++ [{From, Msg, Lamp}], NewRec = ListRec;
            A =:= received ->
              X = lists:keyfind({sending,{hello,B}}, 2, ListSend),
              if
                X =:= false -> NewRec = ListRec ++ [{From, Msg, Lamp}], NewSend = ListSend;
                true -> log(From, Msg, Lamp), NewSend = lists:keydelete({sending,{hello,B}}, 2, ListSend), NewRec = ListRec
              end;
            true -> NewSend = ListSend, NewRec = ListRec
          end,
          L = erlang:length(NewRec),
          if
            L =:= 1 -> loop(NewSend, NewRec);
            true -> testRec(NewSend, NewRec, 1)
          end;

        stop ->
                        ok
end.

testRec(ListSend, ListRec, N) ->
  {From,Msg,Lamp} = lists:nth(N, ListRec),
  {_,B} = Msg,
  {_,C} = B,
  X = lists:keyfind({sending,{hello,C}}, 2, ListSend),
  L = erlang:length(ListRec),
  if
    L =:= N + 1 ->loop(ListSend, ListRec);
    X =:= false -> testRec(ListSend, ListRec, N + 1);
    true -> {_,_,Lapmo} = X, Log = lamporttime:leq(Lapmo, Lamp),
      if
        Log =:= true -> log(From, Msg, Lamp), NewSend = lists:keydelete({sending,{hello,C}}, 2, ListSend), NewRec = lists:keydelete(Msg, 2, ListRec), testRec(NewSend, NewRec, N);
        true -> loop(ListSend, ListRec)
      end

  end.

log(From, Msg, Lamp) ->
      io:format("log: ~w\t ~p\t Lamporttime: ~p\t~n", [From, Msg, Lamp]).