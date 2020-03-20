extends Spatial



onready var block = preload("res://scenes/block.tscn")

#number of blocks which should be generated
var numOfBlocks : int
#the blocks
var blocks = []
#the board length (the maximum width where the player can move blocks)
var boardLength : int = 0
#the maximum height to where the player can move bocks
var maxHeight : int = 0
#the maximum width where blocks can be set during board creation
var maxGenLength
#the maximum height where blocks can be set during board creation
var maxGenHeight
#the minimum number of moves needed to solve this puzzle
var minMoves : int
#the board as matrix
var board = []
#the start configuration of the board so that the player can try again
var startBoard : Array = []
#the goal heihgt of all blocks
var goalBoardHeight : Dictionary = {}
#the goal heihgt of all blocks
var goalBoardBlockBelow : Dictionary = {}
#the number of moves the player has done until now
var moves : int = 0
#an array with all the optimal moves
var optimalMoves : Array = []
#the colors for the cubes
var cBlack : Color = Color8(0, 0, 0, 255)
var cWhite : Color = Color8(255, 255, 255, 255)
#order: red, green, blue, orange, purple
var blockColors : Array = [Color8(255, 17, 0, 255), Color8(0, 255, 13, 255), Color8(0, 4, 255, 255),\
							Color8(255, 157, 0, 255), Color8(255, 0, 217, 255)]


func _ready():

	randomize()
	blockColors.shuffle()
	difficutly()
	
	initializeBoards()
	generateGoalBoard()
	generateStartBoard()
	self.startBoard = Array(self.board)

	#solve the puzzle with clingo and get the needed board dimensions
	var strBoard = boardToAtoms(board)
	#print("starting clingo")
	var clingoOut = solveBoardWithClingo(strBoard)
	#print(clingoOut)
	self.optimalMoves = getOptimalMovesFromCingoOutput(clingoOut[0])
	var minHeight = getBoardHeight(clingoOut[0])
	if(minHeight > self.maxHeight):
		self.maxHeight = minHeight
	var minBoardLength = getBoardLength(clingoOut[0])
	if(minBoardLength > self.boardLength):
		self.boardLength = minBoardLength

	#set the minimal moves at the top
	get_node("/root/GM/Control/labels/moves/CenterContainer/HBoxContainer/minimum").text = str(self.optimalMoves.size())

	self.resizeBoardForOptimalPlan()

	#set the color correctly if it is on the correct spot 
	for block in self.blocks:
		block.checkPosIsValid()

	#instantiate the board, blocks and set the camera
	self.setGraphics()


func difficutly():
	"""
	Set all variables according to the selected difficulty.
	(Board length, max height, number of blocks)
	"""

	if(globals.difficulty == "easy"):
		#range(inluive upper and lower bound) 3-5
		self.maxGenLength = 3
		self.numOfBlocks = self.maxGenLength * (self.maxGenLength - 1)
	elif(globals.difficulty == "casual"):
		#range(inluive upper and lower bound) 3-5
		self.maxGenLength = 4 
		self.numOfBlocks = self.maxGenLength * (self.maxGenLength - 1) 
	elif(globals.difficulty == "hard"):
		#range(inluive upper and lower bound) 3-5
		self.maxGenLength = 4  
		self.numOfBlocks = self.maxGenLength * (self.maxGenLength - 1) + self.maxGenLength
	elif(globals.difficulty == "very hard"):
		#range(inluive upper and lower bound) 3-5
		self.maxGenLength = 4
		self.numOfBlocks = self.maxGenLength * (self.maxGenLength - 1) + self.maxGenLength * 2

	self.maxGenHeight = (self.numOfBlocks / self.maxGenLength) * 2
	
	print(boardLength) 

func initializeBoards():
	"""
	Initializes the current and goal board.
	"""
	for x in range(maxGenLength):
		self.board.append([])
		for y in range(maxGenHeight + 1):
			self.board[x].append(0)

	#subtract 1 of the maximum height so an array out of range is prevented
	maxGenHeight -= 1

