extends Spatial



onready var block = preload("res://scenes/block.tscn")

#number of blocks which should be generated
var numOfBlocks : int
#the blocks
var blocks = []
#the board length
var boardLength : int
#the maximum height
var maxHeight : int
#the board as matrix
var board = []
#the state which is defined as goal (the state in which the current board has to be transformed)
var goalBoard = []
#the number of moves the player has done until now
var moves : int = 0
#the colors for the cubes
var cBlack : Color = Color8(0, 0, 0, 255)
var cWhite : Color = Color8(255, 255, 255, 255)


func _ready():

	randomize()
	difficutly()

	initializeBoards()
	generateCurrentBoard()
	generateGoalBoard()

func initializeBoards():
	"""
	Initializes the current and goal board.
	"""
	for x in range(boardLength):
		board.append([])
		goalBoard.append([])
		for y in range(maxHeight):
			board[x].append(0)
			goalBoard[x].append(0)

	#subtract 1 of the maximum height so an array out of range is prevented
	maxHeight -= 1

func difficutly():
	"""
	Set all variables according to the selected difficulty.
	(Board length, max height, number of blocks)
	"""


	if(globals.difficulty == "easy"):
		#range(inluive upper and lower bound) 3-5
		self.boardLength = 4  
		self.numOfBlocks = self.boardLength * (self.boardLength - 1)
		self.maxHeight = self.boardLength + 4
	elif(globals.difficulty == "casual"):
		#range(inluive upper and lower bound) 3-5
		self.boardLength = 5  
		self.numOfBlocks = self.boardLength * (self.boardLength - 1)
		self.maxHeight = self.boardLength + 4
	elif(globals.difficulty == "hard"):
		#range(inluive upper and lower bound) 3-5
		self.boardLength = (randi() % 2 + 6)  
		self.numOfBlocks = self.boardLength * (self.boardLength - 1)
		self.maxHeight = self.boardLength + 3
	elif(globals.difficulty == "very hard"):
		#range(inluive upper and lower bound) 3-5
		self.boardLength = (randi() % 2 + 8)  
		self.numOfBlocks = self.boardLength * (self.boardLength - 1)
		self.maxHeight = self.boardLength + 2

	print(boardLength) 
	
	#get the length of the ground (board length)
	var gnd = get_node("ground")
	gnd.scale = Vector3(boardLength / 2.0, gnd.scale.y, gnd.scale.z)
	gnd.global_translate(Vector3((boardLength / 2.0) - 0.5, 0, 0))

	#move camera
	var cam = get_viewport().get_camera()
	cam.look_at_from_position(Vector3(boardLength, maxHeight - 1, 10 + boardLength / 3), \
								Vector3(boardLength / 2, maxHeight / 2, 0), \
								Vector3.UP)

func generateCurrentBoard():
	"""
	This generates a current board state and a goal board state.
	According to the current board state all blocks will be instantiated.
	"""
	
	for b in range(self.numOfBlocks):
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
		blockInst.set("lastPosition", blockInst.currentPosition)
		#add the block to the list with all blocks
		blocks.append(blockInst)

func generateGoalBoard():
	"""
	Generates a block configuration for the winning board.
	"""
	for b in range(self.numOfBlocks):
		var x = b % boardLength 
		var y = b / boardLength
		goalBoard[x][y] = b + 1

func generateRandomBlock() -> Vector3:
	"""
	Generate a random location for a block.
	This functions assures that on the generate location is no other block.
	The first and last column will not be used for palcing cubes.

	Returns:
		A Vector3 which contains the position.
		note: z will always be 0
	"""


	var randX : int
	var randY : int
	var valid : bool = false

	while !valid:
		randX = randi() % boardLength
		randY = randi() % maxHeight
		
		#make sure there is no block on this cell
		if(board[randX][randY] == 0):
			valid = true

	return Vector3(randX, randY, 0)
