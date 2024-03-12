extends Control

func _ready():
	$Background.play()


func _on_back_mouse_entered():
	$Options/Back.text = "~ Back"

func _on_back_mouse_exited():
	$Options/Back.text = "Back"

func _on_back_pressed():
	Transition.change_scene("res://Scenes/UI/Title.tscn")


func _on_solo_pressed():
	Audio.change_music("day")
	Transition.change_scene("res://Scenes/Game/World.tscn")

func _on_solo_mouse_entered():
	$Options/Solo.text = "~ Solo"

func _on_solo_mouse_exited():
	$Options/Solo.text = "Solo"

func _on_online_mouse_entered():
	$Options/Online.text = "~ Online"


func _on_online_mouse_exited():
	$Options/Online.text = "Online"

func _on_online_pressed():
	Audio.change_music("online")
	Transition.change_scene("res://Scenes/Game/World.tscn")
