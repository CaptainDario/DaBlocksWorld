extends Spatial



onready var block = preload("res://scenes/block.tscn")

#the block
var s


func _ready():

	s = block.instance()
	add_child(s)


func _process(delta):
	position += Vector2(0, 1)