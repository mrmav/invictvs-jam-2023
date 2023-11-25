extends Node

var blinks = null
var led_patterns = null

func _ready():
	
	Websocket.connect("socket_ready", Callable(self, "_on_socket_connection"))
	
	blinks = preload("res://src/web_socket/blink_patterns.gd").new()
	led_patterns = preload("res://src/web_socket/led_strip_patterns.gd").new()
	

func _on_socket_connection():
	
	# ensure hardwae reset
	var service_remove = SocketServiceMessage.new()
	service_remove.id = "v1/core/settings/remove_capability"
	service_remove.payload = "hardware"
	Websocket.send(service_remove.get_data())
	
	var service_add = SocketServiceMessage.new()
	service_add.id = "v1/core/settings/add_capability"
	service_add.payload = "hardware"
	Websocket.send(service_add.get_data())
	
	Websocket.send(blinks.get_data())
	Websocket.send(led_patterns.get_data())
	
	BlinkPatternTriggerer.trigger("croccantini", "menu_pattern")
	LEDPatternTriggerer.trigger("crocc_rcv_dmg")
	
	await get_tree().create_timer(1).timeout
	
	LEDPatternTriggerer.trigger("crocc_blk")
