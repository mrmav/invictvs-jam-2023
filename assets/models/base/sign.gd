extends MeshInstance3D

@export
var possibilities : Array[Texture2D] = []

var material = StandardMaterial3D.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	
	var chance = randf()
	if chance < 0.7:
		queue_free()
	
	material.albedo_texture = possibilities.pick_random()
	material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	material_override = material


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
