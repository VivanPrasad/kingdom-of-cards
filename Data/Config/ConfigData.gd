class_name ConfigData
extends Resource

const save_path : String = "user://data/config.tres"

#Version Control
@export var version : String = "D2"

@export var master : int = 100
@export var music : int = 100
@export var sfx : int = 100

#controls
@export var keybinds : Dictionary = {
	"ui_left":"",
	"ui_right":"",
	"ui_up":"",
	"ui_down":"",
	"ui_cancel":["ui_right","ui_left","ui_up","ui_down","pause"],
	"inventory":"",
	"emote":"",
	"pause":"",
	"chat":""
}

#Display
@export var fullscreen : bool = false
@export var resolution : Vector2i = Vector2i(1440,720)
@export var quality : int = 0
@export var fps : int = 1 #30,60,90,120,Unlimited

#Multiplayer
@export var player_name : String = "Guest" + str(randi_range(100,999))
@export var player_character : String = "1"

func write_save() -> void:
	ResourceSaver.save(self,save_path)
	Config.update_config()

static func save_exists() -> bool:
	return ResourceLoader.exists(save_path)
	
static func load_save() -> Resource:
	return ResourceLoader.load(save_path)
