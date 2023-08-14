extends StaticBody2D

@export_multiline var text = ""

var player : Node
var hovered : bool = false

@export var on_surface : bool = true
func _ready():
	player = $"/root/World".get_node_or_null(Global.player_id)
func _physics_process(_delta):
	if player != null:
		if on_surface != player.on_surface:
			hide()
			hovered = false
		else:
			show()
	if hovered:
		$Label.show()
		$Sprite2D.modulate = Color(1.5,1.5,1.5,1.0)
	else:
		$Label.hide()
		$Sprite2D.modulate = Color(1.0,1.0,1.0,1.0)

func _input(event):
	if ((event is InputEventScreenTouch and hovered) or (event is InputEventMouseButton and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT))) and hovered:
		hovered = false
		player.open_menu(player.sign_menu,text)
func _on_area_2d_mouse_entered():
	if player != null:
		if player.current_menu == "None":
			hovered = true
		else:
			hovered = false

func _on_area_2d_mouse_exited():
	hovered = false
