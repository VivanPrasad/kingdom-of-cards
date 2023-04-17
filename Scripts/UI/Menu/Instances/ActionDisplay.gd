extends TextureRect

var data : ActionCard
@onready var player = $"/root/World/Entities/Player"
@onready var world = $"/root/World/"

var hovered : bool = false
func _get_drag_data(_at_position):
	pass

func _input(event):
	if event is InputEventMouse:
		if get_global_rect().has_point(get_global_mouse_position()):
			hovered = true
		else:
			hovered = false
func _process(_delta):
	if hovered: 
		modulate = Color(1.1,1.1,1.1,modulate.a)
		position.y -= 5.0 * float(position.y > -8) #when hovered
	else:
		modulate = Color(1.0,1.0,1.0,modulate.a)
		position.y += 5.0 * float(position.y < 0)
func _ready():
	$Name.text = data.name
	if len(data.name) > 10:
		$Name.label_settings.font_size = 8
	$Description.text = data.desc
	$Icon.frame = data.icon_id
	#$".".texture = $".".texture.duplicate()

func handle_use():
	$AnimationPlayer.play("Use")

func _on_button_pressed():
	if modulate.a > 0.9:
		handle_use()
