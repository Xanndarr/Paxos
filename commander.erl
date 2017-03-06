%%% distributed algorithms, n.dulay 27 feb 17
%%% coursework 2, paxos made moderately complex
%%% tb1414

-module(commander).
-export([start/4]).

start(L, Acceptors, Replicas, {B, S, C}) ->
  [ A ! {p2a, self(), {B, S, C}} || A <- Acceptors ],
  Waitfor = Acceptors,
  next(L, Acceptors, Replicas, {B, S, C}, Waitfor).

next(L, Acceptors, Replicas, {B, S, C}, Waitfor) ->
  receive
    {p2b, A, B_new} ->
      if
        B == B_new ->
          New_Waitfor = [ W || W <- Waitfor, W /= A ],
          if length(New_Waitfor) < length(Acceptors) / 2 ->
            [ R ! {decision, S, C} || R <- Replicas ],
            exit(normal)
          end,
          next(L, Acceptors, Replicas, {B, S, C}, New_Waitfor);
        true ->
          L ! {preempted, B_new}
      end
  end. % receive
