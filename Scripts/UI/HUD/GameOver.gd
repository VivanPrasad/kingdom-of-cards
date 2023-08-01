extends Control


func _ready():
	if $"/root/World/UI/Time".day == 1:
		$Text.text = "You survived 1 day."
	else:
		$Text.text = "You survived " + str($"/root/World/UI/Time".day) + " day."
func _on_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/UI/Title.tscn")
	queue_free()
	#DirAccess
	#"hi".get_basename()
