extends AnimationPlayer


@onready var label = $"../Label"
@export var counter = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	CounterManager.update.connect(update)
	label.text = "0"

func update(_id, value):
	if _id == counter:
		if value is float:
			value = snapped(value, 0.1)
		label.text = str(value)
		play("update")


