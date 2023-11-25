extends Node
class_name Utils

static func is_action_just_pressed(event, action):
	if Input.is_action_just_pressed(action):
		return true
	elif event is InputEventAction and event.is_pressed() and event.action == action:
		return true
	else:
		return false


static func is_action_just_released(event, action):
	if Input.is_action_just_released(action):
		return true
	elif event is InputEventAction and not event.is_pressed() and event.action == action:
		return true
	else:
		return false
