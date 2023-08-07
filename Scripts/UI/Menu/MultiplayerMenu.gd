extends Control

@onready var host_button = $"VBoxContainer/TabContainer/Host Game/VBoxContainer/Host"
@onready var join_button = $"VBoxContainer/TabContainer/Join Game/VBoxContainer/Join"

@onready var host_ip_line = $"VBoxContainer/TabContainer/Host Game/VBoxContainer/HBoxContainer/HostIP"
@onready var host_port_line = $"VBoxContainer/TabContainer/Host Game/VBoxContainer/HBoxContainer2/Port"
@onready var join_ip_line = $"VBoxContainer/TabContainer/Join Game/VBoxContainer/HBoxContainer/JoinIP"
@onready var join_port_line = $"VBoxContainer/TabContainer/Join Game/VBoxContainer/HBoxContainer2/Port"

@onready var player_name_line = $"VBoxContainer/TabContainer/Settings/HBoxContainer/VBoxContainer/HBoxContainer/Name"

@onready var character_name = $VBoxContainer/TabContainer/Settings/HBoxContainer/HBoxContainer4/Name
@onready var character = $VBoxContainer/TabContainer/Settings/HBoxContainer/HBoxContainer4/Character
@onready var multiplayer_world = $"../.."

var config_data : Resource = ConfigData

func _ready():
	load_config_data()

func load_config_data():
	if ConfigData.save_exists():
		config_data = ConfigData.load_save() as ConfigData
	else:
		config_data = ConfigData.new()
		config_data.write_save()
	player_name_line.text = config_data.player_name
	character.play(config_data.player_character)
	character_name.select(int(config_data.player_character) - 1)

func _physics_process(_delta):
	host_button.disabled = bool(len(host_ip_line.text) == 0 or not host_port_line.text.is_valid_int())
	join_button.disabled = bool(len(join_ip_line.text) == 0 or not join_port_line.text.is_valid_int())
	multiplayer_world.player_name = player_name_line.text
	multiplayer_world.player_character = str(character_name.selected+1)
	config_data.player_name = player_name_line.text
	config_data.player_character = str(character_name.get_selected_id() + 1)
	config_data.write_save()

func _on_back_pressed():
	get_tree().set_pause(false)
	Transition.change_scene("res://Scenes/UI/GameMode.tscn")
	Audio.change_music("title")

func _on_back_mouse_entered():
	pass # Replace with function body.

func _on_back_mouse_exited():
	pass # Replace with function body.

func _on_name_item_selected(id):
	character.play(str(id+1))
