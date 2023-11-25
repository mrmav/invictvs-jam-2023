extends Node

signal player_node_defined()
signal rival_node_defined()
signal rival_health_updated(health)

var dificulty: int = 1

var player_node: Node:
	set(value):
		player_node = self
		player_node_defined.emit()
var rival_node: Node:
	set(value):
		rival_node = self
		rival_node_defined.emit()

var rival_health: int:
	set(value):
		rival_health = value
		rival_health_updated.emit(value)

