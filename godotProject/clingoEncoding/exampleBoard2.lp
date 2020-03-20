% under 30 moves possible

leftBorder(0).
rightBorder(3).
table(0).
boardLength(5).
block(1..11).

init(2, 0).init(7,2).init(8,7).
init(3, 0).init(6,3).init(9,6).init(12,9).
init(1, 0).init(4,1).init(5,4).init(10,5).init(11,10).
goal(1,0).goal(2,0).goal(3,0).goal(4,0).
goal(5,1).goal(6,2).goal(7,3).goal(8,4).
goal(9,5).goal(10,6).goal(11,7).