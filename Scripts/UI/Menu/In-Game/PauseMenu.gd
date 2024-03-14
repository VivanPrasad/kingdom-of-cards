extends Control

@onready var settings : PackedScene = preload("res://Scenes/UI/Settings.tscn")
@onready var world : Node = $"/root/World"
@onready var disconnect_button : Button = $Panel/CenterContainer/VBoxContainer/Disconnect
func _ready():
	if Game.is_online:
		disconnect_button.text = "Disconnect"
	else:
		disconnect_button.text = "Quit to Menu"

func _on_disconnect_pressed():
	if Game.is_online:
		get_tree().set_pause(true)
		Transition.change_scene(Global.Scenes.GAME_MODE_SCENE)
		await get_tree().create_timer(0.4).timeout
		get_tree().set_pause(false)
		Audio.change_music(Music.ONLINE)
		for node in world.get_children():
			if node is Player:
				world.remove_child(node)
		world.multiplayer.multiplayer_peer = null
	else:
		Transition.change_scene(Global.Scenes.GAME_MODE_SCENE)
		Audio.change_music(Music.ONLINE)
func _on_back_pressed():
	queue_free()
	$"../..".current_menu = "None"
	

func _on_settings_pressed():
	add_child(settings.instantiate())
