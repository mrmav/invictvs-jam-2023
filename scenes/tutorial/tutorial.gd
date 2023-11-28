extends Control

func _input(event):
	if Utils.is_action_just_released(event, "menu"):
		get_tree().change_scene_to_file("res://scenes/intro/intro.tscn")
	
	if Utils.is_action_just_released(event, "stand"):
		get_tree().change_scene_to_file("res://scenes/game/game.tscn")
