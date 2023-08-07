extends Control

var config_data = Config.config_data

@onready var master_slider = $TabContainer/Audio/Container/Master/MasterSlider
@onready var music_slider = $TabContainer/Audio/Container/Music/MusicSlider
@onready var sfx_slider = $TabContainer/Audio/Container/SFX/SFXSlider

@onready var fullscreen_button = $TabContainer/Display/Container/Fullscreen/CheckButton
func _ready() -> void:
	load_config()
	update_values()
func load_config() -> void:
	if ConfigData.save_exists():
		config_data = ConfigData.load_save() as ConfigData
	else:
		config_data = ConfigData.new()
		config_data.write_save()

func update_values():
	master_slider.value = config_data.master
	music_slider.value = config_data.music
	sfx_slider.value = config_data.sfx
	
	fullscreen_button.button_pressed = config_data.fullscreen
func _on_tab_container_tab_clicked(tab):
	if tab == 3:
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
