class_name ConfigData
extends Resource

const save_path : String = "user://data/config.tres"

#Version Control
@export var version : String = "D2"

@export var master : int = 100
@export var music : int = 100
@export var sfx : int = 100

#Controls
@export var keybinds : Dictionary = {
	"ui_up":KEY_W,
	"ui_left":KEY_A,
	"ui_down":KEY_S,
	"ui_right":KEY_D,
	"inventory":KEY_E,
	"emote":KEY_B,
	"chat":KEY_T,
	"player_list":KEY_TAB,
	"pause":KEY_ESCAPE
}

#Display
@export var fullscreen : bool = false
@export var resolution : Vector2i = Vector2i(1440,720)
@export var quality : int = 0
@export var fps : int = 1 #30,60,90,120,Unlimited

#Multiplayer
@export var server_list : Array[Server] = [load("res://Data/Config/OfficialServer.tres")]
@export var port : int = 9999
@export var player_name : String = "Guest" + str(randi_range(100,999))
@export var player_character : String = "1"

func write_save() -> void:
	ResourceSaver.save(self,save_path)
	Config.update_config()

static func save_exists() -> bool:
	if ResourceLoader.load(save_path) != null:
		return ResourceLoader.exists(save_path)
	else:
		return false
	
static func load_save() -> Resource:
	return ResourceLoader.load(save_path)
