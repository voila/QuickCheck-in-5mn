%%% delete_all(X,L) deletes all elements X from L 
%%% There's a bug !
-module(listdel).
-export([delete_all/2]).
-include_lib("proper/include/proper.hrl").
-include_lib("eunit/include/eunit.hrl").
-import(lists,[seq/2]).


%% A lists delete implementation
-spec delete_all(T, list(T)) -> list(T).
delete_all(X, L) ->
    delete_all(X, L, []).

delete_all(_, [], Acc) ->
    lists:reverse(Acc);
delete_all(X, [X|Rest], Acc) ->
    lists:reverse(Acc) ++ Rest;   %% buggy
    %% delete_all(X, Rest, Acc);  %% fine
delete_all(X, [Y|Rest], Acc) ->
    delete_all(X, Rest, [Y|Acc]).


%%-----------------------------------------------------------------
%% Unit tests
%% > eunit:test(listdel).
%%-----------------------------------------------------------------
delete_test_() ->
    [?_assertEqual(delete_all(1,[]), []),
     ?_assertEqual(delete_all(1,[1,2,3,4]), [2,3,4]),
     ?_assertEqual(delete_all(5,[1,2,3,4,5]), [1,2,3,4]),
     ?_assertEqual(delete_all(-3, [-5,-4,-3,-2,-1]), [-5,-4,-2,-1]),
     ?_assertEqual(delete_all(100, seq(1,100)), seq(1,99))
    ].

%%-----------------------------------------------------------------
%% Properties
%% > proper:quickcheck(listdel:prop_delete1(), 10).
%%-----------------------------------------------------------------
%% For any integer x and any list of integers l,
%% if I delete x from l, then l does not contain x
prop_delete1() ->
    ?FORALL({X,L},                                  % variables 
            {integer(), list(integer())},           % generators
            not lists:member(X, delete_all(X, L))). % property

%% same with stats
prop_delete2() ->
    ?FORALL({X,L},                              
            {integer(), list(integer())}, 
            collect(lists:member(X, L), %% is X a member of L ?
            not lists:member(X, delete_all(X, L)))).


%% Generate more relevant test data:
%% non-empty lists and only delete actual list elements
prop_delete3() -> 
    ?FORALL(L, 
            list(integer()), 
            ?IMPLIES(L /= [], 
                     ?FORALL(X, oneof(L), 
                             not lists:member(X,delete_all(X,L))))). 

prop_delete4() -> 
    ?FORALL(L, 
            list(integer()), 
            ?IMPLIES(L /= [], 
                     ?FORALL(X, elements(L), 
                             collect({X, L}, %% with stats
                                     not lists:member(X,delete_all(X,L)))))). 


%% Custom test data generator to generate lists of duplicates
duplist(Type) -> 
    ?LET(L,list(Type), 
       L ++ L).

prop_delete5() ->
    ?FORALL({X,L}, 
            {integer(), duplist(integer())},
            not lists:member(X, delete_all(X, L))).

prop_delete6() ->
    ?FORALL({X,L}, 
            {integer(), duplist(integer())},
            collect({X, L}, %% show generated X and L
                    not lists:member(X, delete_all(X, L)))).


