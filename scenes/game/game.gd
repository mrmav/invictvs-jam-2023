extends Control

@onready var health_progress: TextureProgressBar = $Game/ProgressBar

func _ready():
	$Theme.play()
	Store.rival_health_updated.connect(on_rival_health_updated)

func _enter_tree():
	if not Websocket.booted:
		await Websocket.socket_ready
	BlinkPatternTriggerer.trigger("croccantini", "light_tower_green")
	if Store.rival_health_updated.is_connected(on_rival_health_updated):
		Store.rival_health_updated.disconnect(on_rival_health_updated)

func _input(event):
	if Utils.is_action_just_released(event, "menu"):
		SceneLoader.goto_scene("res://scenes/intro/intro.tscn")

func _exit_tree():
	$Theme.stop()

func on_rival_health_updated(health: int) -> void:
	print(health)
	var health_v = int(float(health) / float(Store.max_health_rival + 30) * 100)
	health_progress.value = health_v
