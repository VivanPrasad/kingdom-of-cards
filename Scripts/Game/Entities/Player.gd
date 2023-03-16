extends CharacterBody2D

const base_speed = 90
var layer : int = 1

enum state {good,sick,potion,unknown}
var status : int = state.good
var life : int = 4
var hunger : int = 1
var speed : int = base_speed

func _ready():
	$Sprite2D.texture = load(str("res://Assets/Game/Entities/Player/player" + str(randi() % 4 + 1)+".png"))
	update_HUD()
var inventory = [load("res://Data/Cards/Bread.tres").duplicate(),load("res://Data/Cards/Bread.tres").duplicate(),load("res://Data/Cards/Berry.tres").duplicate()]
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
func effect(data): #data = [type, amount, time] #if data[0]
	if data[0] == "speed":
		speed = data[1]
	if data[0] == "clear":
		speed = base_speed
		return
	$EffectTimer.wait_time = data[2]
	$EffectTimer.start()
func eat(value):
	print(value)
	for times in value:
		if hunger < 2:
			hunger += 1
		elif life < 4:
			life += 1
	update_HUD()

func update_HUD():
	if life <= 4:
		$"../../UI/Profile/Life".frame = life * (status + 1)
		$"../../UI/Profile/Armour".frame = 15
	else:
		$"../../UI/Profile/Armour".frame = (life - 4) * 5
		$"../../UI/Profile/Life".frame = 3
	
	$"../../UI/Profile/Hunger".frame = hunger


func _on_timer_timeout():
	effect(["clear",0,0])
