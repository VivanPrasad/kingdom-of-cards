extends CharacterBody2D

@onready var emote_menu := preload("res://Scenes/UI/Menu/In-Game/EmoteMenu.tscn")
var speed = 100
func _enter_tree():
	set_multiplayer_authority(name.to_int())
func _ready():
	if str(self.name) == "1":
		$HBoxContainer/HostIcon.visible = true
	if is_multiplayer_authority():
		$Camera2D.enabled = true
		$HBoxContainer/Name.text = get_parent().player_name

func _physics_process(_delta):
	if is_multiplayer_authority():
		var input_vector = Vector2(
				Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
				Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
				).normalized()
		if len($UI.get_children()):
			input_vector = Vector2.ZERO
		if input_vector != Vector2.ZERO: #If moving, blend the position based on the input_vector and run!
			$AnimationTree.set("parameters/Idle/blend_position", input_vector)
			$AnimationTree.set("parameters/Run/blend_position", input_vector)
			$AnimationTree.get("parameters/playback").travel("Run")
		else:
			$AnimationTree.get("parameters/playback").travel("Idle")
		
		velocity = input_vector * speed
	move_and_slide()
	if not is_multiplayer_authority():	return
func _input(_event):
	if not is_multiplayer_authority():	return
	if Input.is_action_just_released("emote"):
		if not get_node_or_null("UI/EmoteMenu"):
			if $Emotes.modulate == Color("ffffff00"):
				$"UI".add_child(emote_menu.instantiate())
				start_thinking.rpc()

@rpc("call_local")
func start_thinking():
	$EmotePlayer.play("Popup")
	await $EmotePlayer.animation_finished
	$EmotePlayer.play("Thinking")

@rpc("call_local")
func stop_thinking():
	$EmotePlayer.play_backwards("Popup")
@rpc("call_local")
func play_emote(id):
	$EmotePlayer.stop()
	$Emotes.frame = id
	$Emotes.show()
	await get_tree().create_timer(3.0).timeout
	$EmotePlayer.play_backwards("Popup")
