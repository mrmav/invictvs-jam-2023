extends Control

@onready var brand_label: Label = $ColorRect/VBoxContainer/Brand/CenterContainer/Label
@onready var play_label: Label = $ColorRect/VBoxContainer/Info/PlayLabelContainer/CenterContainer/Label

var visible_count: int = 0

func _on_timer_timeout():
	if play_label.visible and visible_count == 0:
		visible_count += 1
		return
	play_label.visible = not play_label.visible
	visible_count = 0
