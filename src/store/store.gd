extends Node

signal player_node_defined()
signal rival_node_defined()
signal rival_health_updated(health)
signal surpassed_down_sequence

var dificulty: int = 1
var perfect_down_sequence: bool = false
var start_down_sequence: bool = false
var down_sequence: int = 0

var player_node: Node:
	set(value):
		player_node = value
		player_node_defined.emit()
		if value != null:
			player_node.hit_rival.connect(on_hit_rival)
		else:
			if player_node.hit_rival.is_connected(on_hit_rival):
				player_node.hit_rival.disconnect(on_hit_rival)
				
func _enter_tree():
	if player_node != null and player_node.hit_rival.is_connected(on_hit_rival):
		player_node.hit_rival.disconnect(on_hit_rival)
				
var rival_node: Node:
	set(value):
		rival_node = value
		rival_node_defined.emit()

var rival_health: int:
	set(value):
		rival_health = value
		rival_health_updated.emit(value)

func on_hit_rival() -> void:
	if start_down_sequence:
		down_sequence += 1
		if down_sequence == 12:
			perfect_down_sequence = true
		if down_sequence > 12:
			perfect_down_sequence = false
			surpassed_down_sequence.emit()
