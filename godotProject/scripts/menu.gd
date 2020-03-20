extends Control

onready var aboutPopUp : PopupDialog = get_node("/root/Control/popup")

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


func _on_about_pressed():
	aboutPopUp.popup_centered()
