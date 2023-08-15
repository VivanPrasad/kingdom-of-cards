extends CharacterBody2D

const base_speed = 100
enum state {good,sick,potion,unknown}

@onready var emote_menu : PackedScene = preload("res://Scenes/UI/Menu/In-Game/EmoteMenu.tscn")
@onready var inventory_menu : PackedScene = preload("res://Scenes/UI/Menu/In-Game/InventoryMenu.tscn")
@onready var pause_menu : PackedScene = preload("res://Scenes/UI/Menu/In-Game/PauseMenu.tscn")
@onready var market_menu : PackedScene = preload("res://Scenes/UI/Menu/In-Game/MarketMenu.tscn")
@onready var action_hud := preload("res://Scenes/UI/HUD/ActionHUD.tscn")
@onready var game_over := preload("res://Scenes/UI/HUD/GameOver.tscn")

@onready var emote_player = $Emotes/EmotePlayer
@onready var emote = $Emotes
var on_surface : bool = true #layer 1 = surface, layer 0 = dungeon

var actions = 3 #number of action cards during combat
#+1 if holding the ring 
#+1 if the guard role?

var status : int = state.good
var life : int = 4 #heart
var hunger : int = 2 #food
var speed : int = base_speed #starts at base speed

var in_combat : bool = false
var enemies : Array[CharacterBody2D] = []
var targeted : bool = false
var effect_queue : Array

var current_menu : String = "None"
@onready var world = $"../.."
var inventory = [load("res://Data/Cards/Bread.tres").duplicate(),load("res://Data/Cards/Bread.tres").duplicate(),load("res://Data/Cards/Berry.tres").duplicate()]
func _ready():
	Global.player_id = "Entities/Player"
	velocity = Vector2.ZERO
	$Sprite2D.texture = load(str("res://Assets/Game/Entities/Player/player" + str(randi() % 4 + 1)+".png"))
	update_HUD()
	$Camera2D.enabled = true

func _process(_delta):
	if on_surface:
		z_index = 0
	else:
		z_index = -3
	check_combat() #0 = menu.none
	if in_combat:
		if current_menu != "ActionHUD":
				close_menu()
				open_menu(action_hud)
	else:
		if current_menu == "ActionHUD":
			close_menu()
	var input_vector = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
		).normalized() * int(current_menu in ["None","ActionHUD"])
	if $MobileUI.vector != Vector2.ZERO:
		input_vector = $MobileUI.vector
	if input_vector != Vector2.ZERO: #If moving, blend the position based on the input_vector and run!
		$AnimationTree.set("parameters/Idle/blend_position", input_vector)
		$AnimationTree.set("parameters/Run/blend_position", input_vector)
		$AnimationTree.get("parameters/playback").travel("Run")
	else:
		$AnimationTree.get("parameters/playback").travel("Idle")
	velocity = input_vector * speed
	move_and_slide()
	
func effect(data): #data = [type, value, time (s)] #if data[0]
	var type = data[0]; var value = data[1]; var time = data[2]
	if type == "speed":
		speed = value + 10
		await get_tree().create_timer(time).timeout
		speed = base_speed
	elif type == "immune":
		var previous_state = status
		status = state.potion
		update_HUD()
		await get_tree().create_timer(time).timeout
		status = previous_state
		update_HUD()
func eat(value):
	print(value)
	for times in value:
		if hunger < 2:
			hunger += 1
		elif life < 4:
			life += 1
			in_combat = false
			world.current_menu = 4
	update_HUD()

func hurt():
	if life > 1:
		$Hurt.play("Hurt")
		life -= 1
		update_HUD()
	else:
		life -=1
		update_HUD()
		visible = false
		close_menu()
		open_menu(game_over)
		get_tree().paused = true
		
func update_HUD():
	if life <= 4:
		$"Profile/Life".frame = (life+1) * (status+1) -1
		$"Profile/Armor".frame = 0
	else:
		$"Profile/Armor".frame = (life - 4)
		$"Profile/Life".frame = 3
	
	$"Profile/Hunger".frame = hunger

func _on_timer_timeout():
	effect(["clear",0,0])

func check_combat():
	if len(enemies): #if there are enemies, it returns true
		in_combat = true
	else:
		in_combat = false

func open_menu(menu : PackedScene) -> void:
	close_menu()
	$Menu.add_child(menu.instantiate())
	current_menu = str($Menu.get_child(0).name)
	
	if current_menu == "EmoteMenu":
		start_thinking()

func close_menu():
	if $Menu.get_child_count() > 0:
		$Menu.get_child(0).queue_free()
	current_menu = "None"
	if current_menu == "EmoteMenu":
		stop_thinking()
	
func start_thinking():
	emote_player.play("Popup")
	await emote_player.animation_finished
	emote_player.play("Thinking")

func stop_thinking():
	emote_player.play_backwards("Popup")

func play_emote(emote_id : int):
	if $Menu.get_child_count():
		$Menu.get_child(0).queue_free()
	current_menu = "None"
	emote_player.stop()
	emote.frame = emote_id
	current_menu = "None"
	emote.show()
	await get_tree().create_timer(3.0).timeout
	emote_player.play_backwards("Popup")

func _input(_event) -> void:
	if Input.is_action_just_pressed("ui_cancel") and $Menu.get_child_count() and not current_menu in ["None","ActionHUD"]:
		close_menu()
	elif Input.is_action_just_pressed("pause") and current_menu != "PauseMenu":
		current_menu = "PauseMenu"
		open_menu(pause_menu)
	elif Input.is_action_just_pressed("inventory") and current_menu != "InventoryMenu":
		open_menu(inventory_menu)
	elif Input.is_action_just_pressed("emote") and emote.modulate == Color("ffffff00"):
		open_menu(emote_menu)
