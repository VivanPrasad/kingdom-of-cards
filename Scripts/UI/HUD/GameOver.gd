extends Control


func _ready():
	if $"/root/World/HUD/Time".day == 1:
		$Text.text = "You survived 1 day."
	else:
		$Text.text = "You survived " + str($"/root/World/HUD/Time".day) + " day."
func _on_button_pressed():
	Transition.change_scene("res://Scenes/UI/Title.tscn")
	Audio.change_music("title")
	queue_free()
	#DirAccess
	#"hi".get_basename()
