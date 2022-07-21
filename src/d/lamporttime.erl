-module(lamporttime).

-export([zero/0, inc/1, merge/2, leq/2]).

zero() ->
  0.

inc(T) ->
  T + 1.

merge(Ti, Tj) ->
  if
    Ti < Tj -> Tj;
    Ti > Tj -> Ti;
    true -> Ti
  end.

leq(Ti, Tj) ->
  Ti =< Tj.