extends Control

@onready var health_progress: TextureProgressBar = $Game/ProgressBar

func _ready():
	Store.rival_health_updated.connect(on_rival_health_updated)

func _enter_tree():
	if not OS.has_feature("web"):
		if not Websocket.booted:
			await Websocket.socket_ready
		BlinkPatternTriggerer.trigger("croccantini", "light_tower_green")
	
	if Store.rival_health_updated.is_connected(on_rival_health_updated):
		Store.rival_health_updated.disconnect(on_rival_health_updated)

func _input(event):
	if Utils.is_action_just_released(event, "menu"):
		get_tree().change_scene_to_file("res://scenes/intro/intro.tscn")

func on_rival_health_updated(health: int) -> void:
	var health_v = int(float(health) / float(Store.max_health_rival + 30) * 100)
	health_progress.value = health_v
