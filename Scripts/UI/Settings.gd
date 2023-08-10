extends Control

var config_data = Config.config_data

@onready var master_slider = $TabContainer/Audio/Container/Master/MasterSlider
@onready var music_slider = $TabContainer/Audio/Container/Music/MusicSlider
@onready var sfx_slider = $TabContainer/Audio/Container/SFX/SFXSlider

@onready var fullscreen_button = $TabContainer/Display/Container/Fullscreen/CheckButton

@onready var local_ip_line = $TabContainer/Online/Container/LocalIP/LineEdit
@onready var public_ip_line = $TabContainer/Online/Container/PublicIP/VBoxContainer/HBoxContainer/LineEdit
@onready var copy_ip_button = $TabContainer/Online/Container/PublicIP/VBoxContainer/CopyIP

@onready var keys_row1 = $TabContainer/Controls/Keys/Row1
@onready var keys_row2 = $TabContainer/Controls/Keys/Row2
@onready var keybind = preload("res://Scenes/UI/Instances/Keybind.tscn")
func _ready() -> void:
	load_config()
	instance_keybinds()
	update_values()
	
	update_online()

func instance_keybinds():
	for key in config_data.keybinds.keys():
		var key_node = keybind.instantiate()
		key_node.key = key
		key_node.value = config_data.keybinds[key]
		if keys_row1.get_child_count() <= 4:
			keys_row1.add_child(key_node)
		else:
			keys_row2.add_child(key_node)

func update_online():
	local_ip_line.text = IP.get_local_addresses()[-1]
	var http = HTTPRequest.new()
	add_child(http)
	http.connect("request_completed", Callable(self, "public_ip"))
	http.request("https://api.ipify.org")

func public_ip(_result, _response_code, _headers, body):
	public_ip_line.text = body.get_string_from_utf8()
	
func load_config() -> void:
	if ConfigData.save_exists():
		config_data = ConfigData.load_save() as ConfigData
	else:
		config_data = Config.config_data

func update_values():
	master_slider.value = config_data.master
	music_slider.value = config_data.music
	sfx_slider.value = config_data.sfx
	
	fullscreen_button.button_pressed = config_data.fullscreen
func _on_tab_container_tab_clicked(tab):
	if tab == 5:
		$AnimationPlayer.play_backwards("FadeIn")
		await $AnimationPlayer.animation_finished
		queue_free()

func _on_master_slider_value_changed(value):
	config_data.master = value
	#AudioServer.set_bus_volume_db(0,((0.8*float(value))-80.0))
	config_data.write_save()

func _on_music_slider_value_changed(value):
	config_data.music = value
	#AudioServer.set_bus_volume_db(1,((0.8*float(value))-80.0))
	config_data.write_save()

func _on_sfx_slider_value_changed(value):
	config_data.sfx = value
	#AudioServer.set_bus_volume_db(2,((0.8*float(value))-80.0))
	config_data.write_save()

func _on_check_button_toggled(button_pressed):
	config_data.fullscreen = button_pressed
	config_data.write_save()

func _on_local_visible_toggled(button_pressed):
	local_ip_line.secret = !button_pressed

func _on_public_visible_toggled(button_pressed):
	public_ip_line.secret = !button_pressed

func _on_copy_ip_pressed():
	DisplayServer.clipboard_set(public_ip_line.text)
	copy_ip_button.text = "Copied to Clipboard"
	copy_ip_button.set_disabled(true)
	await get_tree().create_timer(8.0).timeout
	copy_ip_button.text = "Copy Public IP to Clipboard"
	copy_ip_button.set_disabled(false)

func _on_button_pressed():
	OS.shell_show_in_file_manager(ProjectSettings.globalize_path("user://data"))

func _on_button_2_pressed():
	var dir = DirAccess.open("user://data")
	dir.remove("config.tres")
