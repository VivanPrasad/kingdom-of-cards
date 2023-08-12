extends Node

const save_path = "user://config.tres"

var config_data = ConfigData
func _ready():
	var dir = DirAccess.open("user://")
	if not dir.file_exists("data"):
		dir.make_dir("data")
	load_config_data()

func load_config_data():
	if ConfigData.save_exists():
		config_data = ConfigData.load_save() as ConfigData
	else:
		config_data = ConfigData.new()
		config_data.write_save()
		load_config_data()
	update_config()

func update_config():
	AudioServer.set_bus_volume_db(0,linear_to_db(config_data.master/100.0))
	AudioServer.set_bus_volume_db(1,linear_to_db(config_data.music/100.0))
	AudioServer.set_bus_volume_db(2,linear_to_db(config_data.sfx/100.0))
	if config_data.fullscreen:
		if not DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
