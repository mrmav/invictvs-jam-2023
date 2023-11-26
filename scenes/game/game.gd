extends Control

func _enter_tree():
	if not Websocket.booted:
		await Websocket.socket_ready
	BlinkPatternTriggerer.trigger("croccantini", "light_tower_green")
	
func _ready():
	$Theme.play()


func _input(event):
	if Utils.is_action_just_released(event, "menu"):
		SceneLoader.goto_scene("res://scenes/intro/intro.tscn")

func _exit_tree():
	$Theme.stop()
