extends Sprite2D; const animation = ["Door","Castle","Bank","Dungeon1","Dungeon2","Tailor","Blacksmith","Cabin"]; var type : int = 0
func _ready(): 
	for i in animation: if str(name).contains(animation[animation.find(i)]): type = animation.find(i)
	frame = type * 7

func _on_area_2d_body_entered(body): if body.name == "Player": $AnimationPlayer.play(animation[type])
func _on_area_2d_body_exited(body): if body.name == "Player": $AnimationPlayer.play_backwards(animation[type])
