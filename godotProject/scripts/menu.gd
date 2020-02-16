extends Control

func _ready():
	pass

func _on_ButtonEasy_button_down():
	get_tree().change_scene("res://scenes/game.tscn")
