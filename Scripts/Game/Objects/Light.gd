extends PointLight2D

var layer
var type
var disabled = false
var time

func _ready() -> void:
	if layer == 1: enabled = false
	time = $"/root/World/HUD/Time"
	await get_tree().create_timer(randf_range(0.01,2.00)).timeout
	$AnimationPlayer.play("Flicker")

func _process(_delta) -> void:
	if time.hour == 8:
		if layer == 0 and not disabled:
			$AnimationPlayer.play("Fade")
			disabled = true
	elif time.hour == 18:
		if layer == 0 and disabled:
			$AnimationPlayer.play_backwards("Fade")
			disabled = false
func update(t): #state is the layer affected, it will invert the layer if true
	if t == 0:
		if not disabled: enabled = bool(layer == 0)
	elif t == 1:
		if not disabled: enabled = bool(layer == 1)
