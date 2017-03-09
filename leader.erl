%%% distributed algorithms, n.dulay 27 feb 17
%%% coursework 2, paxos made moderately complex
%%% tb1414  hh2214

-module(leader).
-export([start/0]).

start() ->
  receive
    {bind, Acceptors, Replicas} ->
      Ballot_Num = {0, self()},
      Active = false,
      Proposals = sets:new(),
      spawn(scout, start, [self(), Acceptors, Ballot_Num]),
      next(Acceptors, Replicas, Ballot_Num, Active, Proposals)
  end.

next(Acceptors, Replicas, Ballot_Num, Active, Proposals) ->
  receive
    {propose, S, C} ->
      Len = length([ found || {S_, _} <- sets:to_list(Proposals), S == S_ ]),
      if
        Len == 0 ->
          New_Proposals = sets:add_element({S, C}, Proposals),
          if
            Active ->
              spawn(commander, start, [self(), Acceptors, Replicas, {Ballot_Num, S, C}]);
            true ->
              ok
          end,
          next(Acceptors, Replicas, Ballot_Num, Active, New_Proposals);
        true ->
          next(Acceptors, Replicas, Ballot_Num, Active, Proposals)
      end;
    {adopted, B_Num, PVals} ->
      Prop_List = sets:to_list(Proposals),
      New_Proposals = sets:union(
                        [sets:from_list(
                            [ {S, C} || {S, C} <- Prop_List, not filter_slot(S, Prop_List) ]
                        ), PVals]
                      ),
      [ spawn(commander, start, [self(), Acceptors, Replicas, {B_Num, S, C}]) || {S, C} <- sets:to_list(New_Proposals) ],
      New_Active = true,
      next(Acceptors, Replicas, B_Num, New_Active, New_Proposals);
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

filter_slot(Slot, [ {Slot, _} | _]) ->
  true;
filter_slot(Slot, [_ | L]) ->
  filter_slot(Slot, L);
filter_slot(_, _) ->
  false.
