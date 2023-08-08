extends CanvasLayer

@onready var world = $"/root/World"
@onready var player = $MarginContainer/AnimationPlayer

func player_joined(id):
	$MarginContainer/AnimationPlayer.stop()
	var label = Label.new()
	var player_name = id.get_node_or_null("Nametag/HBoxContainer/Name").text
	label.text = str(player_name) + " has joined the town"
	label.add_theme_font_size_override("font_size",24)
	$MarginContainer.add_child(label)
	$MarginContainer/AnimationPlayer.play("AutoFade")
	await player.animation_finished
	for child in $MarginContainer.get_children():
		if child is Label:
			child.queue_free()

func player_left(id):
	var label = Label.new()
	var player_name = id.get_node_or_null("Nametag/HBoxContainer/Name").text
	label.text = str(player_name) + " has left the town"
	
	label.add_theme_font_size_override("font_size",24)
	$MarginContainer.add_child(label)
	$MarginContainer/AnimationPlayer.play("AutoFade")
	await player.animation_finished
	for child in $MarginContainer.get_children():
		if child is Label:
			child.queue_free()
