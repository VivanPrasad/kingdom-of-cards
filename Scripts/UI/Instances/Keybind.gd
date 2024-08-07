extends HBoxContainer

@export var key : String
@export var value : Key

@onready var key_label: Label = $Key
@onready var value_label: Button = $Value
@onready var icon: Sprite2D = $Icon

const CONTROLLER_ICON : Dictionary = {
	"up":8,
	"left":9,
	"down":10,
	"right":11,
	"inventory":2,
	"interact":0,
	"back":1,
	"emote":6,
	"chat":15,
	"player_list":12
}

func _ready():
	icon.frame = CONTROLLER_ICON[key] + 17
	key_label.text = key.split("_")[-1].capitalize()
	value_label.text = OS.get_keycode_string(value)
	value_label.text = ""

func _on_value_pressed():
	$Value.text = "<>"
