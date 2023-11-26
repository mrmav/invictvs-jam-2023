extends Control

func _enter_tree():
	if not Websocket.booted:
		await Websocket.socket_ready
	BlinkPatternTriggerer.trigger("croccantini", "light_tower_red")
	
	
func _ready():
	$Theme.play()


func _input(event):
	if Utils.is_action_just_released(event, "stand"):
		SceneLoader.goto_scene("res://scenes/game/game.tscn")
	
	if Utils.is_action_just_released(event, "rules"):
		SceneLoader.goto_scene("res://scenes/tutorial/tutorial.tscn")


func _exit_tree():
	$Theme.stop()
	
