extends CharacterBody2D

var layer : int = 1
var speed : int = 100

func _ready():
	$Sprite2D.texture = load(str("res://Assets/Game/Entities/Player/player" + str(randi() % 4 + 1)+".png"))
var inventory = [load("res://Data/Cards/Bread.tres"),load("res://Data/Cards/Bread.tres"),load("res://Data/Cards/Berry.tres"),Card.new("TJ",83,"Backrooms Map?")]


func _physics_process(_delta):
	# Get the input direction and handle the movement/deceleration.
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
