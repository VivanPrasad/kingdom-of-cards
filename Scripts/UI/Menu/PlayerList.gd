extends CanvasLayer

@onready var player_display = preload("res://Scenes/UI/Instances/PlayerDisplay.tscn")
@onready var world = $"/root/World"

var mobile : bool = false
func _input(_event):
	if not mobile and Game.is_online:
		if Input.is_action_pressed("player_list"):
			show()
		else:
			hide()
	update_list()

func update_list():
	for child in $Panel/VBoxContainer.get_children():
		if not child is Label: child.queue_free()
	for child in world.get_children():
		if child is CharacterBody2D:
			var display = player_display.instantiate()
			display.icon = child.character
			display.player_name = child.get_node_or_null("Nametag/HBoxContainer/Name").text
			$Panel/VBoxContainer.add_child(display)
