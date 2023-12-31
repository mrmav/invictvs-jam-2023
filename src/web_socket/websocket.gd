extends Node

signal socket_ready

var booted = false

var socket : WebSocketPeer = WebSocketPeer.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	
	#load config
	var cfg = ConfigFile.new()
	var err = cfg.load("res://config.cfg")
	
	if err != OK:
		print("COULD NOT READ CONFIG FILE")
		
	var ip = cfg.get_value("socket", "ip")
	
	var error = socket.connect_to_url(ip)

	if error != OK:
		printerr("SOCKET COULD NOT CONNECT")
		set_process(false)
		return

	print("SOCKET CONNECTED")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	socket.poll()
	var state = socket.get_ready_state()
	if state == WebSocketPeer.STATE_OPEN:
		
		if not booted:
			emit_signal("socket_ready")
			print("SOCKET STATE OPEN")
			booted = true
		
		while socket.get_available_packet_count():

			# INPUT LOGIC:

			var input_obj = JSON.parse_string(socket.get_packet().get_string_from_utf8())
			#print("Packet: ", JSON.stringify(input_obj, "\t"))

			if input_obj.id == "service::hardware/inputs/status_change":
				var input_evt = InputEventAction.new()

				match input_obj.payload.data.name:
					"bet_2":
						input_evt.action = "left_jab"
					"play_8":
						input_evt.action = "left_hook"
					"play_18":
						input_evt.action = "left_upper_cut"
					"bet_6":
						input_evt.action = "right_jab"
					"play_88":
						input_evt.action = "right_hook"
					"play_68":
						input_evt.action = "right_upper_cut"
					"play_38":
						input_evt.action = "guard"
					"bet_1":
						input_evt.action = "dodge_left"
					"bet_10":
						input_evt.action = "dodge_right"
					"play":
						input_evt.action = "stand"
					"pay":
						input_evt.action = "menu"
					"help":
						input_evt.action = "rules"
					

				input_evt.pressed = input_obj.payload.data.input_state == "active"
				Input.parse_input_event(input_evt)

			# END INPUT LOGIC

	elif state == WebSocketPeer.STATE_CLOSING:
		# Keep polling to achieve proper close.
		pass
	elif state == WebSocketPeer.STATE_CLOSED:
		var code = socket.get_close_code()
		var reason = socket.get_close_reason()
		print("WebSocket closed with code: %d, reason %s. Clean: %s" % [code, reason, code != -1])
		set_process(false) # Stop processing.


func send(object : Variant):
	var json : String = JSON.stringify(object)
	var error = socket.send_text(json)
	if error != OK:
		print("ERROR SENDING SOCKET MESSAGE: " + str(error))
	
