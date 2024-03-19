extends StaticBody2D
class_name Market

@onready var world : Game = $"/root/World"
@onready var sprite : Sprite2D = $Sprite2D
@onready var label: Control = $Label

#Market
var nearby : bool = false
var hovered : bool = false
var player : Player

func _physics_process(_delta):
	player = world.get_node_or_null(Global.player_id)
	if player != null:
		if hovered and player.current_menu == "None" and not player.get_node("Menu").get_child_count():
			modulate = Color(1.5,1.5,1.5,1)
			label.visible = true
		else:
			modulate = Color(1,1,1,1)
			label.visible = false

func _input(event):
	if event is InputEventMouse or event is InputEventScreenTouch:
		if sprite.get_rect().has_point(sprite.get_local_mouse_position()):
			hovered = true
		else:
			hovered = false
		
		if (Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) or event is InputEventScreenTouch) and hovered:
			if player.current_menu == "None":
				player.open_menu(player.market_menu)

func _on_area_2d_body_entered(body):
	if body == player:
		nearby = true

func _on_area_2d_body_exited(body):
	if body == player:
		nearby = false
