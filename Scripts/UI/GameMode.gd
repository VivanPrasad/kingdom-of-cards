extends Control

func _ready():
	$Background.play()


func _on_back_mouse_entered():
	$Options/Back.text = "~ Back"

func _on_back_mouse_exited():
	$Options/Back.text = "Back"

func _on_back_pressed():
	$AnimationPlayer.play_backwards("Fade")
	await $AnimationPlayer.animation_finished
	get_tree().change_scene_to_file("res://Scenes/UI/Title.tscn")


func _on_solo_pressed():
	$AnimationPlayer.play_backwards("Fade")
	await $AnimationPlayer.animation_finished
	get_tree().change_scene_to_file("res://Scenes/Game/World.tscn")

func _on_solo_mouse_entered():
	$Options/Solo.text = "~ Solo"

func _on_solo_mouse_exited():
	$Options/Solo.text = "Solo"


func _on_online_mouse_entered():
	$Options/Online.text = "~ Online"


func _on_online_mouse_exited():
	$Options/Online.text = "Online"

func _on_online_pressed():
	$Control.visible = true


func _on_host_pressed():
	$AnimationPlayer.play_backwards("Fade")
	await $AnimationPlayer.animation_finished
	get_parent().add_child(load("res://Scenes/Game/World.tscn").instantiate())
	queue_free()


func _on_join_pressed():
	$AnimationPlayer.play_backwards("Fade")
	await $AnimationPlayer.animation_finished
	get_parent().add_child(load("res://Scenes/Game/World.tscn").instantiate())
	queue_free()


func _on_control_pressed():
	$Control.visible = false
	
