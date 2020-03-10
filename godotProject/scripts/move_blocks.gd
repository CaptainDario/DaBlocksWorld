extends RigidBody

var whiteBlockMaterial = preload("res://materials/blockWhite.tres")
var blackBlockMaterial = preload("res://materials/blockBlack.tres")

#is the player currently dragging a cube
var isDragging = false
#the root object of this scene
var GM
#mouse offset to cube grid
var z = 0
#the scenes camera
var camera
#the board matrix from the tree root
var board
var goalBoard
#all other blocks
var blocks
#the length of the board
var boardLengthX
#maximum height of the board
var maxHeight
#the last position of this block
var lastPosition : Vector3
#the current position of this block
var currentPosition : Vector3
#the block number (the number which is written infront of it)
var number
#if the block is on the correct place
var correctPosition : bool = false



func _ready():
	camera = get_viewport().get_camera()
	
	GM = get_node("/root/GM")
	board = GM.get("board")
	goalBoard = GM.get("goalBoard")
	blocks = GM.get("blocks")
	boardLengthX = GM.get("boardLength")
	maxHeight = GM.get("maxHeight")

func _input_event(camera, event, click_position, click_normal, shape_idx):
	#get the position if the cube was clicked
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.pressed:
				#only move the cube if there is no block above it 
				#and it is not already on the orrect position
				if(board[currentPosition.x][currentPosition.y + 1] == 0):
					#print(click_position)
					isDragging = true

func _input(event):
	#when the left button is released, drop the cube
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if !event.pressed:
				#print("released")
				if(isDragging):
					applyGravity()
					checkPosIsValid()
					setMoveCounter()
					isDragging = false
					lastPosition = currentPosition

func _physics_process(delta):

	#move the cube when it was clicked and the button is stille being pressed
	if(isDragging):
		# get the mouse movement on a plane
		var position2D = get_viewport().get_mouse_position()
		var dropPlane  = Plane(Vector3(0, 0, 10), z)
		var position3D = dropPlane.intersects_ray(camera.project_ray_origin(position2D),camera.project_ray_normal(position2D))
		
		#make sure the cursor is still on the screen
		if(position3D != null):
			#round the calculated coordinates to move the cube on a grid
			var x = round(position3D.x)
			var y = round(position3D.y)
			var z = 0
			
			#check that the new position is not out of the bounds
			if(not(-1 < y and y < maxHeight)):
				y = currentPosition[1]
			if(not (-1 < x and x < boardLengthX)):
				x = currentPosition[0]
			position3D = Vector3(x, y, z)
				
			#only move if the new position is not the same as before
			#and on the new position is no block
			if(position3D != self.translation and
				board[position3D.x][position3D.y] == 0):

				moveBlock(position3D)



func moveBlock(newPos : Vector3):
	"""
	Moves this block to the coordinates specified

	Args:
		newPos - the position where this block should be moved to
	"""

	#set the new value in the board matrix (and remove old)
	var tmpVal = board[self.currentPosition.x][self.currentPosition.y]
	board[self.currentPosition.x][self.currentPosition.y] = 0
	board[newPos.x][newPos.y] = tmpVal

	#set the cube to the (rounded) mouse position
	var t = get_transform()
	t.origin = newPos
	set_transform(t)

	currentPosition = newPos

func applyGravity():
	"""
	Apply gravity to this block.
	"""
	var moved = true

	while moved:
		moved = false
		#if directly below this block there is no other block
		if(board[currentPosition.x][currentPosition.y - 1] == 0
			and currentPosition.y > 0):
			#move the block down one field
			moveBlock(currentPosition - Vector3(0, 1, 0))
			moved = true

func setNumber(_nr : int):
	"""
	Set the number of this block.
	And update the text infront to show the number to the player.
	"""

	self.number = _nr
	self.get_node("frontNr/Viewport/GUI/Panel/Label").text = str(_nr)

func setMoveCounter():
	"""
	Set the move counter at the top of the display
	"""

	if(currentPosition != lastPosition):
		get_node("/root/GM").moves += 1
		get_node("/root/GM/Control/LabelMoves").text = str(get_node("/root/GM").moves)

func checkPosIsValid():
	"""
	Checks if curren position is the position where the block should be placed.
	Changes the color of this block accordingly.
	"""

	#print(currentPosition)
	if(goalBoard[self.currentPosition.x][self.currentPosition.y] == self.number):
		#set the color for the right position
		self.get_node("OuterCube").set_material_override(whiteBlockMaterial)
		self.get_node("InnerCube").set_material_override(blackBlockMaterial)
		
		self.correctPosition = true
		print("valid place for ", str(self.number))
		#check if all blocks are on the correct position
		if(checkAllPosIsValid()):
			print("finished")
	elif(goalBoard[self.currentPosition.x][self.currentPosition.y] != self.number and self.correctPosition):
		self.get_node("OuterCube").set_material_override(blackBlockMaterial)
		self.get_node("InnerCube").set_material_override(whiteBlockMaterial)
		self.correctPosition = false

func checkAllPosIsValid() -> bool:
	"""
	Check if every block is on the correct position.
	"""

	#are all blocks on a valid position
	var allValid : bool = true
	for b in self.blocks:
		if(!b.correctPosition):
			allValid = false
			break

	return allValid
