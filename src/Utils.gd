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


class Colors:
	
	static var DARK_BLUE_1 : Color = Color8(01, 36, 62)
	static var DARK_BLUE_2 : Color = Color8(09, 39, 79)
	static var BLUE_1 : Color = Color8(19, 42, 94)
	static var BLUE_2 : Color = Color8(34, 46, 108)
	static var DARK_PURPLE_1 : Color = Color8(52, 49, 117)
	static var DARK_PURPLE_2 : Color = Color8(76, 52, 121)
	static var PURPLE_1 : Color = Color8(101, 57, 122)
	static var PURPLE_2 : Color = Color8(129, 62, 118)
	static var PINK_1 : Color = Color8(158, 69, 111)
	static var PINK_2 : Color = Color8(186, 78, 105)
	static var RED_1 : Color = Color8(211, 90, 96)
	static var RED_2 : Color = Color8(233, 104, 88)
	static var ORANGE_1 : Color = Color8(248, 123, 82)
	static var ORANGE_2 : Color = Color8(255, 144, 81)
	static var YELLOW_1: Color = Color(255, 170, 83)
	static var YELLOW_2: Color = Color(255, 199, 92)
	
