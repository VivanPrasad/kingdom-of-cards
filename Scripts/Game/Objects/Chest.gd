extends StaticBody2D

@export_enum("Old","New","Gold") var type : String = "Old"

var nearby : bool = false
var hovered : bool = false
var player : Node

func _process(_delta):
	player = $"/root/World".get_node_or_null(Global.player_id)
	if player != null:
		if hovered and nearby and player.current_menu == "None" and not player.get_node("Menu").get_child_count():
			modulate = Color(1.5,1.5,1.5,1)
			$Label.visible = true
		else:
			hovered = false
			modulate = Color(1,1,1,1)
			$Label.visible = false

func _on_player_area_body_entered(body):
	if body == player:
		nearby = true

func _on_player_area_body_exited(body):
	if body == player:
		nearby = false

#####
func _on_mouse_area_mouse_entered():
	hovered = true

func _on_mouse_area_mouse_exited():
	hovered = false
