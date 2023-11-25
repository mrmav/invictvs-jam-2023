extends RefCounted
class_name LEDPatternTriggerer

static func get_data(pattern : String):
	return {
		id = "v1/hardware/led_strips/set_pattern",
		payload = pattern
	}

static func trigger(pattern : String):
	Websocket.send(get_data(pattern))
