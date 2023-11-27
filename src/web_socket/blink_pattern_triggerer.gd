extends RefCounted
class_name BlinkPatternTriggerer

static func get_data(group : String, id : String):
	return {
		id = "v1/hardware/outputs/start_blink_pattern",
		payload = {
			group = group,
			id = id
		}
	}

static func trigger(group : String, id : String):
	if Store.QUIXANT_SUPPORTED:
		Websocket.send(get_data(group, id))
