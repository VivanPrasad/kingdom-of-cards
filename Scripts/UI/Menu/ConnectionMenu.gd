extends Control

@onready var world = $"../.."

func _on_back_pressed():
	Audio.change_music(Music.TITLE)
	Transition.change_scene(Global.Scenes.WORLD_SCENE)

func _process(_delta):
	for child in world.get_children():
		if child is Player:
			if visible: hide()
			return
		else:
			show()
