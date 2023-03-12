extends CharacterBody2D
var input_vector = Vector2.ZERO

@export var path_to_player : NodePath

var VELOCITY = Vector2.ZERO
@onready var player = get_node(path_to_player)
@onready var agent = $NavigationAgent2D

var direction = Vector2.ZERO

var locations : Array[Vector2]
func _ready():
	$Sprite2D.texture = load(str("res://Assets/Game/Entities/Player/player" + str(randi() % 4 + 1)+".png"))
	locations.append(player.position)
	locations.append(Vector2())

func _physics_process(_delta):
	
	if not agent.is_navigation_finished():
		direction = global_position.direction_to(agent.get_next_path_position())
	else:
		direction = Vector2.ZERO
	if  direction != Vector2.ZERO: #If moving, blend the position based on the input_vector and run!
		$AnimationTree.set("parameters/Idle/blend_position", input_vector)
		$AnimationTree.set("parameters/Run/blend_position", input_vector)
		$AnimationTree.get("parameters/playback").travel("Run")
	else:
		$AnimationTree.get("parameters/playback").travel("Idle")
	
	velocity = direction.normalized() * 100
	move_and_slide()

func _on_timer_timeout():
	agent.target_position = locations[randi() % len(locations)]
	locations.append(player.position)
