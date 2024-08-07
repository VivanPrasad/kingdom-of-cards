extends Control

@onready var tab_container: TabContainer = $TabContainer

@onready var audio_sliders: VBoxContainer = $TabContainer/Audio/Sliders
@onready var fullscreen_button = $TabContainer/Display/Container/Fullscreen/CheckButton

@onready var keys_row1 = $TabContainer/Controls/VBoxContainer/Keys/Row1
@onready var keys_row2 = $TabContainer/Controls/VBoxContainer/Keys/Row2

@onready var animation_player: AnimationPlayer = $AnimationPlayer

const KEYBIND_SCENE : PackedScene = preload("res://Scenes/UI/Instances/Keybind.tscn")

func _ready() -> void:
	connect_ui()
	instance_keybinds()

func instance_keybinds() -> void:
	var keys : Array = ["up","left","down","right","interact","back","inventory","emote","chat","player_list"]
	for key in keys:
		var key_node = KEYBIND_SCENE.instantiate()
		key_node.key = key
		key_node.value = Config.save.keybinds[key][Config.save.input]
		if keys_row1.get_child_count() <= 5:
			keys_row1.add_child(key_node)
		else:
			keys_row2.add_child(key_node)

func connect_ui() -> void:
	# Tab Buttons
	tab_container.tab_changed.connect(
		_on_tab_switched)
	# Audio Tab
	for box:HBoxContainer in audio_sliders.get_children():
		var slider : HSlider = box.get_child(1)
		var bus : int = box.get_index()
		slider.value_changed.connect(
			_on_audio_update.bind(bus))
		slider.rounded = true
		slider.step = 5
		slider.value = Config.save.audio[bus]
	
	# Display Tab
	fullscreen_button.button_pressed = Config.save.fullscreen
	
	# Data Tab
func close_settings() -> void:
	animation_player.play_backwards("FadeIn")
	Audio.play_sfx(SFX.BACK)
	await animation_player.animation_finished
	$"/root/Title".buttons.get_child(0).grab_focus()
	queue_free()

func _on_tab_switched(tab : int) -> void:
	if tab == 4:
		close_settings()
	else:
		Audio.play_sfx(SFX.SELECT,0.0,1.0)
func _on_audio_update(value : int, bus : int) -> void:
	Config.save.audio[bus] = value

func _on_check_button_toggled(button_pressed):
	Config.save.fullscreen = button_pressed

func _on_button_pressed(button : Button):
	match str(button.name):
		"Open Data Folder":
			OS.shell_show_in_file_manager(
				ProjectSettings.globalize_path(Save.DATA_FOLDER))
		"Delete Save Data":
			if Save.save_exists():
				var dir = DirAccess.open(Save.DATA_FOLDER)
				dir.remove("save.tres")
				Config.load_default()

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_released("tab_left") and tab_container.current_tab > 0:
		tab_container.current_tab = (tab_container.current_tab - 1)
	elif Input.is_action_just_released("tab_right"):
		tab_container.current_tab = (tab_container.current_tab + 1)
	elif Input.is_action_just_pressed("back"):
		close_settings()
