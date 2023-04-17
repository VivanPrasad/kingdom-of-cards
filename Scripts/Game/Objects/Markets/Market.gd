extends StaticBody2D
#Market
var nearby : bool = false
var hovered : bool = false
@onready var player = $"/root/World/Entities/Player"
@onready var world = $"/root/World"

func _ready():
	world.market_locations[str(name)] = (position + Vector2(0,6)) * 5

func _physics_process(_delta):
	if nearby and hovered and world.current_menu == world.menu.none:
		modulate = Color(1.5,1.5,1.5,1)
		$Label.visible = true
	else:
		modulate = Color(1,1,1,1)
		$Label.visible = false

func _on_area_2d_body_entered(body):
	if str(body.name).contains("Player"): nearby = true

func _on_area_2d_body_exited(body):
	if str(body.name).contains("Player"): nearby = false

func _input(event):
	if event is InputEventMouse:
		if $Sprite2D.get_rect().has_point($Sprite2D.get_local_mouse_position()):
			hovered = true
		else:
			hovered = false
		if event is InputEventMouseButton and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) and hovered:
			if world.current_menu == 0:
				world.current_menu = world.menu.market
