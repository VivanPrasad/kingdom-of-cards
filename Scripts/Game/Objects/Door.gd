extends Sprite2D

const animation : Array[String] = ["House","Castle","Bank","Dungeon","Cell","Tailor","Blacksmith","Cabin"]

@export_enum("House","Castle","Bank","Dungeon","Cell","Tailor","Blacksmith","Cabin") var type : int = 0
var body_count : int = 0

@export var on_surface : bool
func _ready(): 
	$AnimationPlayer.speed_scale = 1.25
	frame = type * 7
	if str(get_parent().name) == "Surface":
		on_surface = true
	else:
		on_surface = false

func _on_area_2d_body_entered(body):
	if body is CharacterBody2D:
		if body_count == 0:
			$AnimationPlayer.play(animation[type])
		body_count += 1

func _on_area_2d_body_exited(body):
	if body is CharacterBody2D:
		body_count -= 1
		if not body_count:
			$AnimationPlayer.play_backwards(animation[type])
