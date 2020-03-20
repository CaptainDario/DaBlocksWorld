% under 50 moves possible

boardLength(4).
table(0).
amountOfBlocks(12).
block(1..12).
init(5, 0).
init(6, 0).init(9,6).init(10,9).
init(2, 0).init(4,2).init(7,4).init(11,7).init(12,11).
init(1, 0).init(3,1).init(8,3).
goal(1,0).goal(2,0).goal(3,0).goal(4,0).
goal(5,1).goal(6,2).goal(7,3).goal(8,4).
goal(9,5).goal(10,6).goal(11,7).