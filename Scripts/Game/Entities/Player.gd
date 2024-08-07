extends CharacterBody2D
class_name Player

const emote_menu : PackedScene = preload("res://Scenes/UI/Menu/In-Game/EmoteMenu.tscn")
const inventory_menu : PackedScene = preload("res://Scenes/UI/Menu/In-Game/InventoryMenu.tscn")
const pause_menu : PackedScene = preload("res://Scenes/UI/Menu/In-Game/PauseMenu.tscn")

const market_menu : PackedScene = preload("res://Scenes/UI/Menu/In-Game/MarketMenu.tscn")
const sign_menu : PackedScene = preload("res://Scenes/UI/Menu/In-Game/SignMenu.tscn")

const action_hud : PackedScene = preload("res://Scenes/UI/HUD/ActionHUD.tscn")
const game_over : PackedScene = preload("res://Scenes/UI/HUD/GameOver.tscn")

@export var character : String = "1"

const ROYAL : String = "0"

@onready var emote := $Emote
@onready var emote_player := $Emote/EmotePlayer

@onready var world : Game = $".."
@onready var chat : Chat = $"/root/World/HUD/Chat"
@onready var animation_tree : AnimationTree = $AnimationTree
@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var icon : TextureRect = $Nametag/HBoxContainer/Icon
@onready var player_name : Label = $Nametag/HBoxContainer/Name
@onready var nametag: CenterContainer = $Nametag

@export var current_menu : String = "None"

@onready var mobile_ui : CanvasLayer = $MobileUI
@onready var profile : CanvasLayer = $Profile
@onready var profile_icon: Sprite2D = $Profile/Icon
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
	Card.new_card("Bread"),
	Card.new_card("Berry"),
	Card.new_card("Key")
]

const MAX_LIFE : int = 4
const MAX_HUNGER : int = 2

@export var life : int = MAX_LIFE
@export var hunger : int = MAX_HUNGER
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

var ghost_effect : bool = false
func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())

func _ready() -> void:
	if not Multi.is_online: 
		nametag.hide()
		camera.set_enabled(true)
		inventory.pop_at(0)
		Global.player_id = str(self.name)
		set_character("1")
		return
	
	if name == &"1": # If player is king
		character = "0"
		icon.show()
	
	if is_multiplayer_authority():
		if name == &"1":
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
	set_character(character)
	chat.player_joined(player_name.text)
	
@rpc("call_local")
func set_character(id):
	sprite.texture = load("res://Assets/Game/Entities/Player/player" + id + ".png")
	profile_icon.frame = int(id)

func _physics_process(_delta):
	if on_surface:
		z_index = 0
	else:
		z_index = -3
	
	if Multi.is_online:
		if not is_multiplayer_authority():
			visible = bool(on_surface == world.get_node_or_null(Global.player_id).on_surface)

	input_vector = Input.get_vector(
		"left","right","up","down").normalized()
	if input_vector and current_menu not in ["None","ActionHUD"]:
		close_menu()
	input_vector *= \
		int(bool(current_menu in ["None","ActionHUD"]))*\
		int(bool(not Transition.animation_player.is_playing()))*\
		int(bool(not get_tree().is_paused()))
	
	if ghost_effect:
		if Time.get_ticks_msec() % 10 == 1:
			create_ghost_effect()
			if Multi.is_online:
				create_ghost_effect.rpc()
	if Multi.is_online:
		input_vector *= int(bool(not chat.chat_input.has_focus()))
	if mobile_ui.vector != Vector2.ZERO:
		input_vector = mobile_ui.vector
	if input_vector: #If moving, blend the position based on the input_vector and run!
		animation_tree["parameters/Idle/blend_position"] = input_vector
		animation_tree["parameters/Run/blend_position"] = input_vector
		animation_tree["parameters/playback"].travel("Run")
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

@rpc("call_local")
func create_ghost_effect() -> void:
	var ghost : Sprite2D = sprite.duplicate()
	ghost.modulate.a = 0.3
	ghost.global_position = sprite.global_position
	world.add_child(ghost)
	await create_tween()\
	.tween_property(ghost,"modulate:a",0.0,0.1)\
	.set_trans(Tween.TRANS_CIRC)\
	.finished
	ghost.queue_free()
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
	
	if Input.is_action_just_pressed("back") and menu.get_child_count() and current_menu not in ["None","ActionHUD"]:
		close_menu()
	elif Input.is_action_just_pressed("back") and current_menu != "PauseMenu":
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
func eat(value : int):
	for times in range(value):
		if hunger < 2:
			hunger += 1
		elif life < 4:
			life += 1
	update_profile()

func effect(value : Array):
	var type : String = value[0];
	var old_value : Variant = get(type) #Get the variable value
	var new_value : Variant = value[1]
	var duration : int = value[2]
	
	if value[0] == "speed": ghost_effect = true
	
	if not new_value is String:
		set(type,old_value + new_value)
	await get_tree().create_timer(duration).timeout
	if value[0] == "speed": ghost_effect = false
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
