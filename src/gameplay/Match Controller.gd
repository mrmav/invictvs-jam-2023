extends Node


@onready var rest_time_animation = $"../Rest Time Transition/AnimationPlayer"
@onready var game  = $"../Game"

var round = 0
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
	_on_round_timeout()


func _on_round_timeout():
	rest_time_animation.play("Transition")
	game.set_process(false)
	$"../Rest Time Transition/Label".text = "Round " + str(round + 1)
	
	

func _round_animation_finished(_animation):
	if round < 13:
		CounterManager.decrease_all()
		round += 1
		game.set_process(true)
	else:
		print("Game Over")

