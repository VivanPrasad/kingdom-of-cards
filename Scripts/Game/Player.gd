extends CharacterBody2D
class_name Player

var emote_menu : PackedScene = preload("res://Scenes/UI/Menu/In-Game/EmoteMenu.tscn")
var inventory_menu : PackedScene = preload("res://Scenes/UI/Menu/In-Game/InventoryMenu.tscn")
var pause_menu : PackedScene = preload("res://Scenes/UI/Menu/In-Game/PauseMenu.tscn")

var market_menu : PackedScene = preload("res://Scenes/UI/Menu/In-Game/MarketMenu.tscn")
var sign_menu : PackedScene = preload("res://Scenes/UI/Menu/In-Game/SignMenu.tscn")

var action_hud : PackedScene = preload("res://Scenes/UI/HUD/ActionHUD.tscn")
var game_over : PackedScene = preload("res://Scenes/UI/HUD/GameOver.tscn")

var player0 = preload("res://Assets/Game/Entities/Player/player0.png")
var player1 = preload("res://Assets/Game/Entities/Player/player1.png")
var player2 = preload("res://Assets/Game/Entities/Player/player2.png")
var player3 = preload("res://Assets/Game/Entities/Player/player3.png")
var player4 = preload("res://Assets/Game/Entities/Player/player4.png")
var player5 = preload("res://Assets/Game/Entities/Player/player5.png")

@export var character : String = "1"

@onready var emote := $Emote
@onready var emote_player := $Emote/EmotePlayer

@onready var world = $".."
@onready var animation_tree : AnimationTree = $AnimationTree
@onready var animation_player : AnimationPlayer = $AnimationPlayer

@onready var icon : TextureRect = $Nametag/HBoxContainer/Icon
@onready var player_name : Label = $Nametag/HBoxContainer/Name
@export var current_menu : String = "None"

@onready var mobile_ui : CanvasLayer = $MobileUI
@onready var profile : CanvasLayer = $Profile
@onready var menu : CanvasLayer = $Menu

@onready var collision : CollisionShape2D = $Collision
@onready var camera : Camera2D = $Camera
@onready var camera_player: AnimationPlayer = $Camera/Camera

@onready var sprite : Sprite2D = $Sprite

@onready var life_ui : Sprite2D = $Profile/Life
@onready var armor_ui : Sprite2D = $Profile/Armor
@onready var hunger_ui : Sprite2D = $Profile/Hunger
@onready var card_amount_ui : Label = $Profile/Cards/Amount

@export var inventory : Array[Card] = [
	Card.new("Rules",82,"There are no rules!",3,"Hold"),
	load("res://Data/Cards/Bread.tres").duplicate(),
	load("res://Data/Cards/Berry.tres").duplicate()
]

@export var life : int = 4
@export var hunger : int = 2
@export var cards : int = 3

@export var enemies : Array[Node] = []
@export var actions : int = 3

@export var on_surface : bool = true
enum STATUS {GOOD,ILL,IMMUNE,UNKNOWN}
@export_enum("Good","Ill","Immune") var status : int

const ROYAL_SPAWN_POSITION : Vector2i = Vector2i(384,-238)
const BASE_CITIZEN_SPEED : int = 100
const BASE_ROYAL_SPEED : int = 80
@export var speed : int = BASE_CITIZEN_SPEED

var input_vector : Vector2 = Vector2.ZERO

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())

func _ready() -> void:
	if str(self.name) == "1":
		icon.show()
	
	if name == &"1":
			character = "0"
	if is_multiplayer_authority():
		if name == &"1":
			character = "0"
			speed = BASE_ROYAL_SPEED
			position = ROYAL_SPAWN_POSITION
			collision.shape.size.x = 30
			collision.position.x = -4
		else:
			character = get_parent().player_character
		Global.player_id = str(self.name)
		player_name.text = get_parent().player_name
		camera.set_enabled(true)
	else:
		mobile_ui.hide()
		menu.hide()
		profile.hide()
	await get_tree().create_timer(0.5).timeout
	set_character(character)
	$"/root/World/HUD/ServerUpdates".player_joined(player_name.text)
	
@rpc("call_local")
func set_character(id):
	sprite.texture = get("player" + id)
	sprite.frame = int(id)

func _physics_process(_delta):
	if on_surface:
		z_index = 0
	else:
		z_index = -3
	
	if not is_multiplayer_authority():
		if on_surface == world.get_node_or_null(Global.player_id).on_surface:
			visible = true
		else:
			visible = false
		return

	input_vector = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
		).normalized() * int(bool(current_menu in ["None","ActionHUD"])) * int(bool(Transition.player.is_playing() == false))
	if mobile_ui.vector != Vector2.ZERO:
		input_vector = mobile_ui.vector
	if input_vector != Vector2.ZERO: #If moving, blend the position based on the input_vector and run!
		animation_tree.set("parameters/Idle/blend_position", input_vector)
		animation_tree.set("parameters/Run/blend_position", input_vector)
		animation_tree.get("parameters/playback").travel("Run")
	else:
		animation_tree.get("parameters/playback").travel("Idle")
	velocity = input_vector * speed
	move_and_slide()
	if len(enemies) > 0:
		if current_menu != "ActionHUD":
			close_menu()
			open_menu(action_hud)
	elif current_menu == "ActionHUD":
		close_menu()

#Menu Handling
func open_menu(menu_,data : String = "") -> void:
	close_menu()
	menu.add_child(menu_.instantiate())
	current_menu = str(menu.get_child(0).name)
	
	if current_menu == "EmoteMenu":
		start_thinking.rpc()
	if current_menu == "SignMenu":
		menu.get_child(0).get_node_or_null("TextureRect/CenterContainer/Label").text = data

func close_menu():
	if current_menu == "EmoteMenu":
		stop_thinking.rpc()
	
	if menu.get_child_count():
		menu.get_child(0).queue_free()
	current_menu = "None"

#Input Handling
func _unhandled_key_input(_event) -> void:
	if not is_multiplayer_authority():	return
	
	if Input.is_action_just_pressed("ui_cancel") and menu.get_child_count() and current_menu not in ["None","ActionHUD"]:
		close_menu()
	elif Input.is_action_just_pressed("pause") and current_menu != "PauseMenu":
		current_menu = "PauseMenu"
		open_menu(pause_menu)
	elif Input.is_action_just_pressed("inventory") and current_menu != "InventoryMenu":
		open_menu(inventory_menu)
	elif Input.is_action_just_pressed("emote") and emote.modulate == Color("ffffff00"):
		open_menu(emote_menu)

#Emotes
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

#Card Functions
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
	set(type,old_value + new_value)
	await get_tree().create_timer(duration).timeout
	set(type, old_value)
	update_profile()

func update_profile():
	if life < 1:
		close_menu()
		get_tree().paused = true
		open_menu(game_over)
	life_ui.frame = life * (status + 1)
	armor_ui.frame = (life-4) * int(life > 4)
	hunger_ui.frame = hunger
	
func _process(_delta):
	card_amount_ui.text = "x" + str(len(inventory))
