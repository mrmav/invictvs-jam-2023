extends Control

func _ready():
	CounterManager.limit_reached.connect(set_reason)
	$AnimationPlayer.animation_finished.connect(go_to_menu)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func set_reason(id):
	var text
	match id:
		"left_jab":
			text = "One left jab\ntoo many..."
		"left_hook":
			text = "12 left hooks\nwere the limit."
		"left_uppercut":
			text = "That left upper cut\nwas your last."
		"right_jab":
			text = "rIgHt_JaB == 13:\n  kiLl()"
		"right_hook":
			text = "13 right hooks \n 0 bodies left."
		"right_uppercut":
			text = ".13 upper cut\nright did You"
		"dodge_left":
			text = "Next time don't\ndodge to the left."
		"dodge_right":
			text = "Right... dodge...\nno... more..."
		"stand":
			text = "13 equals dead!"
		"guard":
			text = "You are not a turtle."
	$ScrollContainer/Label2.text = text
	$AnimationPlayer.play("new_animation")


func go_to_menu(_id):
	SceneLoader.goto_scene("res://scenes/intro/intro.tscn")
