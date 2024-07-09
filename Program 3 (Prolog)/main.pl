% Isaiah R. Harville
% 7/8/2024
% This work is not copied from another person or anywhere on the internet, or elsewhere.
% Tested in swish.swi-prolog.org

% provided by swish for the student profile
:- set_prolog_flag(occurs_check, error).        % disallow cyclic terms
:- set_prolog_stack(global, limit(8 000 000)).  % limit term space (8Mb)
:- set_prolog_stack(local,  limit(2 000 000)).  % limit environment space

% import lists library
:- use_module(library(lists)).


% -- (a) DISJOINT --
% where the intersection of two lists is empty
% tested via disjoint([], [])

disjoint([], _). % an empty list is disjoint with any list.

% if the first element of the first list is not in the second list,
% and the rest of the first list is disjoint with the second list.
disjoint([F|R], L2) :-
    \+ member(F, L2), % the head of (L1 := [F|R]) isnt in the second list
    disjoint(R, L2).

% -- (b) COUNT --
% counts the elements of the list
% tested via count_values(x, [], X) 

count_values(_, [], 0). % count is 0 when empty

% head == i
count_values(Item, [Item|Tail], Count) :-
    count_values(Item, Tail, TailCount),
    Count is TailCount + 1.

% head != i: go tail
count_values(Item, [Head|Tail], Count) :-
    Item \= Head,
    count_values(Item, Tail, Count).

% -- (c) GRADE --
% Returns a letter grade based on an integer 
% tested via grade(int, Grade)

% handle invalid input types
grade(Value, 'Invalid grade') :- \+ number(Value), !.

% define ranges per grade
grade(Value, 'A') :- number(Value), Value >= 90, Value =< 100, !.
grade(Value, 'B') :- number(Value), Value >= 80, Value < 90, !.
grade(Value, 'C') :- number(Value), Value >= 70, Value < 80, !.
grade(Value, 'D') :- number(Value), Value >= 60, Value < 70, !.
grade(Value, 'F') :- number(Value), Value >= 0, Value < 60, !.

% error msg
grade(Value, 'Invalid grade') :- number(Value), (Value < 0; Value > 100), !.
