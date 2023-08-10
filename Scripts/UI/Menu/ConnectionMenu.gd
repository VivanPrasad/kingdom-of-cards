extends Control

@onready var world = $"../.."

func _on_back_pressed():
	get_tree().paused = true
	Audio.change_music("online")
	Transition.change_scene("res://Scenes/Game/OnlineWorld.tscn")
	


func _process(_delta):
	for child in world.get_children():
		if child is CharacterBody2D:
			if visible: hide()
			return
		else:
			Audio.get_child(0).stop()
			show()
	
