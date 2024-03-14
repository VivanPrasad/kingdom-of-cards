extends PanelContainer

@onready var button = $Button
@onready var icon = $Sprite2D
func _ready():
	icon.frame = get_index()

func _on_button_pressed():
	ServerIconMenu.icon_selected = get_index()
