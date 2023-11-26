extends Node


@onready var rest_time_animation = $"../Rest Time Transition/AnimationPlayer"
@onready var game  = $"../Game"
@onready var timer_label  = $"../Timer/Label"
@onready var player_knockout = $"../Game/Gameplay Arena/Player/StateChart/Root/Knockout"

var round = 0
var round_timer = null

# Called when the node enters the scene tree for the first time.
func _ready():
	CounterManager.reset_all()
	round_timer = Timer.new()
	add_child(round_timer)
	round_timer.wait_time = 13.0
	round_timer.one_shot = true
	round_timer.timeout.connect(_on_round_timeout)
	timer_label.text = "13.0"
	
	player_knockout.state_entered.connect(on_knockout)
	player_knockout.state_exited.connect(on_recover)
	
	rest_time_animation.animation_finished.connect(_round_animation_finished)
	_on_round_timeout()


func _on_round_timeout():
	if round == 13:
		CounterManager.limit_reached.emit("rounds")
	else:
		rest_time_animation.play("Transition")
		get_tree().paused = true
		$"../Rest Time Transition/Label".text = "Round " + str(round + 1)
	
	

func _round_animation_finished(_animation):
	if _animation != "Transition":
		return
	if round < 13:
		CounterManager.decrease_all()
		round += 1
		get_tree().paused = false
		round_timer.start()
		rest_time_animation.play("Transition_2")


func _process(delta):
	timer_label.text = str(snapped(round_timer.time_left, 0.1))


func on_knockout():
	round_timer.paused = true

func on_recover():
	round_timer.paused = false
