extends StaticBody2D

@onready var sprite : Node = $Sprite2D
@onready var time : Node = $"/root/Audio"

@onready var player : Node
@onready var berry_card : Card = preload("res://Data/Cards/Berry.tres")

var hovered : bool = false

func _physics_process(_delta):
	player = $"/root/World".get_node_or_null(Global.player_id)
	if player != null and $Sprite2D.frame == 0 and $Timer.is_stopped():
		$Timer.wait_time = randf_range(180,300.0) #3-5 minutes regrowth
		$Timer.start()
	if hovered:
		$Label.show()
		if $Sprite2D.frame == 0:
			$Sprite2D.modulate = Color(1.5,1.0,1.0,1.0)
		else:
			$Sprite2D.modulate = Color(1.5,1.6,1.5,1.0)
	else:
		$Label.hide()
		$Sprite2D.modulate = Color(1.0,1.0,1.0,1.0)

func _input(event):
	if ((event is InputEventScreenTouch and hovered) or (event is InputEventMouseButton and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT))) and hovered and $Sprite2D.frame == 1:
		hovered = false
		$Sprite2D.frame = 0
		player.inventory.append(berry_card.duplicate())
		$Timer.wait_time = randf_range(15.0,60.0)
		$Timer.start()
		
func _on_timer_timeout():
	$Sprite2D.frame = 1

func _on_area_2d_mouse_entered():
	if player.current_menu == "None":
		hovered = true

func _on_area_2d_mouse_exited():
	hovered = false
