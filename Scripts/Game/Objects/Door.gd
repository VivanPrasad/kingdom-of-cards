extends Sprite2D; const animation = ["Door","Castle","Bank","Dungeon1","Dungeon2","Tailor","Blacksmith","Cabin"]; var type : int = 0
func _ready(): 
	$AnimationPlayer.speed_scale = 1.25
	for i in animation: if str(name).contains(animation[animation.find(i)]): type = animation.find(i)
	frame = type * 7

func _on_area_2d_body_entered(body): if str(body.name).contains("Player") or str(body.name).contains("NPC"): $AnimationPlayer.play(animation[type])
func _on_area_2d_body_exited(body): if str(body.name).contains("Player") or str(body.name).contains("NPC"): $AnimationPlayer.play_backwards(animation[type])
