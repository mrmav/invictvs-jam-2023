extends Node3D

@export 
var textures_available : Array[Texture2D] = []

var material = StandardMaterial3D.new()

@onready var player = get_node("../../../Player")

# Called when the node enters the scene tree for the first time.
func _ready():
	
	material.albedo_texture = textures_available.pick_random()
	material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	$Node/audience.material_override = material

	var target = position
	target.x = 0
	target.z = 0
	look_at(target, Vector3.UP, true)
	
	await get_tree().process_frame
	player.hit_rival.connect(play_animation)


func _process(delta):
	if Store.rival_health < 0 or Store.player_node.is_knocked_out:
		play_animation()
		await $AnimationPlayer.animation_finished

	
func play_animation():
	var chance = randf()
	if chance >= 0.7:
		$AnimationPlayer.play("jump")
