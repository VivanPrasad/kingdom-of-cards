extends StaticBody2D

@export var open : bool = false
@onready var time : Node = $"/root/World/HUD/Time"
@onready var animation : Node = $Gate/AnimationPlayer
func _physics_process(_delta):
	if time.hour == 8:
		if not open:
			$Gate/AnimationPlayer.play("Gate")
			await animation.animation_finished
			open = true
	elif time.hour == 20:
		if open:
			$Gate/AnimationPlayer.play_backwards("Gate")
			await animation.animation_finished
			open = false
	elif time.hour > 8 and time.hour < 20:
		$Gate.frame = 12
		open = true
		$CollisionShape2D.disabled = true
	elif time.hour < 8 and time.hour > 20:
		$Gate.frame = 0
		open = false
		$CollisionShape2D.disabled = false
