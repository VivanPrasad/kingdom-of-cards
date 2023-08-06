extends Control

func _ready():
	if Global.player_id.is_valid_int():
		$Panel/CenterContainer/VBoxContainer/Disconnect.text = "Disconnect"
	else:
		$Panel/CenterContainer/VBoxContainer/Disconnect.text = "Quit to Menu"
	
func _on_disconnect_pressed():
	if Global.player_id.is_valid_int():
		if str($"../..".name) != "1":
			$"/root/World/".peer.disconnect_peer(int(str($"../..".name)))
		Transition.change_scene("res://Scenes/Game/OnlineWorld.tscn")
		Audio.change_music("online")
	else:
		Transition.change_scene("res://Scenes/UI/GameMode.tscn")
		Audio.change_music("title")

func _on_back_pressed():
	queue_free()
	$"../..".current_menu = "None"
