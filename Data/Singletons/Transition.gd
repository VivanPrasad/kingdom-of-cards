extends CanvasLayer

signal faded

@onready var player : AnimationPlayer = $AnimationPlayer
func change_scene(scene : String,speed = 1.8) -> void:
	player.speed_scale = speed
	player.play("SlideIn")
	await player.animation_finished
	get_tree().change_scene_to_file(scene)
	player.play("SlideOut")
	await player.animation_finished

func change_scene_packed(scene : PackedScene, speed = 1.3) -> void:
	player.speed_scale = speed
	player.play("SlideIn")
	await player.animation_finished
	get_tree().change_scene_to_packed(scene)
	player.play("SlideOut")
	await player.animation_finished

func fade_in(speed = 1.5) -> void:
	player.speed_scale = speed
	player.play("FadeIn")
	emit_signal("faded")

func fade_out(speed = 1.5) -> void:
	player.speed_scale = speed
	player.play_backwards("FadeIn")
	emit_signal("faded")
