extends Control

func _enter_tree():
	if not OS.has_feature("web"):
		if not Websocket.booted:
			await Websocket.socket_ready
		BlinkPatternTriggerer.trigger("croccantini", "light_tower_red")
	
		
func _input(event):
	if Utils.is_action_just_released(event, "stand"):
		get_tree().change_scene_to_file("res://scenes/game/game.tscn")
	
	if Utils.is_action_just_released(event, "rules"):
		get_tree().change_scene_to_file("res://scenes/tutorial/tutorial.tscn")
