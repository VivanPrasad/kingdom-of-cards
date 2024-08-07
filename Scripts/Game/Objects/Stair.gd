extends Area2D

@export_enum("Mine","Dungeon") var type
func _ready():
	connect("body_entered",Callable(get_parent(),["descend_to_mines","descend_to_dungeon"][type]))
