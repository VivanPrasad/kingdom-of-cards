extends Node

var player_id : String = "none"

class Scenes:
	const TITLE_PATH : String = "res://Scenes/UI/Title.tscn"
	const GAME_MODE_PATH : String = "res://Scenes/UI/GameMode.tscn"
	
	const WORLD_SCENE : String = "res://Scenes/Game/World.tscn"
	const SETTINGS_SCENE : PackedScene = preload("res://Scenes/UI/Settings.tscn")

class UI:
	enum ICON {DEFAULT=8}
	enum CARD {DEFAULT=83}
	enum EMOTE {DEFAULT=12}

class InputMode:
	enum MODE {MOUSE_KEYBOARD=0,TOUCH=1,CONTROLLER=2,KEYBOARD=3}
	var input = MODE.MOUSE_KEYBOARD
