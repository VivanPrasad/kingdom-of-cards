extends StaticBody2D
#Market
var nearby : bool = false
var hovered : bool = false
@onready var player = $"/root/World/Entities/Player"
@onready var world = $"/root/World/"

func _ready():
	world.market_locations[str(name)] = (position + Vector2(0,6)) * 5
	print(world.market_locations)
func _physics_process(_delta):
	if nearby and hovered:
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
		if $Sprite2D.get_rect().has_point(get_local_mouse_position()):
			hovered = true
		else:
			hovered = false
