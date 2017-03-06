%%% distributed algorithms, n.dulay 27 feb 17
%%% coursework 2, paxos made moderately complex
%%% tb1414

-module(replica).
-export([start/1]).

start(Database) ->
  receive
    {bind, Leaders} ->
      State = ,%%%initial State
      Slot_in = 1,
      Slot_out = 1,
      Requests = [],
      Proposals = [],
      Decisions = [],
      next(State, Slot_in, Slot_out, Requests, Proposals, Decisions, Leaders)
  end.

next(State, Slot_in, Slot_out, Requests, Proposals, Decisions, Leaders) ->
  receive
    {request, C} ->      % request from client
      ...
    {decision, S, C} ->  % decision from commander
      ... = decide (...)
  end, % receive

  ... = propose(...),
  ...

propose(Slot_in, Slot_out, Requests, Proposals, Decisions, Leaders) ->
  WINDOW = 5,
  while Slot_in < Slot_out+WINDOW and length(Requests) /= 0 ->
    Ops = [ Op || {S, {_, _, Op}} <- Decisions, S == Slot_in - WINDOW ],
    if length(Ops) > 0 ->
      [Op | _] = Ops,
  end.


decide(...) ->
  ...
       perform(...),
  ...

perform(...) ->
  ...
      Database ! {execute, Op},
      Client ! {response, Cid, ok}
