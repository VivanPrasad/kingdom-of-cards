class_name Save
extends Resource

const SAVE_PATH : String = "user://data/save.tres"
const DATA_FOLDER : String = "user://data"
# Version Control
@export var version : String = "A"

# Audio
@export var audio : Array[int] = [100,100,100] :
	set(value): 
		audio = value
		for bus in [0,1,2]:
			AudioServer.set_bus_volume_db(
				bus,linear_to_db(audio[bus]/100.0))
		changed.emit()

#Controls
@export var input : int = Global.InputMode.MODE.MOUSE_KEYBOARD
@export var keybinds : Dictionary = {
	"up":[KEY_W],
	"left":[KEY_A],
	"down":[KEY_S],
	"right":[KEY_D],
	"inventory":[KEY_E],
	"interact":[KEY_ENTER],
	"back":[KEY_ESCAPE],
	"emote":[KEY_B],
	"chat":[KEY_T],
	"player_list":[KEY_TAB]
}

#Display
@export var fullscreen : bool = false
@export var fps : int = 30 #30,60,90,120,Unlimited
@export var resolution : Vector2i = Vector2i(1440,720)

#Multiplayer
@export var player_name : String = "Guest%s" % randi_range(100,999)
@export var player_character : String = "1"

func write_save() -> void:
	ResourceSaver.save(self,SAVE_PATH)

func update_display() -> void:
	if fullscreen:
		if not DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func update() -> void:
	update_display()

static func save_exists() -> bool:
	return ResourceLoader.exists(SAVE_PATH)
	
static func load_save() -> Resource:
	return ResourceLoader.load(SAVE_PATH)

func _init() -> void:
	changed.connect(_on_changed)

func _on_changed() -> void:
	print("ConfigData.gd::52 _changed() called")
	write_save()
