extends Node3D

const STUN_RECOVER_TIME = 2
const DODGE_TIME = 1

@onready var _state_chart = $StateChart

@onready var _stand_up_counter = $"Stand Up Counter"

@onready var _left_hand = $"Left Placeholder"
@onready var _right_hand = $"Right Placeholder"

@onready var _animation_sprites_right = $RightAnimatedSprite3D
@onready var _animation_sprites_left = $LeftAnimatedSprite3D
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
signal hit_rival
signal gave_damage
signal received_damage
signal preparing_hook()
signal preparing_uppercut()
	
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
	guard.state_exited.connect(_on_guard_state_exited)
	stunned.state_entered.connect(_on_stunned_state_entered)
	stunned.state_exited.connect(_on_stunned_state_exited)
	knockout.state_entered.connect(_on_knockout_state_entered)
	knockout.state_input.connect(_on_knockout_state_input)


func _input(event):
	
	emit_signal("gave_damage")
	
	# LEFT HAND CONTROLS
	if Utils.is_action_just_pressed(event, "left_jab"):
		emit_signal("hit_rival")
		_state_chart.send_event("left_jab")
		
	if Utils.is_action_just_pressed(event, "left_hook"):
		_state_chart.send_event("left_prepare_hook")
	
	if Utils.is_action_just_released(event, "left_hook"):
		emit_signal("hit_rival")
		_state_chart.send_event("left_hook")
		
	if Utils.is_action_just_pressed(event, "left_upper_cut"):
		_state_chart.send_event("left_prepare_uppercut")
		
	if Utils.is_action_just_released(event, "left_upper_cut"):
		emit_signal("hit_rival")
		_state_chart.send_event("left_uppercut")
		
	if Utils.is_action_just_pressed(event, "dodge_left"):
		_state_chart.send_event("dodge_left")

	# RIGHT HAND CONTROLS
	if Utils.is_action_just_pressed(event, "right_jab"):
		emit_signal("hit_rival")
		_state_chart.send_event("right_jab")
		
	if Utils.is_action_just_pressed(event, "right_hook"):
		_state_chart.send_event("right_prepare_hook")
	
	if Utils.is_action_just_released(event, "right_hook"):
		emit_signal("hit_rival")
		_state_chart.send_event("right_hook")
		
	if Utils.is_action_just_pressed(event, "right_upper_cut"):
		_state_chart.send_event("right_prepare_uppercut")
		
	if Utils.is_action_just_released(event, "right_upper_cut"):
		emit_signal("hit_rival")
		_state_chart.send_event("right_uppercut")
		
	if Utils.is_action_just_pressed(event, "dodge_right"):
		_state_chart.send_event("dodge_right")
	
	if Utils.is_action_just_pressed(event, "guard"):
		_state_chart.send_event("enter_guard")
	
	if Utils.is_action_just_released(event, "guard"):
		_state_chart.send_event("recover")

	
func light_hit():
	_state_chart.send_event("stun")

func strong_hit():
	_state_chart.send_event("knockout")
	_animation_player.play("hurt")
	LEDPatternTriggerer.trigger("crocc_rcv_dmg")

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
	
	var sprites = _animation_sprites_right if is_right_hand else _animation_sprites_left
	sprites.play("idle")
	_animation_player.play("idle")
	

func _on_jab_state_entered(is_right_hand):
	attacking.emit(Enumerators.Attacks.RIGHT_JAB if is_right_hand else Enumerators.Attacks.LEFT_JAB)
	CounterManager.increase(_prefix("jab", is_right_hand))
	
	var sprites = _animation_sprites_right if is_right_hand else _animation_sprites_left
			
	# To susbstitute by animation
	sprites.play("jab_right")
	_animation_player.play("jab_" + ("right" if is_right_hand else "left"))
	#LEDPatternTriggerer.trigger("crocc_giv_dmg")
	
	await sprites.animation_finished
	
	_attack_finished(is_right_hand)


