extends Control

func _ready():
	pass
	
func _on_disconnect_pressed():
	if str($"../..".name) != "1":
		$"/root/World/".peer.disconnect_peer(int(str($"../..".name)))
	Transition.change_scene("res://Scenes/Game/OnlineWorld.tscn")
	Audio.change_music("online")

func _on_back_pressed():
	queue_free()
	$"../..".current_menu = "None"
