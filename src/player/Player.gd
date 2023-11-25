extends Node3D

const STUN_RECOVER_TIME = 2
const DODGE_TIME = 1

@onready var _state_chart = $StateChart

@onready var _stand_up_counter = $"Stand Up Counter"

@onready var _left_hand = $"Left Placeholder"
@onready var _right_hand = $"Right Placeholder"

@onready var _animation_sprites = $AnimatedSprite3D
@onready var _animation_player : AnimationPlayer = get_node("AnimationPlayer")
@onready var right_hand_idle_state: AtomicState = $"StateChart/Root/Combat/Right Hand/Idle"
@onready var right_hand_jab_state: AtomicState = $"StateChart/Root/Combat/Right Hand/Jab"
@onready var right_hand_preparing_hook: AtomicState = $"StateChart/Root/Combat/Right Hand/Preparing Hook"
@onready var right_hand_hook: AtomicState = $"StateChart/Root/Combat/Right Hand/Hook"
@onready var right_hand_preparing_uppercut: AtomicState = $"StateChart/Root/Combat/Right Hand/Preparing Uppercut"
@onready var right_hand_uppercut: AtomicState = $"StateChart/Root/Combat/Right Hand/Uppercut"
@onready var left_hand_idle_state: AtomicState = $"StateChart/Root/Combat/Left Hand/Idle"
@onready var left_hand_jab_state: AtomicState = $"StateChart/Root/Combat/Left Hand/Jab"
@onready var left_hand_preparing_hook: AtomicState = $"StateChart/Root/Combat/Left Hand/Preparing Hook"
@onready var left_hand_hook: AtomicState = $"StateChart/Root/Combat/Left Hand/Hook"
@onready var left_hand_preparing_uppercut: AtomicState = $"StateChart/Root/Combat/Left Hand/Preparing Uppercut"
@onready var left_hand_uppercut: AtomicState = $"StateChart/Root/Combat/Left Hand/Uppercut"
@onready var dodging_left: AtomicState = $"StateChart/Root/Dodging Left"
@onready var dodging_right: AtomicState = $"StateChart/Root/Dodging Right"
@onready var guard: AtomicState = $StateChart/Root/Guard
@onready var stunned: AtomicState = $StateChart/Root/Stunned
@onready var knockout: AtomicState = $StateChart/Root/Knockout

signal attacking(attack: Enumerators.Attacks)
	
var gameplay_arena


func _ready():
	Store.player_node = self
	CounterManager.limit_reached.connect(_lose)
	right_hand_idle_state.state_entered.connect(_on_idle_state_entered.bind(true))
	right_hand_jab_state.state_entered.connect(_on_jab_state_entered.bind(true))
	right_hand_preparing_hook.state_entered.connect(_on_preparing_hook_state_entered.bind(true))
	right_hand_hook.state_entered.connect(_on_hook_state_entered.bind(true))
	right_hand_preparing_uppercut.state_entered.connect(_on_preparing_uppercut_state_entered.bind(true))
	right_hand_uppercut.state_entered.connect(_on_uppercut_state_entered.bind(true))
	left_hand_idle_state.state_entered.connect(_on_idle_state_entered.bind(false))
	left_hand_jab_state.state_entered.connect(_on_jab_state_entered.bind(false))
	left_hand_preparing_hook.state_entered.connect(_on_preparing_hook_state_entered.bind(false))
	left_hand_hook.state_entered.connect(_on_hook_state_entered.bind(false))
	left_hand_preparing_uppercut.state_entered.connect(_on_preparing_uppercut_state_entered.bind(false))
	left_hand_uppercut.state_entered.connect(_on_uppercut_state_entered.bind(false))
	dodging_left.state_entered.connect(_on_dodging_left_state_entered)
	dodging_right.state_entered.connect(_on_dodging_right_state_entered)
	guard.state_entered.connect(_on_guard_state_entered)
	guard.state_processing.connect(_on_guard_state_processing)
	stunned.state_entered.connect(_on_stunned_state_entered)
	stunned.state_exited.connect(_on_stunned_state_exited)
	knockout.state_entered.connect(_on_knockout_state_entered)
	knockout.state_input.connect(_on_knockout_state_input)


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



#----------------------------------------
# Knockdown
#----------------------------------------
var _knockout_timer

func _on_knockout_state_entered():
	CounterManager.reset("stand")
	if _knockout_timer == null:
		_knockout_timer = Timer.new()
		add_child(_knockout_timer)
		_knockout_timer.wait_time = 3
		_knockout_timer.timeout.connect(_on_knockdown_timeout)
	_knockout_timer.start()
	_stand_up_counter.visible = true

func _on_knockout_state_input(event):
	if Utils.is_action_just_released(event, "stand"):
		CounterManager.increase("stand")

func _on_knockdown_timeout():
	if CounterManager._counters.stand == 12:
		_state_chart.send_event("recover")
	elif CounterManager._counters.stand < 12:
		CounterManager.increase("stand", 13 - CounterManager._counters.stand)

