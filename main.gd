extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(delta):
	pass


func _input(event):
	
	if event is InputEventAction:
		if event.is_pressed():
			$CanvasLayer/Control/Label.text = event.action + str(event.is_pressed())
	
