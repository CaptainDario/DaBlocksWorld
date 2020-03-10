#program base.
% DOMAIN
t(0).
do(X,Z)   :- init(X,Y), not table(Y), table(Z).
do(X,Y)   :- goal(X,Y), not table(Y).
on(X,Y,0) :- init(X,Y).
 
#program check(t).
% TEST
:- query(t), goal(X,Y),  not on(X,Y,t).
#program step(t).

% GENERATE
1 {move(X,Y,t) : do(X,Y)} 1.

% DEFINE
move(X,t) :- move(X,Y,t).
on(X,Y,t) :- move(X,Y,t).
on(X,Y,t) :- on(X,Y,t-1), not move(X,t).
lock(Y,t) :- on(X,Y,t-1), not table(Y).
firm(X,t) :- on(X,Y,t), table(Y).
firm(X,t) :- on(X,Y,t), firm(Y,t).
% TEST
:- lock(X,t), move(X,t).
:- lock(Y,t), move(X,Y,t).
:- init(Y,Z), #count{X : on(X,Y,t)} > 1.
:- init(X,Z), #count{Y : on(X,Y,t)} > 1.
:- init(X,Z), not firm(X,t).

% DISPLAY
#show move/3.