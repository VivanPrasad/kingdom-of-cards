extends CharacterBody2D

var input_vector = Vector2.ZERO

var layer : int = 1

var on_cooldown : bool = false
var touching_player : bool = false
var health : int = 3
var VELOCITY = Vector2.ZERO
@onready var player = $"/root/World/Entities/Player"
@onready var agent = $NavigationAgent2D
@onready var world = $"/root/World/"
var direction = Vector2.ZERO

func _physics_process(_delta):
	if player.layer == layer:
		visible = true
	else:
		visible = false
	if not agent.is_navigation_finished():
		direction = global_position.direction_to(agent.get_next_path_position())
	else:
		direction = Vector2.ZERO
	if  direction != Vector2.ZERO: #If moving, blend the position based on the input_vector and run!
		$AnimationTree.set("parameters/Idle/blend_position", direction)
		$AnimationTree.set("parameters/Run/blend_position", direction)
		$AnimationTree.get("parameters/playback").travel("Run")
	else:
		$AnimationTree.get("parameters/playback").travel("Idle")
	
	velocity = direction.normalized() * 95
	move_and_slide()
	
	if not on_cooldown and touching_player:
		player.hurt()
		attack_cooldown()
	
	check_surroundings()

func check_surroundings():
	if position.distance_to(player.position) < 200:
		await get_tree().create_timer(0.5).timeout
		player.in_combat = true
		agent.target_position = player.position
	else:
		await get_tree().create_timer(5).timeout
		agent.target_position = position + Vector2(randi() % 301 - 150,randi() % 301 - 150)
		player.in_combat = false

func attack_cooldown():
	on_cooldown = true
	await get_tree().create_timer(2).timeout
	on_cooldown = false

func _on_area_2d_body_entered(body):
	if body.name == "Player":
		touching_player = true

func _on_area_2d_body_exited(body):
	if body.name == "Player":
		touching_player = false
