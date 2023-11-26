extends Node3D

@onready var reaction_timer: Timer

@onready var state_chart: StateChart = $StateChart
@onready var down_timer: Timer = $DownTimer
@onready var idle_tree_state: AnimationTreeState = $StateChart/CompoundState/IdleTreeState

var is_lower_blocking: bool = false
var is_upper_blocking: bool = false
var last_blows_buffer: Array[Enumerators.Attacks] = []
var prioritize_upper_defense: bool = false
var prioritize_lower_defense: bool = false
var player_is_preparing_uppercut: bool = false
var player_is_preparing_hook: bool = false

@onready var tree = $AnimationTree
@onready var state_machine = tree.get("parameters/playback")

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
	await get_tree().create_timer(3).timeout
	

func _ready() -> void:
	Store.rival_node = self
	Store.rival_health = Store.max_health_rival
	Store.surpassed_down_sequence.connect(on_surpassed_down_sequence)
	idle_tree_state.state_entered.connect(_on_idle_tree_state_state_entered)
	idle_tree_state.state_processing.connect(_on_idle_tree_state_state_process)
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
	if Store.player_node_defined.is_connected(on_player_node_defined):
		Store.player_node_defined.disconnect(on_player_node_defined)
	Store.rival_health_updated.disconnect(on_rival_health_updated)
	if Store.player_node.attacking.is_connected(on_player_attacking):
		Store.player_node.attacking.disconnect(on_player_attacking)
	if idle_tree_state.state_processing.is_connected(_on_idle_tree_state_state_process):
		idle_tree_state.state_processing.disconnect(_on_idle_tree_state_state_process)


func on_player_node_defined() -> void:
	if Store.player_node_defined.is_connected(on_player_node_defined):
		Store.player_node_defined.disconnect(on_player_node_defined)
	Store.player_node.attacking.connect(on_player_attacking)
	Store.player_node.preparing_uppercut.connect(on_player_prepare_uppercut)
	Store.player_node.preparing_hook.connect(on_player_prepare_hook)
	
func on_player_attacking(attack: Enumerators.Attacks) -> void:
	player_is_preparing_uppercut = false
	player_is_preparing_hook = false
	match(attack):
		Enumerators.Attacks.LEFT_JAB, Enumerators.Attacks.RIGHT_JAB:
			if not is_upper_blocking:
				state_chart.send_event("hurt_jab")
				last_blows_buffer.append(Enumerators.Attacks.LEFT_JAB)
				Store.rival_health -= 5
		Enumerators.Attacks.LEFT_HOOK, Enumerators.Attacks.RIGHT_HOOK:
			if not is_upper_blocking:
				state_chart.send_event("hurt_hook")
				last_blows_buffer.append(Enumerators.Attacks.LEFT_HOOK)
				Store.rival_health -= 10
		Enumerators.Attacks.LEFT_UPPERCUT, Enumerators.Attacks.RIGHT_UPPERCUT:
			if not is_lower_blocking:
				state_chart.send_event("hurt_uppercut")
				last_blows_buffer.append(Enumerators.Attacks.LEFT_UPPERCUT)
				Store.rival_health -= 10


func on_player_prepare_uppercut():
	player_is_preparing_uppercut = true

func on_player_prepare_hook():
	player_is_preparing_hook = true


func on_rival_health_updated(value: int) -> void:
	if value <= 0:
		Store.start_down_sequence = true
		state_chart.send_event("down")
		down_timer.start()
		$"../../../Match Controller".on_knockout()
		



func _on_upper_block_tree_state_state_entered():
	is_upper_blocking = true


func _on_upper_block_tree_state_state_exited():
	is_upper_blocking = false


func _on_lower_block_tree_state_state_entered():
	is_lower_blocking = true


func _on_lower_block_tree_state_state_exited():
	is_lower_blocking = false

func on_down_timer_timeout() -> void:
	state_chart.send_event("knocked")
	await get_tree().create_timer(1).timeout
	# TODO do an interface like stand up
	CounterManager.limit_reached.emit("win")
	
	
	return
	if Store.perfect_down_sequence:
		state_chart.send_event("knocked")
	else:
		_failed_down_sequence()
		
func _failed_down_sequence() -> void:
	state_chart.send_event("idle")
	match(Store.dificulty):
		1:
			Store.rival_health = 25
			
