%%% distributed algorithms, n.dulay 27 feb 17
%%% coursework 2, paxos made moderately complex
%%% tb1414  hh2214

-module(replica).
-export([start/1]).

start(Database) ->
  receive
    {bind, Leaders} ->
      State = Database,
      Slot_in = 1,
      Slot_out = 1,
      Requests = sets:new(),
      Proposals = maps:new(),
      Decisions = maps:new(),
      next(State, Slot_in, Slot_out, Requests, Proposals, Decisions, Leaders)
  end.

next(State, Slot_in, Slot_out, Requests, Proposals, Decisions, Leaders) ->
  {Slot_out3, Decisions3, Proposals3, Requests3} =

  receive
    {request, C} ->      % request from client
      Requests2 = sets:add_element(C, Requests),
      {Slot_out, Decisions, Proposals, Requests2};
      %next(State, Slot_in, Slot_out, NewRequests, Proposals, Decisions, Leaders);
    {decision, S, C} ->  % decision from commander
      Decisions2 = maps:put(S, C, Decisions),
      decide(State, Slot_out, Decisions2, Proposals, Requests)
  end,

  {Slot_in4, Slot_out4, Requests4, Proposals4, Decisions4, Leaders4} =
    propose(Slot_in, Slot_out3, Requests3, Proposals3, Decisions3, Leaders),
  next(State, Slot_in4, Slot_out4, Requests4, Proposals4, Decisions4, Leaders4).


propose(Slot_in, Slot_out, Requests, Proposals, Decisions, Leaders) ->
  WINDOW = 5,
  Request_Size = sets:size(Requests),
  if (Slot_in < Slot_out+WINDOW) and (Request_Size > 0) ->
        FoundVal = maps:is_key(Slot_in, Decisions),
        {Requests3, Proposals3} = if not FoundVal ->
                                      C = lists:min(sets:to_list(Requests)),
                                      Requests2 = sets:del_element(C, Requests),
                                      Proposals2 = maps:put(Slot_in, C, Proposals),

                                      [Leader ! {propose, Slot_in, C} || Leader <- Leaders], %% TODO USE SEND FUNCTION???

                                      {Requests2, Proposals2};
                                    FoundVal  -> {Requests, Proposals}
                                  end,
        propose(Slot_in + 1, Slot_out, Requests3, Proposals3, Decisions, Leaders);
      true ->
        {Slot_in, Slot_out, Requests, Proposals, Decisions, Leaders}
    end.



decide(State, Slot_out, Decisions, Proposals, Requests) ->
  HasKey = maps:is_key(Slot_out, Decisions),
  if  HasKey ->
      CP = maps:get(Slot_out, Decisions),
      HasKey2 = maps:is_key(Slot_out, Proposals),
      {Proposals3, Requests3} = if HasKey2 ->
                                    CPP = maps:get(Slot_out, Proposals),
                                    Proposals2 = maps:remove(Slot_out, Proposals),
                                    if CP /= CPP ->
                                        Requests2 = sets:del_element(CPP, Requests),
                                        {Proposals2, Requests2};
                                      true -> {Proposals2, Requests}
                                    end;
                                  true -> {Proposals, Requests}
                                end,
      perform(CP, State),
      decide(State, Slot_out + 1, Decisions, Proposals3, Requests3);
    true ->
      {Slot_out, Decisions, Proposals, Requests}
  end.

perform(CP, State) ->
  {Client, Cid, Op} = CP,
  State ! {execute, Op},
  Client ! {response, Cid, ok}.
