## Config
extends Node

var save : Save

func _ready():
	var dir = DirAccess.open("user://")
	if not dir.file_exists("data"):
		dir.make_dir("data")
	load_save()

func load_save():
	if Save.save_exists():
		save = Save.load_save() as Save
		if not is_compatible():
			load_default()
		save.update()
	else:
		load_default()

func load_default() -> void:
	save = Save.new()
	save.write_save()
	load_save()
## Verifies if the config data loaded is compatible
func is_compatible() -> bool:
	return true

'''
	if get_node_or_null("/root/Title/") != null:
		var value : int
		for input_name in config_data.keybinds.keys():
			value = config_data.keybinds[input_name][config_data.input_mode]
			if InputMap.has_action(input_name):
				InputMap.action_erase_events(input_name)
				InputMap.erase_action(input_name)
				prints("Config.gd :: Removed action:",input_name)
			InputMap.add_action(input_name)
			prints("Config.gd :: Added action:",input_name)
			var event = InputEventKey.new()
			event.keycode = value
			Input.parse_input_event(event)
			InputMap.action_add_event(input_name,event)
			prints("Config.gd :: Added event to action:",event.keycode)
	'''
