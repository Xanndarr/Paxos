%%% distributed algorithms, n.dulay 27 feb 17
%%% coursework 2, paxos made moderately complex
%%% tb1414  hh2214

-module(acceptor).
-export([start/0]).

start() ->
  Ballot_num = undefined,
  Accepted = sets:new(),
  next(Ballot_num, Accepted).

next(Ballot_num, Accepted) ->
  receive
    {p1a, L, B} ->
      if
        B > Ballot_num ->
          L ! {p1b, self(), B, Accepted},
          next(B, Accepted);
        true ->
          L ! {p1b, self(), Ballot_num, Accepted},
          next(Ballot_num, Accepted)
      end;
      {p2a, L, {B, S, C}} ->
        L ! {p2b, self(), Ballot_num},
        if
          B == Ballot_num ->
            New_Accepted = sets:add_element({B, S, C}, Accepted),
            next(B, New_Accepted);
          true ->
            next(Ballot_num, Accepted)
        end
  end. % receive
