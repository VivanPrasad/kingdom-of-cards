extends Sprite2D

const animation = ["Door","Castle","Bank","Dungeon1","Dungeon2","Tailor","Blacksmith","Cabin"]; var type : int = 0

func _ready(): 
	$AnimationPlayer.speed_scale = 1.25
	for i in animation: 
		if str(name).contains(animation[animation.find(i)]): 
			type = animation.find(i)
	frame = type * 7

func _on_area_2d_body_entered(body):
	if str(body.name).contains("Player"):
		$AnimationPlayer.play(animation[type])
	if str(body.name).contains("NPC"):
		$AnimationPlayer.play(animation[type])

func _on_area_2d_body_exited(body):
	if str(body.name).contains("Player"): 
		$AnimationPlayer.play_backwards(animation[type])
	if str(body.name).contains("NPC"):
		$AnimationPlayer.play_backwards(animation[type])

### I Had to make a custom set of doors for the tileset
### DOOR IDs (change in the packed scenes of id >1 the first variant names value to the names in the animation)
# 1 : House
# 2 : Castle
