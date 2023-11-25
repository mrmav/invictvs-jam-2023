extends Node3D

const STUN_RECOVER_TIME = 2
const DODGE_TIME = 1

@onready var _state_chart = $StateChart

@onready var _left_hand = $"Left Placeholder"
@onready var _right_hand = $"Right Placeholder"

@onready var _animation_sprites = $AnimatedSprite3D
@onready var _animation_player : AnimationPlayer = get_node("AnimationPlayer")

signal attacking(attack: Enumerators.Attacks)
	
var gameplay_arena


func _ready():
	Store.player_node = self
	CounterManager.limit_reached.connect(_lose)
	

func _input(event):
	# LEFT HAND CONTROLS
	if Utils.is_action_just_released(event, "left_jab"):
		_state_chart.send_event("left_jab")
		
	if Utils.is_action_just_pressed(event, "left_hook"):
		_state_chart.send_event("left_prepare_hook")
	
	if Utils.is_action_just_released(event, "left_hook"):
		_state_chart.send_event("left_hook")
		
	if Utils.is_action_just_pressed(event, "left_upper_cut"):
		_state_chart.send_event("left_prepare_uppercut")
		
	if Utils.is_action_just_released(event, "left_upper_cut"):
		_state_chart.send_event("left_uppercut")
		
	if Utils.is_action_just_released(event, "dodge_left"):
		_state_chart.send_event("dodge_left")

	# RIGHT HAND CONTROLS
	if Utils.is_action_just_released(event, "right_jab"):
		_state_chart.send_event("right_jab")
		
	if Utils.is_action_just_pressed(event, "right_hook"):
		_state_chart.send_event("right_prepare_hook")
	
	if Utils.is_action_just_released(event, "right_hook"):
		_state_chart.send_event("right_hook")
		
	if Utils.is_action_just_pressed(event, "right_upper_cut"):
		_state_chart.send_event("right_prepare_uppercut")
		
	if Utils.is_action_just_released(event, "right_upper_cut"):
		_state_chart.send_event("right_uppercut")
		
	if Utils.is_action_just_released(event, "dodge_right"):
		_state_chart.send_event("dodge_right")

	
func light_hit():
	_state_chart.send_event("stun")

func strong_hit():
	_state_chart.send_event("knockout")

func _lose(id:String):
	_state_chart.send_event("lose")
	print(id)

#----------------------------------------
# Combat (Hands)
#----------------------------------------
func _get_hand(is_right_hand):
	return _right_hand if is_right_hand else _left_hand


func _prefix(event, is_right_hand):
	var _prefix = "right_" if is_right_hand else "left_"
	return _prefix + event

func _sufix(event, is_right_hand):
	var _sufix = "_right" if is_right_hand else "_left"
	return event + _sufix

func _attack_finished(is_right_hand):
	_state_chart.send_event(_prefix("attack_finished", is_right_hand))


func _on_idle_state_entered(is_right_hand):
	var hand = _get_hand(is_right_hand)


func _on_jab_state_entered(is_right_hand):
	attacking.emit(Enumerators.Attacks.RIGHT_JAB if is_right_hand else Enumerators.Attacks.LEFT_JAB)
	var hand = _get_hand(is_right_hand)
	CounterManager.increase(_prefix("jab", is_right_hand))
	
	# To susbstitute by animation
	_animation_sprites.play("jab_right")
	_animation_player.play("jab")
	LEDPatternTriggerer.trigger("crocc_giv_dmg")
	
	_attack_finished(is_right_hand)


func _on_preparing_hook_state_entered(is_right_hand):
	var hand = _get_hand(is_right_hand)


func _on_hook_state_entered(is_right_hand):
	attacking.emit(Enumerators.Attacks.RIGHT_HOOK if is_right_hand else Enumerators.Attacks.LEFT_HOOK)
	var hand = _get_hand(is_right_hand)
	CounterManager.increase(_prefix("hook", is_right_hand))
	
	# To susbstitute by animation
	await get_tree().create_timer(0.4).timeout
	
	_attack_finished(is_right_hand)


func _on_preparing_uppercut_state_entered(is_right_hand):
	var hand = _get_hand(is_right_hand)


func _on_uppercut_state_entered(is_right_hand):
	attacking.emit(Enumerators.Attacks.RIGHT_UPPERCUT if is_right_hand else Enumerators.Attacks.LEFT_UPPERCUT)
	var hand = _get_hand(is_right_hand)
	CounterManager.increase(_prefix("uppercut", is_right_hand))
	
	# To susbstitute by animation
	await get_tree().create_timer(0.5).timeout
	
	_attack_finished(is_right_hand)


#----------------------------------------
# Dodge
#----------------------------------------

var dodge_timer = null
func _on_dodging_left_state_entered():
	CounterManager.increase("dodge_left")
	if dodge_timer == null:
		dodge_timer = Timer.new()
		add_child(dodge_timer)
		dodge_timer.wait_time = DODGE_TIME
		dodge_timer.timeout.connect(_on_dodge_timeout)
	dodge_timer.start()
	gameplay_arena.rotate_arena(true)


func _on_dodging_right_state_entered():
	CounterManager.increase("dodge_right")
	if dodge_timer == null:
		dodge_timer = Timer.new()
		add_child(dodge_timer)
		dodge_timer.wait_time = DODGE_TIME
		dodge_timer.timeout.connect(_on_dodge_timeout)
	dodge_timer.start()
	gameplay_arena.rotate_arena(false)
	
func _on_dodge_timeout():
	_state_chart.send_event("recover")

#----------------------------------------
# Stun
#----------------------------------------

var _stun_timer = null
func _on_stunned_state_entered():
	if _stun_timer == null:
		_stun_timer = Timer.new()
		add_child(_stun_timer)
		_stun_timer.wait_time = STUN_RECOVER_TIME
		_stun_timer.timeout.connect(_on_stunned_timeout)
	_stun_timer.start()


func _on_stunned_state_exited():
	_stun_timer.stop()
	
	
func _on_stunned_timeout():
	_state_chart.send_event("recover")

#----------------------------------------
# Guard
#----------------------------------------

func _on_guard_state_entered():
	pass


func _on_guard_state_processing(delta):
	CounterManager.increase("guard", delta)
