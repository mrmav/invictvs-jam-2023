extends Node3D

@onready var _player = $Player
@onready var _camera = $Player/Camera3D

@onready var _arena = $Arena

const rotate_speed = 6

# Called when the node enters the scene tree for the first time.
func _ready():
	_player.gameplay_arena = self


var _target_arena_rotation = 0.0
func rotate_arena(clockwise):
	if clockwise:
		_target_arena_rotation += PI * 2 / 13
	else:
		_target_arena_rotation -= PI * 2 / 13
	


func _process(delta):
	_arena.rotation = _arena.rotation.lerp(Vector3(0, _target_arena_rotation, 0), delta * rotate_speed)
