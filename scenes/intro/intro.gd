extends Control

func _input(event):
	if event.is_action_pressed("play"):
		SceneLoader.goto_scene("res://scenes/game/game.tscn")
