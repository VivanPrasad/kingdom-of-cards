extends Control

#Servers
@onready var host_button = $TabContainer/Servers/VBoxContainer/HBoxContainer/Host
@onready var join_button = $TabContainer/Servers/VBoxContainer/HBoxContainer/Join

@onready var add_server_button = $TabContainer/Servers/VBoxContainer/HBoxContainer/Add
@onready var edit_server_button = $TabContainer/Servers/VBoxContainer/HBoxContainer/Edit

var server_selected : int = 0

@onready var deselect_server_button = $TabContainer/Servers/VBoxContainer/HBoxContainer/Deselect
@onready var server_list_container = $TabContainer/Servers/VBoxContainer/ScrollContainer/VBoxContainer

const SERVER_DISPLAY = preload("res://Scenes/UI/Instances/ServerDisplay.tscn")
const SERVER_EDIT = preload("res://Scenes/UI/Instances/ServerEdit.tscn")

#Profile
@onready var player_name_line = $TabContainer/Profile/HBoxContainer/VBoxContainer/Name/LineEdit
@onready var character_name = $TabContainer/Profile/HBoxContainer/VBoxContainer/Character/OptionButton
@onready var character_icon = $TabContainer/Profile/HBoxContainer/VBoxContainer/Character/AnimatedSprite2D

#World
@onready var multiplayer_world = $"../.."

var config_data : Resource = ConfigData

@onready var no_servers_label: Label = $TabContainer/Servers/VBoxContainer/ScrollContainer/VBoxContainer/NoServers

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
	var server_list : Array[Server] = config_data.server_list
	var id = 0
	for server: Server in server_list:
		id += 1
		var item = SERVER_DISPLAY.instantiate()
		item.server = server
		item.id = id
		server_list_container.add_child(item)
		
	no_servers_label.visible = bool(len(server_list) == 0)
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
		host_button.disabled = true
		join_button.disabled = false
	else:
		add_server_button.show()
		edit_server_button.hide()
		deselect_server_button.hide()
		host_button.disabled = false
		join_button.disabled = true
		
func _on_back_pressed():
	get_tree().set_pause(false)
	Audio.play_sfx(SFX.BACK,0.0,-0.1)
	Transition.change_scene(Global.Scenes.GAME_MODE_SCENE)
	Audio.change_music(Music.TITLE)

#From profile
func _on_name_item_selected(id):
	character_icon.play(str(id+1))

func _on_clear_pressed():
	Audio.play_sfx(SFX.SELECT,0.0,2.0)
	server_selected = 0

func _on_deselect_pressed():
	Audio.play_sfx(SFX.SELECT,0.0,2.0)
	server_selected = 0

func _on_tab_container_tab_changed(_tab):
	Audio.play_sfx(SFX.SELECT,0.0,2.0)
	server_selected = 0

func _on_edit_pressed():
	Audio.play_sfx(SFX.CONFIRM,0.0,0.2)
	var scene : ServerEdit = SERVER_EDIT.instantiate()
	scene.edit_mode = ServerEdit.MODE.EDIT
	add_child(scene)
	server_selected = 0

func _on_add_pressed():
	Audio.play_sfx(SFX.CONFIRM,0.0,0.2)
	var scene : ServerEdit = SERVER_EDIT.instantiate()
	scene.edit_mode = ServerEdit.MODE.NEW
	add_child(scene)
	server_selected = 0


func _on_refresh_pressed():
	Audio.play_sfx(SFX.CONFIRM,0.0,-0.5)
	update_server_list()