func on_surpassed_down_sequence() -> void:
	down_timer.stop()
	_failed_down_sequence()

func on_right_hook_charged() -> void:
	state_chart.send_event("right_hook")
	
func on_left_hook_charged() -> void:
	state_chart.send_event("left_hook")

func on_right_jab_charged() -> void:
	state_chart.send_event("right_jab")

func on_left_jab_charged() -> void:
	state_chart.send_event("left_jab")
	
func on_right_uppercut_charged() -> void:
	state_chart.send_event("right_uppercut")

func on_left_uppercut_charged() -> void:
	state_chart.send_event("left_uppercut")

func on_upper_block_hit() -> void:
	if is_upper_blocking:
		state_chart.send_event("upper_block")
	else:
		state_chart.send_event("idle")
	
func on_lower_block_hit() -> void:
	if is_lower_blocking:
		state_chart.send_event("lower_block")
	else:
		state_chart.send_event("idle")

func on_hit() -> void:
	state_chart.send_event("idle")
	LEDPatternTriggerer.trigger("crocc_giv_dmg")

func on_right_hook() -> void:
	state_chart.send_event("idle")
	Store.player_node.strong_hit()

func on_left_hook() -> void:
	state_chart.send_event("idle")
	Store.player_node.strong_hit()
	

func on_right_jab() -> void:
	state_chart.send_event("idle")
	Store.player_node.strong_hit()
	

func on_left_jab() -> void:
	state_chart.send_event("idle")
	Store.player_node.strong_hit()
	

func on_right_uppercut() -> void:
	state_chart.send_event("idle")
	Store.player_node.strong_hit()
	

func on_left_uppercut() -> void:
	state_chart.send_event("idle")
	Store.player_node.strong_hit()
	



# --------------------------------------
# Idle Reaction Timer
# --------------------------------------
var defense_time = 0.0
var attack_time = 0.0

const DEFENSE_TIME = 0.8
const ATTACK_TIME = 2.0
const VARIATION = 0.2

func _on_idle_tree_state_state_entered():
	defense_time = DEFENSE_TIME + randf_range(0.0, 0.2)
	attack_time = ATTACK_TIME + randf_range(0.0, 0.2)
	

func _on_idle_tree_state_state_process(delta):
	defense_time -= delta
	attack_time -= delta
	
	if defense_time <= 0.0:
		_on_idle_handle_defense()
		attack_time += VARIATION
	
	if attack_time <= 0.0:
		_on_idle_handle_attack()
		defense_time += VARIATION
	
	

func _on_idle_handle_defense():
	defense_time = DEFENSE_TIME + randf_range(0.0, 0.2)
	
	var rand = randi() % 100
	if player_is_preparing_hook and player_is_preparing_uppercut:
		if rand < 10:
			state_chart.send_event("lower_block")
		if rand < 20:
			state_chart.send_event("upper_block")
		elif rand < 60:
			state_chart.send_event("left_jab_charge")
		elif rand < 100:
			state_chart.send_event("right_jab_charge")
	elif player_is_preparing_hook:
		if rand < 100:
			state_chart.send_event("lower_block")
		elif rand < 80:
			state_chart.send_event("left_jab_charge")
		elif rand < 90:
			state_chart.send_event("right_jab_charge")
		else:
			return
	elif player_is_preparing_uppercut:
		if rand < 70:
			state_chart.send_event("upper_block")
		elif rand < 80:
			state_chart.send_event("left_jab_charge")
		elif rand < 90:
			state_chart.send_event("right_jab_charge")
		else:
			return
		

func _on_idle_handle_attack():
	attack_time = ATTACK_TIME + randf_range(0.0, 0.2)
	
	var rand = randi() % 100
	if rand < 5:
		state_chart.send_event("lower_block")
	if rand < 15:
		state_chart.send_event("upper_block")
	elif rand < 25:
		state_chart.send_event("left_jab_charge")
	elif rand < 35:
		state_chart.send_event("right_jab_charge")
	elif rand < 45:
		state_chart.send_event("left_hook_charge")
	elif rand < 55:
		state_chart.send_event("right_hook_charge")
	elif rand < 65:
		state_chart.send_event("left_uppercut_charge")
	elif rand < 75:
		state_chart.send_event("right_uppercut_charge")
	else:
		return

