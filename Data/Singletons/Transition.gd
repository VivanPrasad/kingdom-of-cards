## Transition
extends CanvasLayer

@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var mouse_filter: Control = $MouseFilter

signal faded

## Change scene by wiping the screen from left to right
func change_scene(scene : Variant, speed : float = 1.9) -> void:
	animation_player.speed_scale = speed
	mouse_filter.show()
	animation_player.play("SlideIn")
	await animation_player.animation_finished
	if scene is String: 
		get_tree().change_scene_to_file(scene)
	elif scene is PackedScene: 
		get_tree().change_scene_to_packed(scene)
	animation_player.play("SlideOut")
	await animation_player.animation_finished
	mouse_filter.hide()
	faded.emit()

func fade_in(speed : float = 1.5) -> void:
	animation_player.speed_scale = speed
	animation_player.play("FadeIn")
	await animation_player.animation_finished
	faded.emit()

func fade_out(speed : float = 1.5) -> void:
	animation_player.speed_scale = speed
	animation_player.play_backwards("FadeIn")
	await animation_player.animation_finished
	faded.emit()
