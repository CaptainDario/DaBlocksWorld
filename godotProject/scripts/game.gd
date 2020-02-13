extends Spatial



onready var block = preload("res://scenes/block.tscn")

#the block
var blocks = []

#the board length
var boardLength : int
#the maximum height
var maxHeight : int = 10
#the board as matrix
var board = []
#the state which is defined as goal (the state in which the current board has to be transformed)
var goalBoard = []
#the number of moves the player has done until now
var moves : int = 0

var cBlack : Color = Color8(0, 0, 0, 255)
var cWhite : Color = Color8(255, 255, 255, 255)


func _ready():


	#get the length of the ground (board length)
	boardLength = get_node("ground").scale.x * 2

	#initialize the currentBoard and goalBoard 
	for x in range(boardLength):
		board.append([])
		goalBoard.append([])
		for y in range(maxHeight):
			board[x].append(0)
			goalBoard[x].append(0)

	#subtract 1 of the maximum height so an array out of range is prevented
	maxHeight -= 1

	#Generate currentBoard and goalBoard
	generateBoards()


func generateBoards():
	"""
	This generates a current board state and a goal board state.
	According to the current board state all blocks will be instantiated.
	"""
	var numOfBlocks = 10
	
	for b in range(numOfBlocks):
		#CURRENT BOARD
		#create random block coordinate for the currentBoard
		var rndBlockCur = generateRandomBlock()
		#instantiate the block 
		var blockInst = block.instance()
		blockInst.set("currentPosition", rndBlockCur)
		add_child(blockInst)
		blockInst.translate(rndBlockCur * 2)
		#create materials for this block and override old
		var newMaterial = SpatialMaterial.new()
		newMaterial.albedo_color = cBlack
		blockInst.get_node("OuterCube").material_override = newMaterial
		newMaterial = SpatialMaterial.new()
		newMaterial.albedo_color = cWhite
		blockInst.get_node("InnerCube").material_override = newMaterial
		#set the name of this block
		blockInst.name = "block" + str(b + 1)
		#set the position in the grid
		board[rndBlockCur.x][rndBlockCur.y] = b + 1
		#set the blocks number
		blockInst.setNumber(b + 1)
		#apply gravity to this block
		blockInst.applyGravity()
		#add the block to the list with all blocks
		blocks.append([b, blockInst])

		#GOAL BOARD
		#get a random coor which has a different x-coor from the currentBoard-coor
		var rndBlockGoal = rndBlockCur
		while(rndBlockCur.x == rndBlockGoal.x):
			rndBlockGoal = generateRandomBlock()
		goalBoard[rndBlockGoal.x][rndBlockGoal.y] = b + 1
		#apply gravity to this block
		var moved = true
		while moved:
			moved = false
			#if directly below this block is no other block
			if(goalBoard[rndBlockGoal.x][rndBlockGoal.y - 1] == 0
				and rndBlockGoal.y > 0):
				#move the block down one field
				goalBoard[rndBlockGoal.x][rndBlockGoal.y - 1] = b + 1
				goalBoard[rndBlockGoal.x][rndBlockGoal.y] = 0
				rndBlockGoal -= Vector3(0, 1, 0)
				moved = true

		

func generateRandomBlock() -> Vector3:
	"""
	Generate a random location for a block.
	This functions assures that on the generate location is no other block.

	Returns:
		A Vector3 which contains the position.
		note: z will always be 0
	"""

	randomize()

	var randX : int
	var randY : int
	var valid : bool = false

	while !valid:
		randX = randi() % (boardLength - 1)
		randY = randi() % (maxHeight - 1)

		#make sure there is no block on this cell
		if(board[randX][randY] == 0):
			valid = true

	return Vector3(randX, randY, 0)
