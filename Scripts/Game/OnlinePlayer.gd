extends CharacterBody2D

@onready var emote_menu : PackedScene = preload("res://Scenes/UI/Menu/In-Game/EmoteMenu.tscn")
@onready var inventory_menu : PackedScene = preload("res://Scenes/UI/Menu/In-Game/InventoryMenu.tscn")
@onready var pause_menu : PackedScene = preload("res://Scenes/UI/Menu/In-Game/PauseMenu.tscn")
@onready var market_menu : PackedScene = preload("res://Scenes/UI/Menu/In-Game/MarketMenu.tscn")

@onready var player1 = preload("res://Assets/Game/Entities/Player/player1.png")
@onready var player2 = preload("res://Assets/Game/Entities/Player/player2.png")
@onready var player3 = preload("res://Assets/Game/Entities/Player/player3.png")
@onready var player4 = preload("res://Assets/Game/Entities/Player/player4.png")
@onready var player5 = preload("res://Assets/Game/Entities/Player/player5.png")

@export var character : String

@onready var emote := $Emotes
@onready var emote_player := $Emotes/EmotePlayer

@onready var animation_tree := $AnimationTree
@onready var animation_player := $AnimationPlayer

@export var current_menu : String = "None"

@export var inventory : Array[Card] = [Card.new("Rules",82,"There are no rules!",3,"Hold"),load("res://Data/Cards/Bread.tres").duplicate(),load("res://Data/Cards/Berry.tres").duplicate()]
@export var life : int = 4
@export var hunger : int = 2

@export_enum("Good","Ill","Immune") var status : int

const base_speed = 100
@export var speed = base_speed

var input_vector : Vector2 = Vector2.ZERO
func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())

func _ready() -> void:
	if str(self.name) == "1":
		$Nametag/HBoxContainer/Icon.visible = true
	if is_multiplayer_authority():
		character = $"..".player_character
		Global.player_id = str(self.name)
		$Camera.enabled = true
		$Nametag/HBoxContainer/Name.text = get_parent().player_name
		set_character.rpc(character)
	else:
		set_character(character)
@rpc("call_local")
func set_character(id):
	$Sprite.texture = get("player" + id)
func _physics_process(_delta):
	if not is_multiplayer_authority(): return
	input_vector = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
		).normalized() * int(bool(current_menu == "None"))
	if $MobileUI.vector != Vector2.ZERO:
		input_vector = $MobileUI.vector
	if input_vector != Vector2.ZERO: #If moving, blend the position based on the input_vector and run!
		animation_tree.set("parameters/Idle/blend_position", input_vector)
		animation_tree.set("parameters/Run/blend_position", input_vector)
		animation_tree.get("parameters/playback").travel("Run")
	else:
		animation_tree.get("parameters/playback").travel("Idle")
		
	velocity = input_vector * speed
	move_and_slide()

#Menu Handling
func open_menu(menu : PackedScene) -> void:
	close_menu()
	$Menu.add_child(menu.instantiate())
	current_menu = str($Menu.get_child(0).name)
	
	if current_menu == "EmoteMenu":
		start_thinking.rpc()

func close_menu():
	if current_menu == "EmoteMenu":
		stop_thinking.rpc()
	
	if $Menu.get_child_count():
		$Menu.get_child(0).queue_free()
	current_menu = "None"

func _unhandled_key_input(_event) -> void:
	if not is_multiplayer_authority():	return
	
	if Input.is_action_just_pressed("ui_cancel") and $Menu.get_child_count():
		close_menu()
	elif Input.is_action_just_pressed("pause") and current_menu != "PauseMenu":
		current_menu = "PauseMenu"
		open_menu(pause_menu)
	elif Input.is_action_just_pressed("inventory") and current_menu != "InventoryMenu":
		open_menu(inventory_menu)
	elif Input.is_action_just_pressed("emote") and emote.modulate == Color("ffffff00"):
		open_menu(emote_menu)

@rpc("call_local")
func start_thinking():
	emote_player.play("Popup")
	await emote_player.animation_finished
	emote_player.play("Thinking")

@rpc("call_local")
func stop_thinking():
	emote_player.play_backwards("Popup")

@rpc("call_local")
func play_emote(emote_id : int):
	emote_player.stop()
	emote.frame = emote_id
	current_menu = "None"
	emote.show()
	await get_tree().create_timer(3.0).timeout
	emote_player.play_backwards("Popup")

func eat(value):
	for times in value:
		if hunger < 2:
			hunger += 1
		elif life < 4:
			life += 1
	update_profile()

func effect(value):
	var type = value[0]; var new_value = value[1]; var duration = value[2]
	var old_value = get(type)
	set(type,new_value)
	await get_tree().create_timer(duration).timeout
	set(type, old_value)
	update_profile()

func update_profile():
	$Profile/Life.frame = life * (status + 1)
	$Profile/Armor.frame = (life-4) * int(life > 4)
	$Profile/Hunger.frame = hunger
