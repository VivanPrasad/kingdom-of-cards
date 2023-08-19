extends Control

#Servers
@onready var host_button = $TabContainer/Servers/VBoxContainer/HBoxContainer/Host
@onready var join_button = $TabContainer/Servers/VBoxContainer/HBoxContainer/Join
@onready var direct_join_button = $TabContainer/Direct/VBoxContainer/DirectJoin

@onready var add_server_button = $TabContainer/Servers/VBoxContainer/HBoxContainer/Add
@onready var edit_server_button = $TabContainer/Servers/VBoxContainer/HBoxContainer/Edit

var server_selected : int = 0
@onready var deselect_server_button = $TabContainer/Servers/VBoxContainer/HBoxContainer/Deselect
@onready var server_list_container = $TabContainer/Servers/VBoxContainer/ScrollContainer/VBoxContainer

@onready var server_display = preload("res://Scenes/UI/Instances/ServerDisplay.tscn")
@onready var server_display_edit = preload("res://Scenes/UI/Instances/ServerDisplayEdit.tscn")
@onready var server_display_new = preload("res://Scenes/UI/Instances/ServerDisplayNew.tscn")

#Direct
@onready var direct_join_ip_line = $TabContainer/Direct/VBoxContainer/DirectIP/LineEdit

#Profile
@onready var player_name_line = $TabContainer/Profile/HBoxContainer/VBoxContainer/Name/LineEdit
@onready var character_name = $TabContainer/Profile/HBoxContainer/VBoxContainer/Character/OptionButton
@onready var character_icon = $TabContainer/Profile/HBoxContainer/VBoxContainer/Character/AnimatedSprite2D

#World
@onready var multiplayer_world = $"../.."

var config_data : Resource = ConfigData

func _ready():
	load_config_data()
	update_server_list()
	if Audio.get_node_or_null("SFX/light_rain") != null:
		Audio.stop_sfx("light_rain")

func load_config_data():
	if ConfigData.save_exists():
		config_data = ConfigData.load_save() as ConfigData
	else:
		config_data = ConfigData.new()
		config_data.write_save()
	
	player_name_line.text = config_data.player_name
	character_icon.play(config_data.player_character)
	character_name.select(int(config_data.player_character) - 1)

func update_server_list():
	for child in server_list_container.get_children():
		if not child is Label: child.queue_free()
	var server_list = config_data.server_list
	var i = 0
	for server in server_list:
		i += 1
		var item = server_display.instantiate()
		item.server = server
		item.id = i
		server_list_container.add_child(item)
	if len(server_list) == 0:
		$TabContainer/Servers/VBoxContainer/ScrollContainer/VBoxContainer/Label.show()
	else:
		$TabContainer/Servers/VBoxContainer/ScrollContainer/VBoxContainer/Label.hide()
	load_config_data()
func _physics_process(_delta):
	if multiplayer_world != null:
		multiplayer_world.player_name = player_name_line.text
		multiplayer_world.player_character = str(character_name.selected+1)
		config_data.player_name = player_name_line.text
		config_data.player_character = str(character_name.get_selected_id() + 1)
		config_data.write_save()
	if server_selected != 0:
		add_server_button.hide()
		edit_server_button.show()
		deselect_server_button.show()
		join_button.disabled = false
	else:
		add_server_button.show()
		edit_server_button.hide()
		deselect_server_button.hide()
		join_button.disabled = true
	if direct_join_ip_line.text.is_valid_ip_address() or direct_join_ip_line.text == "localhost" or direct_join_ip_line.text in multiplayer_world.official_servers:
		direct_join_button.disabled = true
	else:
		direct_join_button.disabled = false
		
func _on_back_pressed():
	get_tree().set_pause(false)
	Transition.change_scene("res://Scenes/UI/GameMode.tscn")
	Audio.change_music("title")

#From profile
func _on_name_item_selected(id):
	character_icon.play(str(id+1))


func _on_clear_pressed():
	server_selected = 0


func _on_deselect_pressed():
	server_selected = 0

func _on_tab_container_tab_changed(_tab):
	server_selected = 0


func _on_edit_pressed():
	add_child(server_display_edit.instantiate())
	server_selected = 0

func _on_add_pressed():
	add_child(server_display_new.instantiate())
	server_selected = 0


func _on_refresh_pressed():
	update_server_list()