func generateStartBoard():
	"""
	Generates a current board state and a goal board state.
	According to the current board state all blocks will be instantiated.
	"""
	
	var currentStackColor : Color
	
	for b in range(self.numOfBlocks):
		#the number which will be displayed on this block (change color when new stack)
		var disNr : int = (b % self.maxGenLength) + 1
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
		if(disNr == 1):
			currentStackColor = blockColors.pop_front()
		newMaterial.albedo_color = currentStackColor
		blockInst.get_node("InnerCube").material_override = newMaterial
		#set the name of this block
		blockInst.name = "block" + str(b + 1)
		#set the position in the grid
		board[rndBlockCur.x][rndBlockCur.y] = b + 1
		#set the blocks number
		blockInst.setNumber(b + 1, disNr)
		#apply gravity to this block
		blockInst.applyGravity()
		blockInst.set("lastPosition", blockInst.currentPosition)
		#add the block to the list with all blocks
		blocks.append(blockInst)

func generateGoalBoard():
	"""
	Generates a block configuration for the winning board.
	"""
	
	var cnt : int = 1
	for x in range(self.maxGenLength):
		for y in range(self.maxGenHeight):
			if(cnt <= self.numOfBlocks):
				var height : int = (cnt - 1) % self.maxGenLength
				self.goalBoardHeight[cnt] = height
				if(height == 0):
					self.goalBoardBlockBelow[cnt] = 0
				else:
					self.goalBoardBlockBelow[cnt] = cnt - 1
			cnt += 1

func generateRandomBlock() -> Vector3:
	"""
	Generate a random location (for a block).
	This functions assures that on the generate location is no other block.

	Returns:
		A Vector3 which contains the position.
		note: z will always be 0
	"""

	var randX : int
	var randY : int
	var valid : bool = false

	while !valid:
		randX = randi() % self.maxGenLength
		randY = randi() % self.maxGenHeight
		
		#make sure there is no block on this cell
		if(board[randX][randY] == 0):
			valid = true

	return Vector3(randX, randY, 0)

func boardToAtoms(_board) -> String:
	"""
	Returns a string representation of the current board.
	This string matches the syntax of clingo.

	Args:
		_board : the board which should be translated to a representaiton which than can be solved with clingo.

	Returns:
		The string representation of the board.
	"""

	var boardStr = ""

	boardStr += "block(1.." + str(blocks.size()) + ")." + "\n"
	boardStr += "amountOfBlocks(" + str(blocks.size()) + ")." + "\n"
	boardStr += "table(0)." + "\n\n"

	#add the initial state of all blocks
	for x in _board.size():
		for y in _board[x].size():
			if(board[x][y] != 0):
				if(y > 0):
					boardStr += "init(" + str(_board[x][y]) + "," + str(_board[x][y-1]) + ")."
				if(y == 0):
					boardStr += "init(" + str(_board[x][y]) + ", 0)."
		boardStr += "\n"
	boardStr += "\n"

	#add the goal state of all blocks
	for b in self.goalBoardBlockBelow.keys():
		boardStr += "goal(" + str(b) + "," + str(self.goalBoardBlockBelow[b]) + ")."

	return boardStr

func solveBoardWithClingo(_board : String) -> String:
	"""
	Solve the given _board with clingo.

	Args:
		_board : a string representaiton of the generated board which is readable for clingo.
		
	Returns:
		The output of clingo.
	"""

	#save current board to disk to load it later with clingo
	var tmpFilePath = "user://board.lp"
	save_data_to_user_dir(tmpFilePath, _board)
	#copy the solveBoard file and clingo to disk 
	var dir = Directory.new()
	dir.copy("res://clingoEncoding/solveBoard.lp", "user://solveBoard.lp")
	#get the path to the files for clingo 
	print(OS.get_user_data_dir())
	var filePath = OS.get_user_data_dir() + "/board.lp"
	var solveFilePath = OS.get_user_data_dir() + "/solveBoard.lp"
	var clingoPath = ""
	if(OS.get_name() == "X11"):
		clingoPath = "./lin/clingo"
	elif(OS.get_name() == "Win"):
		clingoPath = "./win/clingo.exe"
	elif(OS.get_name() == "OSX"):
		clingoPath = "./osx/clingo"
		
	var out = []
	OS.execute(clingoPath, [solveFilePath, filePath, "-t " + str(OS.get_processor_count())], true, out, true)

	return out

