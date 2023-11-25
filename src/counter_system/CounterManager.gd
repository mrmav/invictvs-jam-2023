extends Node

signal limit_reached(id:String)

var _counters = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	_register("left_jab")
	_register("left_hook")
	_register("left_uppercut")
	_register("left_dodge")
	_register("right_jab")
	_register("right_hook")
	_register("right_uppercut")
	_register("right_dodge")


# Registers new counter
# -is_float: bool - true for floats (like time counters)
func _register(id: String, is_float = false):
	_counters[id] = 0.0 if is_float else 0


# Increases a counter
func increase(id: String, value = 1):
	_counters[id] += value
	emit_signal(id)


# Decreases a counter
func decrease(id: String, value = 1):
	_counters[id] -= value
	_counters[id] = max(_counters[id], 0)
	

# Decreases all counter
func decrease_all(value = 1):
	for id in _counters:
		decrease(id, value)


# Resets a counter (counter = 0)
func reset(id: String):
	_counters[id] = 0


# Resets a counter (counter = 0)
func reset_all():
	for id in _counters:
		reset(id)

