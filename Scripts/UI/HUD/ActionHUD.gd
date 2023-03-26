extends Control

@onready var action_display = preload("res://Scenes/UI/Instances/ActionDisplay.tscn")

func _ready():
	for item in $"/root/World/Entities/Player".actions:
		var card = action_display.instantiate()
		card.data = load(get_action_files("res://Data/Actions/").pick_random())
		$CenterContainer/HBoxContainer.add_child(card)

func get_action_files(path : String):
	var dir = DirAccess.get_files_at(path)
	var action_files : Array[String] = []
	for file in dir:
		if not file.ends_with(".gd"):
			action_files.append(path + file)
	return action_files