func getOptimalMovesFromCingoOutput(_clingoOut : String) -> Array:
	"""
	Reads the output of clingo and sets the board to the dimensions to allow the optimal solution.
	
	Args:
		_clingoOut : the output of clingo which should be parsed.
		
	Returns:
		An array of all moves which are the optimal plan.
		Each array element has the form: [targetBlock, destinationBlock, timestep]
	"""

	#Parse clingos output
	# remove all none move related lines
	var ex = RegEx.new()
	ex.compile("move\\((?<block>\\d+).(?<destination>\\d+).(?<time>\\d+)\\)")
	var res = ex.search_all(_clingoOut)
	for i in res:
		var length = int(i.get_string())
		optimalMoves.append([i.get_string("block"), i.get_string("destination"), i.get_string("time")])
		
	return optimalMoves

func getBoardHeight(_clingoOut : String) -> int:
	"""
	Gets the needed board height to execute the optimal plan.
	
	Args:
		_clingoOut : the output of clingo from which the needed height should be calculated.
		
	Returns:	
		The needed Height.
	"""
	
	#Parse clingos output
	# remove all none heigth related lines
	var height : int = 0
	
	var ex = RegEx.new()
	ex.compile("height\\((?<block>\\d+).(?<height>\\d+).(?<time>\\d+)\\)")
	var res = ex.search_all(_clingoOut)
	for i in res:
		if(int(i.get_string("height")) > height):
			height = int(i.get_string("height"))
		#print(i.get_string("height"))
		
	return height

func getBoardLength(_clingoOut : String) -> int:
	"""
	Gets the needed board length to execute the optimal plan.
	
	Args:
		_clingoOut : the output of clingo from which the needed length should be calculated.
		
	Returns:	
		The needed board length.
	"""
	
	#Parse clingos output
	# remove all none heigth related lines
	var length : int = 0
	
	var ex = RegEx.new()
	ex.compile("blocksOnGround\\((?<length>\\d+).(\\d+)\\)")
	var res = ex.search_all(_clingoOut)
	for i in res:
		if(int(i.get_string("length")) > length):
			length = int(i.get_string("length"))
		#print(i.get_string("length"))
		
	return length

func resizeBoardForOptimalPlan():
	"""
	resize the startBoard to the size needed for the optimal plan
	"""
	
	#resize height
	if(self.maxHeight > self.board[0].size()):
		var differenceY = self.maxHeight - self.board.size()
		for x in range(self.maxHeight):
			for i in range(differenceY):
				self.board[x].append(0)
				self.goalBoard[x].append(0)
			
	#resize length
	if(self.boardLength > self.startBoard.size()):
		var differenceY = self.boardLength - self.board.size()
		for i in range(differenceY):
			self.board.append([])
			for new in range(self.board[0].size()):
				self.board[self.board.size()-1].append(0)
		
	for block in self.blocks:
		block.set("maxHeight", self.maxHeight)
		block.set("boardLengthX", self.boardLength)
		block.set("board", self.board)
	
func setGraphics():
	"""
	Sets the visuals for the generated board
	
	Scales the ground
	moves the camera to a position where the player can see the board
	"""
	#get the length of the ground (board length)
	var gnd = get_node("ground")
	gnd.scale = Vector3(self.boardLength / 2.0, gnd.scale.y, gnd.scale.z)
	gnd.global_translate(Vector3((self.boardLength / 2.0) - 0.5, 0, 0))

	#move camera
	var cam = get_viewport().get_camera()
	cam.look_at_from_position(Vector3(self.boardLength, self.maxHeight - 1, 10 + self.boardLength / 3), \
								Vector3(self.boardLength / 2, self.maxHeight / 2, 0), \
								Vector3.UP)

func save_data_to_user_dir(path, data):
	var f = File.new()
	f.open(path, File.WRITE)
	f.store_string(data)
	f.close()

