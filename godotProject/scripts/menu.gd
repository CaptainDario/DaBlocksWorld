extends Control

func _ready():
	pass

func _on_ButtonEasy_button_down():
	get_tree().change_scene("res://scenes/game.tscn")
	globals.difficulty = "easy"


func _on_ButtonCasual_button_down():
	get_tree().change_scene("res://scenes/game.tscn")
	globals.difficulty = "casual"


func _on_ButtonHard_button_down():
	get_tree().change_scene("res://scenes/game.tscn")
	globals.difficulty = "hard"


func _on_ButtonVeryHard_button_down():
	get_tree().change_scene("res://scenes/game.tscn")
	globals.difficulty = "very hard"


func _on_ButtonCasual_button_up():
	pass # Replace with function body.
