extends Resource
class_name SocketServiceMessage

var id : String = ""
var payload : Variant = null

func get_data():
	return {
		id = id,
		payload = payload
	}
