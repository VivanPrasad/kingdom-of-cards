extends Control

@onready var settings : PackedScene = preload("res://Scenes/UI/Settings.tscn")
@onready var world : Node = $"/root/World"

func _ready():
	if Global.player_id.is_valid_int():
		$Panel/CenterContainer/VBoxContainer/Disconnect.text = "Disconnect"
	else:
		$Panel/CenterContainer/VBoxContainer/Disconnect.text = "Quit to Menu"

func _on_disconnect_pressed():
	if Global.player_id.is_valid_int():
		Transition.change_scene("res://Scenes/Game/OnlineWorld.tscn")
		Audio.change_music("online")
		if str($"../..".name) != "1":
			world.peer.close()
	else:
		Transition.change_scene("res://Scenes/UI/GameMode.tscn")
		Audio.change_music("title")
func _on_back_pressed():
	queue_free()
	$"../..".current_menu = "None"


func _on_settings_pressed():
	add_child(settings.instantiate())