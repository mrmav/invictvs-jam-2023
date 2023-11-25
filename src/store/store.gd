extends Node

signal player_node_defined()
signal rival_node_defined()
signal rival_health_updated(health)

var dificulty: int = 1
var perfect_down_sequence: bool = false

var player_node: Node:
	set(value):
		player_node = value
		player_node_defined.emit()
var rival_node: Node:
	set(value):
		rival_node = value
		rival_node_defined.emit()

var rival_health: int:
	set(value):
		rival_health = value
		rival_health_updated.emit(value)

