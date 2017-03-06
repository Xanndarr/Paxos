%%% distributed algorithms, n.dulay 27 feb 17
%%% coursework 2, paxos made moderately complex
%%% tb1414

-module(acceptor).
-export([start/0]).

start() ->
  Ballot_num = {-1, -1},
  Accepted = [],
  next(Ballot_num, Accepted).

next(Ballot_num, Accepted) ->
  receive
    {p1a, L, B} ->
      if
        compare(B, Ballot_Num) == 1 ->
          L ! {p1b, self(), B, Accepted},
          next(B, Accepted);
        true ->
          L ! {p1b, self(), Ballot_num, Accepted},
          next(Ballot_num, Accepted)
      end;
      {p2a, L, {B, S, C}} ->
        L ! {p2b, self(), Ballot_Num},
        if
          compare(B, Ballot_num) == 0 ->
            next(B, [{B, S, C} | Accepted]);
          true ->
            next(Ballot_num, Accepted)
        end.
  end. % receive

compare({B, _}, {B_, _}) ->
  if
    B < B_ -> -1;
    B == B_ -> 0;
    B > B_ -> 1
  end.
