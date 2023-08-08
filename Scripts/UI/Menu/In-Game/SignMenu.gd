extends CanvasLayer

func _unhandled_input(_event):
	if Input.is_action_just_pressed("ui_cancel"):
		queue_free()
