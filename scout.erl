%%% distributed algorithms, n.dulay 27 feb 17
%%% coursework 2, paxos made moderately complex
%%% tb1414  hh2214

-module(scout).
-export([start/3]).

start(L, Acceptors, B) ->
  [ A ! {p1a, self(), B} || A <- Acceptors ],
  Waitfor = Acceptors,
  PValues = [],
  next(L, Acceptors, B, Waitfor, PValues).

next(L, Acceptors, B, Waitfor, PValues) ->
  receive
    {p1b, A, B_new, R} ->
      if
        B == B_new ->
          New_PValues = [R | PValues],
          New_Waitfor = [ W || W <- Waitfor, W /= A ],
          if length(New_Waitfor) < length(Acceptors) / 2 ->
            L ! {adopted, B, New_PValues},
            exit(normal)
          end,
          next(L, Acceptors, B, New_Waitfor, New_PValues);
        true ->
          L ! {preempted, B_new}
      end
  end. % receive
