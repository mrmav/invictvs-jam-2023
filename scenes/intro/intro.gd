extends Control

func _input(event):
	if Utils.is_action_just_released(event, "stand"):
		SceneLoader.goto_scene("res://scenes/game/game.tscn")
	
	if Utils.is_action_just_released(event, "rules"):
		SceneLoader.goto_scene("res://scenes/tutorial/tutorial.tscn")
