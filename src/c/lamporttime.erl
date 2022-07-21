-module(lamporttime).
-export([zero/0, inc/1, merge/2,leq/2]).

%Gibt den Wert 0 zurück
zero() ->
    0.

% erhöht den Wert Ti um 1
inc(T) ->
    T + 1.

% vergleicht die Werte Ti und Tj und gibt den größeren zurück
merge(Ti, Tj) -> 
    if
        Ti > Tj -> Ti;

        Tj > Ti -> Tj;
            
        true -> Tj
            
    end.

% falls Ti kleiner oder gleich groß wie Tj ist, wird der Wert 'true' zurückgegeben
leq(Ti, Tj) -> (Ti =< Tj).