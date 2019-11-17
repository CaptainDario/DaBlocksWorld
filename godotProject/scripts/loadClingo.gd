extends Control

# load the Simple library
onready var data = preload("res://bin/simple.gdns").new()


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Button_pressed():
	var text = "Data = " + data.get_data()
	$Label.text = text
	print("asdas", text)
