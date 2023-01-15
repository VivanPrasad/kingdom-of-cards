extends PointLight2D

var layer
var type

func _ready():
	if layer == 1:
		enabled = false
	randomize()
	var delay = randf_range(0.01,1.00)
	$Timer.wait_time = delay
	$Timer.start()

func update(t): #state is the layer affected, it will invert the layer if true
	if t == 0:
		enabled = bool(layer == 0)
	elif t == 1:
		enabled = bool(layer == 1)
	elif t == 2:
		$AnimationPlayer.play("Fade")
	elif t == 3:
		$AnimationPlayer.play_backwards("Fade")

func _on_timer_timeout():
	$AnimationPlayer.play("Flicker")
