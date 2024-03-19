class_name Chat
extends Control

@onready var world : Game = $"/root/World"

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var chat_input: LineEdit = $Panel/MarginContainer/VBoxContainer/ChatInput
@onready var messages: RichTextLabel = $Panel/MarginContainer/VBoxContainer/Messages

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("chat"):
		chat_input.grab_focus()
	
	if chat_input.has_focus() and animation_player.is_playing():
		animation_player.stop()
	
	if not animation_player.is_playing():
		modulate.a = float(int(chat_input.has_focus()))
	
	if not chat_input.has_focus():
		chat_input.text = ""
	
	

func player_joined(id):
	add_town_message(str(id) + " has joined the town")

func player_left(id):
	add_town_message(str(id) + " has left the town")

func add_message(nametag:String, text:String) -> void:
	animation_player.stop()
	animation_player.play("AutoFade")
	messages.append_text("{0}: {1}\n".format([nametag,text]))

@rpc("any_peer")
func send_message(user:String,text:String) -> void:
	add_message(user,text)

func add_town_message(text : String) -> void:
	add_message(get_nametag("Town",Color.MEDIUM_PURPLE),text)

func _on_chat_input_text_submitted(text: String) -> void:
	if (text.count(" ") == len(text)) or text.is_empty():
		chat_input.release_focus()
		return
	send_message(get_nametag(world.player_name),text)
	send_message.rpc(get_nametag(world.player_name),text)
	chat_input.clear()

func get_nametag(nametag:String, color:Color=Color.WHITE):
	return "[color={0}]{1}[/color]".format([color.to_html(),nametag])
