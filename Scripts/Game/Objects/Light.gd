extends PointLight2D

var layer
var type
var disabled = false
var hour

func _ready():
	if layer == 1: enabled = false
	hour = get_parent().get_parent().get_child(7).get_child(1).hour
	await get_tree().create_timer(randf_range(0.01,2.00)).timeout
	$AnimationPlayer.play("Flicker")

func _process(_delta):
	if hour == 8:
		if layer == 0 and not disabled:
			$AnimationPlayer.play("Fade")
			disabled = true
	elif hour == 18:
		if layer == 0 and disabled:
			$AnimationPlayer.play_backwards("Fade")
			disabled = false
func update(t): #state is the layer affected, it will invert the layer if true
	if t == 0:
		if not disabled: enabled = bool(layer == 0)
	elif t == 1:
		if not disabled: enabled = bool(layer == 1)
