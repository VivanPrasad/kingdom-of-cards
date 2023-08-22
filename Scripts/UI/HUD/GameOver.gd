extends Control


func _ready():
	$AnimationPlayer.play("Fade In")
	if $"/root/World/HUD/Time".day == 1:
		$Text.text = "You survived 1 day."
	else:
		$Text.text = "You survived " + str($"/root/World/HUD/Time".day) + " day."

func _process(_delta):
	for child in $"/root/World".get_children():
		if child is CharacterBody2D:
			if str(child.name) != Global.player_id:
				child.hide()
func _on_button_pressed():
	Transition.change_scene("res://Scenes/UI/Title.tscn")
	await get_tree().create_timer(0.25).timeout
	get_tree().set_pause(false)
	if Global.player_id.is_valid_int():
		$"/root/World".multiplayer.multiplayer_peer = null
	Audio.change_music("title")
	#DirAccess
	#"hi".get_basename()
