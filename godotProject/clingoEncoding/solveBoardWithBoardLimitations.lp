#include <incmode>.

#program base.
% DOMAIN
do(X,Y)   :- block(X), block(Y), X != Y.
do(X,Y)   :- block(X), table(Y).
on(X,Y,0) :- init(X,Y).
#program step(t).
% GENERATE                              
1 {move(X,Y,t) : do(X,Y)} 1.
% DEFINE
move(X,t) :- move(X,Y,t).
on(X,Y,t) :- move(X,Y,t).
on(X,Y,t) :- on(X,Y,t-1), not move(X,t).
lock(Y,t) :- on(X,Y,t-1), not table(Y).
height(B, 1, t) :- on(B, 0, t).
height(B1, H+1, t) :- height(B2, H, t), on(B1, B2, t), amountOfBlocks(A), H < A.
% TEST
:- lock(X,t), move(X,t).
:- lock(Y,t), move(X,Y,t).
:- init(Y,Z), #count{X : on(X,Y,t)} > 1.
:- init(X,Z), #count{Y : on(X,Y,t)} > 1.
:- boardLength(L), #count{X,t : on(X,0,t)} > L.
:- height(B, H, t), boardHeight(MH), H > MH.
#program check(t).
% TEST
:- query(t), goal(X,Y),  not on(X,Y,t).
% DISPLAY
#show move/3.