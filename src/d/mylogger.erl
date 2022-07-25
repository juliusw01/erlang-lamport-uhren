-module(mylogger).
-export([start/1, stop/1]).


start(Nodes) ->
  spawn_link(fun() -> init(Nodes) end).

stop(Logger) ->
  Logger ! stop.

init(Nodes) ->
  loop(lamporttime:startClock(Nodes), []).

loop(Clocks, HoldBackQueue) ->

  receive

    {log, From, Time, Msg} ->

        UpdatedClockList = lamporttime:update(From, Time, Clocks),
        CheckedTimestamp = lamporttime:canLog(UpdatedClockList),

        if
          Time =:= 1 ->
                SortedQueue = lists:keysort(2, HoldBackQueue),
                log(From, Time, Msg);
            true ->
                SortedQueue = lists:keysort(2, HoldBackQueue ++ [{From, Time, Msg}])
        end,

        {MsgQueue, Temp} = lists:splitwith(fun({_, Timestamp, _}) -> 
          lamporttime:leq(Timestamp, CheckedTimestamp)
          end,
        SortedQueue),

        lists:foreach(
          fun({Sender, Timestamp, Message}) -> 
            log(Sender, Timestamp, Message)
          end,
        MsgQueue),
  
        loop(UpdatedClockList, Temp);

    stop ->
        ok

  end.

log(From, Time, Msg) ->
  io:format("log: ~w ~w ~p~n", [Time, From, Msg]). 