extends Node

signal limit_reached(id:String)
signal update(id:String, value)

const COUNTER_LIMIT = 13

var _counters = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	_register("left_jab")
	_register("left_hook")
	_register("left_uppercut")
	_register("dodge_left")
	_register("right_jab")
	_register("right_hook")
	_register("right_uppercut")
	_register("dodge_right")
	_register("guard", true)
	_register("stand")


# Registers new counter
# -is_float: bool - true for floats (like time counters)
func _register(id: String, is_float = false):
	_counters[id] = 0.0 if is_float else 0


# Increases a counter
func increase(id: String, value = 1):
	_counters[id] += value
	update.emit(id, _counters[id])
	if _counters[id] >= COUNTER_LIMIT:
		limit_reached.emit(id)


# Decreases a counter
func decrease(id: String, value = 1):
	_counters[id] -= value
	_counters[id] = max(_counters[id], 0)
	update.emit(id, _counters[id])
	

# Decreases all counter
func decrease_all(value = 1):
	for id in _counters:
		decrease(id, value)


# Resets a counter (counter = 0)
func reset(id: String):
	_counters[id] = 0
	update.emit(id, _counters[id])


# Resets a counter (counter = 0)
func reset_all():
	for id in _counters:
		reset(id)

