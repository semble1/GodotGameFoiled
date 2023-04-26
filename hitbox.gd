extends Area2D

@export var damage: int = 10
# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("hitboxes")
