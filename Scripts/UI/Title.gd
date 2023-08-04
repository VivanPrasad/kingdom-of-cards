extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	$Background.play()
	get_tree().paused = false
	if Global.title_intro_played:
		$AnimationPlayer.play_backwards("FadeOut")
	else:
		$AnimationPlayer.play("IntroFade")
		Global.title_intro_played = true
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_play_mouse_entered():
	$Options/Play.text = "~ Play"

func _on_play_mouse_exited():
	$Options/Play.text = "Play"


func _on_settings_mouse_entered():
	pass#$Options/Settings.text = "X Settings"


func _on_settings_mouse_exited():
	pass#$Options/Settings.text = "Settings"


func _on_collection_mouse_entered():
	pass#$Options/Collection.text = "X Collection"


func _on_collection_mouse_exited():
	pass#$Options/Collection.text = "Collection"


func _on_quit_mouse_entered():
	$Options/Quit.text = "~ Quit"

func _on_quit_mouse_exited():
	$Options/Quit.text = "Quit"

func _on_play_pressed():
	$AnimationPlayer.play("FadeOut")
	await $AnimationPlayer.animation_finished
	get_tree().change_scene_to_file("res://Scenes/UI/GameMode.tscn")


func _on_settings_pressed():
	get_tree().reload_current_scene()


func _on_collection_pressed():
	get_tree().reload_current_scene()


func _on_quit_pressed():
	get_tree().quit()
