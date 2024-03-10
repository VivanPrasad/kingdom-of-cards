extends CanvasLayer

signal faded

@onready var player = $AnimationPlayer
func change_scene(scene : String,speed = 1.5):
	player.speed_scale = speed
	player.play("FadeIn")
	await player.animation_finished
	get_tree().change_scene_to_file(scene)
	player.play_backwards("FadeIn")
	await player.animation_finished
	
func fade_in(speed = 1.5):
	player.speed_scale = speed
	player.play("FadeIn")
	emit_signal("faded")

func fade_out(speed = 1.5):
	player.speed_scale = speed
	player.play_backwards("FadeIn")
