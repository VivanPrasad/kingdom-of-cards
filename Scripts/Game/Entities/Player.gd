extends CharacterBody2D

const base_speed = 100
enum state {good,sick,potion,unknown}

var layer : int = 1 #layer 1 = surface, layer 0 = dungeon

var actions = 2 #number of action cards during combat
#+1 if holding the ring 
#+1 if the guard role?

var status : int = state.good
var life : int = 4 #heart
var hunger : int = 2 #food
var speed : int = base_speed #starts at base speed

var in_combat : bool = false
var effect_queue : Array
@onready var world = $"../.."
func _ready():
	$Sprite2D.texture = load(str("res://Assets/Game/Entities/Player/player" + str(randi() % 4 + 1)+".png"))
	update_HUD()
var inventory = [load("res://Data/Cards/Bread.tres").duplicate(),load("res://Data/Cards/Bag++.tres").duplicate(),load("res://Data/Cards/Berry.tres").duplicate(),load("res://Data/Cards/Potion.tres").duplicate(),load("res://Data/Cards/Fishing Rod.tres").duplicate(),load("res://Data/Cards/Elixir.tres").duplicate()]
func _process(_delta):
	if world.current_menu == 0 or world.current_menu == 3: #0 = menu.none
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
	else:
		$AnimationTree.get("parameters/playback").travel("Idle")
func effect(data): #data = [type, value, time (s)] #if data[0]
	var type = data[0]; var value = data[1]; var time = data[2]
	if type == "speed":
		speed = value + 10
		$"../../UI/Chat".addMessage("Debug","Gave speed effect, increasing speed to " + str(value) + " for " + str(time) + " seconds.")
		await get_tree().create_timer(time).timeout
		$"../../UI/Chat".addMessage("Debug","Effect ended")
		speed = base_speed
	elif type == "immune":
		var previous_state = status
		status = state.potion
		update_HUD()
		$"../../UI/Chat".addMessage("Debug","Gave immunity for " + str(time) + " seconds.")
		await get_tree().create_timer(time).timeout
		$"../../UI/Chat".addMessage("Debug","Effect ended")
		status = previous_state
		update_HUD()
func eat(value):
	$"../../UI/Chat".addMessage("Debug","You ate something and restored" + str(value) + "hunger")
	print(value)
	for times in value:
		if hunger < 2:
			hunger += 1
		elif life < 4:
			life += 1
	update_HUD()

func update_HUD():
	if life <= 4:
		$"../../UI/Profile/Life".frame = (life+1) * (status+1) -1
		$"../../UI/Profile/Armour".frame = 15
	else:
		$"../../UI/Profile/Armour".frame = (life - 4) * 5
		$"../../UI/Profile/Life".frame = 3
	
	$"../../UI/Profile/Hunger".frame = hunger

func _on_timer_timeout():
	effect(["clear",0,0])
