extends Spatial



onready var block = preload("res://scenes/block.tscn")

#the block
var blocks = []

#the board length
var boardLength
#the maximum height
var maxHeight = 5
#the board as matrix
var board = []


func _ready():

	#get the length of the ground (board length)
	boardLength = get_node("ground").scale.x

	#initialize the board-matrix
	for x in range(boardLength * 2):
		board.append([])
		for y in range(maxHeight):
			board[x].append(0)


	#GET RANDOM BLOCKS AND COORDINATES



	#instantiate the random blocks
	for y in range(5):
		#instantiate the block 
		var block_inst = block.instance()
		block_inst.set("currentPosition", Vector3(0, y, 0))
		add_child(block_inst)
		block_inst.translate(Vector3(0, y * 2, 0))
		board[0][y] = y + 1

		#add the block to the list with all blocks
		blocks.append([y, block_inst])



func generatePuzzle():

	pass
