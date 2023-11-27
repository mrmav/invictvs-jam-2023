extends Label

@export_multiline
var quixant_text : String = ""

@export_multiline
var other_systems_text : String = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	if Store.QUIXANT_SUPPORTED:
		text = quixant_text
	else:
		text = other_systems_text
