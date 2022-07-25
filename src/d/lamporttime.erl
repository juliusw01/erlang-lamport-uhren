-module(lamporttime).

-export([zero/0, inc/1, merge/2, leq/2, startClocks/1, update/3, canLog/1]).

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

startClocks(Nodes) -> lists:foldl(fun(Node, Clocks) -> [{Node, zero()} | Clocks] end, [], Nodes).

canLog(Clocks) -> element(2, hd(lists:keysort(2, Clocks))).

update(Node, Time, Clocks) -> lists:keyreplace(Node, 1, Clocks, {Node, Time}).