func _on_preparing_hook_state_entered(is_right_hand):
	var sprites = _animation_sprites_right if is_right_hand else _animation_sprites_left
	
	sprites.play("hook_anticipation")
	# if time: implement camera movement
	#_animation_player.play("upper_cut_anticipation")
	preparing_hook.emit()
	LEDPatternTriggerer.trigger("crocc_hld")
	

	await sprites.animation_finished
	

func _on_hook_state_entered(is_right_hand):
	attacking.emit(Enumerators.Attacks.RIGHT_HOOK if is_right_hand else Enumerators.Attacks.LEFT_HOOK)
	var hand = _get_hand(is_right_hand)
	CounterManager.increase(_prefix("hook", is_right_hand))
	
	# To susbstitute by animation
	var sprites = _animation_sprites_right if is_right_hand else _animation_sprites_left
	
	sprites.play("hook")
	_animation_player.play("hook_hit_" + ("right" if is_right_hand else "left"))
	await sprites.animation_finished
	
	_attack_finished(is_right_hand)


func _on_preparing_uppercut_state_entered(is_right_hand):	
	
	var sprites = _animation_sprites_right if is_right_hand else _animation_sprites_left
	
	sprites.play("upper_cut_anticipation")
	_animation_player.play("upper_cut_anticipation")
	
	LEDPatternTriggerer.trigger("crocc_hld")
	preparing_uppercut.emit()
	
	await sprites.animation_finished
	

func _on_uppercut_state_entered(is_right_hand):
	attacking.emit(Enumerators.Attacks.RIGHT_UPPERCUT if is_right_hand else Enumerators.Attacks.LEFT_UPPERCUT)
	var hand = _get_hand(is_right_hand)
	CounterManager.increase(_prefix("uppercut", is_right_hand))
	
	# To susbstitute by animation
	var sprites = _animation_sprites_right if is_right_hand else _animation_sprites_left
	
	sprites.play("upper_cut")
	_animation_player.play("upper_cut")
	
	LEDPatternTriggerer.trigger("crocc_reset")
	
	
	await sprites.animation_finished
	
	_attack_finished(is_right_hand)


#----------------------------------------
# Dodge
#----------------------------------------

var dodge_timer = null
func _on_dodging_left_state_entered():
	CounterManager.increase("dodge_left")
	gameplay_arena.rotate_arena(true)
	
	_animation_sprites_right.play("block")
	_animation_sprites_left.play("block")
	_animation_player.play("dodge_left", -1, 1, false)
	
	await _animation_player.animation_finished
	_on_dodge_timeout()


func _on_dodging_right_state_entered():
	CounterManager.increase("dodge_right")
	gameplay_arena.rotate_arena(false)
	
	_animation_sprites_right.play("block")
	_animation_sprites_left.play("block")
	_animation_player.play("dodge_right")
	
	await _animation_player.animation_finished
	_on_dodge_timeout()
	
	
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
	print("guard")
	_animation_sprites_left.play("guard")
	_animation_sprites_right.play("guard")


func _on_guard_state_processing(delta):
	CounterManager.increase("guard", delta)


func _on_guard_state_exited():
	_animation_sprites_left.play("guard_exit")
	_animation_sprites_right.play("guard_exit")

#----------------------------------------
# Knockdown
#----------------------------------------
var _knockout_timer
const KNOCKOUT_TIME = 4.0

func _on_knockout_state_entered():
	CounterManager.reset("stand")
	if _knockout_timer == null:
		_knockout_timer = Timer.new()
		add_child(_knockout_timer)
		_knockout_timer.wait_time = KNOCKOUT_TIME
		_knockout_timer.timeout.connect(_on_knockdown_timeout)
	_knockout_timer.start()
	_stand_up_counter.visible = true
	LEDPatternTriggerer.trigger("crocc_rcv_dmg")
	
	_animation_player.play("hurt")
	

func _on_knockout_state_input(event):
	if Utils.is_action_just_released(event, "stand"):
		CounterManager.increase("stand")

func _on_knockdown_timeout():
	if CounterManager._counters.stand == 12:
		_state_chart.send_event("recover")
		_stand_up_counter.visible = false
		
	elif CounterManager._counters.stand < 12:
		CounterManager.limit_reached.emit("knockout")

