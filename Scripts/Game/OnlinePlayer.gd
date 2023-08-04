extends CharacterBody2D

@onready var emote_menu := preload("res://Scenes/UI/Menu/In-Game/EmoteMenu.tscn")

@onready var emote := $Emotes
@onready var emote_player := $Emotes/EmotePlayer

class ello:
	func _init(hi):
		self.hi = hi
	
@onready var animation_tree := $AnimationTree
@onready var animation_player := $AnimationPlayer

@onready var name_label = $Nametag/HBoxContainer/Name
@onready var name_icon = $Nametag/HBoxContainer/Icon

@onready var player_id : String = str(self.name)

@onready var UI := $UI
const max_life : int = 4

var life : int = 4
var armor : int = 0

var hunger : int = 2

const base_speed = 100
var speed = base_speed

func _enter_tree():
	set_multiplayer_authority(name.to_int())

func _ready():
	if player_id == "1":
		name_icon.visible = true
	if is_multiplayer_authority():
		$Camera.enabled = true
		name_label.text = get_parent().player_name

func _physics_process(_delta):
	if not is_multiplayer_authority(): return
	
	var input_vector = Vector2(
			Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
			Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
			).normalized()
	if len(UI.get_children()):
		input_vector = Vector2.ZERO
	if input_vector != Vector2.ZERO: #If moving, blend the position based on the input_vector and run!
		$AnimationTree.set("parameters/Idle/blend_position", input_vector)
		$AnimationTree.set("parameters/Run/blend_position", input_vector)
		$AnimationTree.get("parameters/playback").travel("Run")
	else:
		$AnimationTree.get("parameters/playback").travel("Idle")
		
	velocity = input_vector * speed
	move_and_slide()
	
	if not is_multiplayer_authority():	return
func _input(_event):
	if not is_multiplayer_authority():	return
	if Input.is_action_just_released("emote"):
		if not get_node_or_null("UI/EmoteMenu"):
			if emote.modulate == Color("ffffff00"):
				UI.add_child(emote_menu.instantiate())
				start_thinking.rpc()

@rpc("call_local")
func start_thinking():
	emote_player.play("Popup")
	await emote_player.animation_finished
	emote_player.play("Thinking")

@rpc("call_local")
func stop_thinking():
	emote_player.play_backwards("Popup")

@rpc("call_local")
func play_emote(emote_id):
	emote_player.stop()
	emote.frame = emote_id
	emote.show()
	await get_tree().create_timer(3.0).timeout
	emote_player.play_backwards("Popup")
