extends PanelContainer

@onready var icon_menu = $"../../../../.."
func _ready():
	$Sprite2D.frame = get_index()

func _on_button_pressed():
	icon_menu.icon_selected = get_index()
