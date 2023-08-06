extends StaticBody2D
#Market
var nearby : bool = false
var hovered : bool = false
var player : Node
@onready var world = $"/root/World"

func _ready():
	world.market_locations[str(name)] = (position + Vector2(0,6)) * 5

func _physics_process(_delta):
	player = $"/root/World".get_node_or_null(Global.player_id)
	if nearby and hovered and player.current_menu == "None" and not player.get_node("Menu").get_child_count():
		modulate = Color(1.5,1.5,1.5,1)
		$Label.visible = true
	else:
		modulate = Color(1,1,1,1)
		$Label.visible = false

func _on_area_2d_body_entered(body):
	if body is CharacterBody2D and body.is_multiplayer_authority(): nearby = true

func _on_area_2d_body_exited(body):
	if body is CharacterBody2D and body.is_multiplayer_authority(): nearby = false

func _input(event):
	if event is InputEventMouse:
		if $Sprite2D.get_rect().has_point($Sprite2D.get_local_mouse_position()):
			hovered = true
		else:
			hovered = false
		if event is InputEventMouseButton and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) and hovered:
			if player.current_menu == "None":
				player.open_menu(player.market_menu)
