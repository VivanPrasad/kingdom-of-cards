extends CharacterBody2D

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
		if input_vector != Vector2.ZERO: #If moving, blend the position based on the input_vector and run!
			$AnimationTree.set("parameters/Idle/blend_position", input_vector)
			$AnimationTree.set("parameters/Run/blend_position", input_vector)
			$AnimationTree.get("parameters/playback").travel("Run")
		else:
			$AnimationTree.get("parameters/playback").travel("Idle")
		velocity = input_vector * speed
	move_and_slide()
