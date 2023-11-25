extends Node3D


@onready var rest_time_animation = $"Rest Time Transition/AnimationPlayer"

var round = 1
var round_timer = null

# Called when the node enters the scene tree for the first time.
func _ready():
	CounterManager.reset_all()
	round_timer = Timer.new()
	add_child(round_timer)
	round_timer.wait_time = 13.0
	round_timer.timeout.connect(_on_round_timeout)
	round_timer.start()
	
	rest_time_animation.animation_finished.connect(_round_animation_finished)

func _on_round_timeout():
	rest_time_animation.play("Transition")
	
	

func _round_animation_finished():
	if round < 13:
		CounterManager.decrease_all()
		round += 1
	else:
		print("Game Over")

