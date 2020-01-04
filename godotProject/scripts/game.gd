extends Spatial



onready var block = preload("res://scenes/block.tscn")

#the block
var block_inst


func _ready():

	block_inst = block.instance()
	add_child(block_inst)

