extends HBoxContainer

@export var key : String
@export var value : Key

func _ready():
	$Key.text = key.split("_")[-1].capitalize()
	$Value.text = OS.get_keycode_string(value)

func _input(event):
	if event is InputEventKey:
		if $Value.text == "<>":
			value = event.keycode
			$Value.text = OS.get_keycode_string(value)
	if event is InputEventMouseButton:
		$Value.text = OS.get_keycode_string(value)
func _on_value_pressed():
	$Value.text = "<>"
