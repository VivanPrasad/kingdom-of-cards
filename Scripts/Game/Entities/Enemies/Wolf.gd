extends CharacterBody2D

var input_vector = Vector2.ZERO

@export var on_surface : bool = true

@export var on_cooldown : bool = false
@export var touching_player : bool = false
@export var life : int = 10
var speed : int = 90
const base_speed : int = 90
var VELOCITY = Vector2.ZERO
@onready var agent = $NavigationAgent2D
@onready var world = $"/root/World/"
var direction = Vector2.ZERO
var player = null

func _physics_process(_delta):
	player = world.get_node_or_null(Global.player_id)
	if player != null:
		if player.on_surface == on_surface:
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
			
		velocity = direction.normalized() * speed
	move_and_slide()
			
	if not on_cooldown and touching_player:
		player.hurt()
		attack_cooldown()
			
			#print("on_cooldown:" + str(on_cooldown))
			#print("touching_player:" + str(touching_player))
	check_surroundings()
			
	if life == 0:
		die()
func check_surroundings():
	if not $Hurt.is_playing():
		if position.distance_to(player.position) < 200:
			if not self in player.enemies:
				player.enemies.append(self)
			agent.target_position = player.position
		else:
			await get_tree().create_timer(1.0).timeout
			if self in player.enemies:
				player.enemies.erase(self)

func attack_cooldown():
	on_cooldown = true
	await get_tree().create_timer(0.8).timeout
	on_cooldown = false

func _on_area_2d_body_entered(body):
	if body.name == "Player":
		touching_player = true

func _on_area_2d_body_exited(body):
	if body.name == "Player":
		touching_player = false

func die():
	direction = Vector2.ZERO
	agent.target_position = position
	$Hurt.play("Death")
	await $Hurt.animation_finished
	if self in player.enemies:
		player.enemies.erase(self)
	queue_free()

func hurt():
	$Hurt.play("Hurt")
	life -= 1
	await get_tree().create_timer(0.5).timeout
	if life == 0:
		die()
func strike():
	$Hurt.stop()
	$Hurt.play("Strike")
	life -= 1
	await get_tree().create_timer(0.5).timeout
	if life == 0:
		die()

func stun():
	direction = Vector2.ZERO
	agent.target_position = position
	$Hurt.play("Stun")
