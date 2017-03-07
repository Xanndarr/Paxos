%%% distributed algorithms, n.dulay 27 feb 17
%%% coursework 2, paxos made moderately complex
%%% tb1414

-module(leader).
-export([start/2]).

start(Acceptors, Replicas) ->
  Ballot_Num = {0, self()},
  Active = false,
  Proposals = [],
  spawn(scout, start, [self(), Acceptors, Ballot_Num]),
  next(Acceptors, Replicas, Ballot_Num, Active, Proposals).

next(Acceptors, Replicas, Ballot_Num, Active, Proposals) ->
  receive
    {propose, S, C} ->
      Len = length([ found || {S_, _} <- Proposals, S == S_ ]),
      if
        Len == 0 ->
          New_Proposals = [{S, C} | Proposals],
          if Active ->
            spawn(commander, start, [self(), Acceptors, Replicas, {Ballot_Num, S, C}])
          end,
          next(Acceptors, Replicas, Ballot_Num, Active, New_Proposals)
      end;
    {adopted, B_Num, PVals} ->
      PMax = [ {S, C} || {B, S, C} <- PVals, {B_, S_, C_} <- PVals, B_ =< B, S == S_ ], %%%%%%%%%%%%%%%%%broken
      New_Proposals = PMax ++ [ P || P <- Proposals, not lists:member(P, PMax) ],
      [ spawn(commander, start, [self(), Acceptors, Replicas, {Ballot_Num, S, C}]) || {S, C} <- Proposals ],
      New_Active = true,
      next(Acceptors, Replicas, Ballot_Num, New_Active, New_Proposals);
    {preempted, {R_, L_}} ->
      if
        {R_, L_} > Ballot_Num ->
          New_Active = false,
          New_Ballot_Num = {R_ + 1, self()},
          spawn(scout, start, [self(), Acceptors, New_Ballot_Num]),
          next(Acceptors, Replicas, New_Ballot_Num, New_Active, Proposals);
        true ->
          next(Acceptors, Replicas, Ballot_Num, Active, Proposals)
      end
  end. % receive
