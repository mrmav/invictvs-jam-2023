extends Node3D

@onready var state_chart: StateChart = $StateChart
@onready var down_timer: Timer = $DownTimer

var is_lower_blocking: bool = false
var is_upper_blocking: bool = false
var last_blows_buffer: Array[Enumerators.Attacks] = []
var prioritize_upper_defense: bool = false
var prioritize_lower_defense: bool = false

func _physics_process(delta):
	if last_blows_buffer.size() >= 4:
		var upper_attacks: int = 0
		var lower_attacks: int = 0
		while(last_blows_buffer.size() > 4):
			last_blows_buffer.pop_front()
		for blow in last_blows_buffer:
			if blow == Enumerators.Attacks.LEFT_HOOK:
				lower_attacks += 1
			else:
				upper_attacks += 1
		prioritize_upper_defense = lower_attacks >= 3
		prioritize_upper_defense = lower_attacks >= 3
	if is_lower_blocking or is_upper_blocking:
		pass
		

func _on_knocked_tree_state_state_entered():
	print("pumba")
	await get_tree().create_timer(3).timeout
	print("coisa")
	

func _ready() -> void:
	down_timer.timeout.connect(on_down_timer_timeout)
	match(Store.dificulty):
		1:
			down_timer.wait_time = 3
			
	if Store.player_node == null:
		Store.player_node_defined.connect(on_player_node_defined)
	else:
		on_player_node_defined()
	Store.rival_health_updated.connect(on_rival_health_updated)

func _exit_tree():
	if 	Store.player_node_defined.is_connected(on_player_node_defined):
		Store.player_node_defined.disconnect(on_player_node_defined)
	Store.rival_health_updated.disconnect(on_rival_health_updated)

func on_player_node_defined() -> void:
	Store.player_node_defined.disconnect(on_player_node_defined)
	Store.player_node.attacking.connect(on_player_attacking)
	
func on_player_attacking(attack: Enumerators.Attacks) -> void:
	match(attack):
		Enumerators.Attacks.LEFT_JAB, Enumerators.Attacks.RIGHT_JAB:
			if not is_upper_blocking:
				state_chart.send_event("hurt_by_jab")
				last_blows_buffer.append(Enumerators.Attacks.LEFT_JAB)
				Store.rival_health -= 5
		Enumerators.Attacks.LEFT_HOOK, Enumerators.Attacks.RIGHT_HOOK:
			if not is_upper_blocking:
				state_chart.send_event("hurt_by_hook")
				last_blows_buffer.append(Enumerators.Attacks.LEFT_HOOK)
				Store.rival_health -= 10
		Enumerators.Attacks.LEFT_UPPERCUT, Enumerators.Attacks.RIGHT_UPPERCUT:
			if not is_lower_blocking:
				state_chart.send_event("hurt_by_uppercut")
				last_blows_buffer.append(Enumerators.Attacks.LEFT_UPPERCUT)
				Store.rival_health -= 10


func on_rival_health_updated(value: int) -> void:
	if value <= 0:
		state_chart.send_event("down")
		down_timer.start()


func _on_upper_block_tree_state_state_entered():
	is_upper_blocking = true


func _on_upper_block_tree_state_state_exited():
	is_upper_blocking = false


func _on_lower_block_tree_state_state_entered():
	is_lower_blocking = true


func _on_lower_block_tree_state_state_exited():
	is_lower_blocking = false

func on_down_timer_timeout() -> void:
	if Store.perfect_down_sequence:
		state_chart.send_event("knocked")
	else:
		var random_number = randi_range(0, 1)
		if random_number == 1:
			state_chart.send_event("revive_lower_block")
		else:
			state_chart.send_event("revive_upper_block")
		match(Store.dificulty):
			1:
				Store.rival_health = 25
