extends PanelContainer

#Globals
@onready var menu = $"../../../../../.."
@onready var world = $"/root/World"

#Properties
@onready var icon_rect: TextureRect = $MarginContainer/HBoxContainer/PanelContainer/Icon
@onready var town_name_label: Label = $MarginContainer/HBoxContainer/VBoxContainer/TownName
@onready var player_count_label: Label = $MarginContainer/HBoxContainer/VBoxContainer/PlayerCount
@onready var select_button : Button = $Select

func _ready():
	select_button.pressed.connect(_on_select_pressed)

func _on_select_pressed():
	menu.town_selected = get_index()
	
func _on_select_focus_entered():
	Audio.play_sfx(SFX.SELECT,0.0,-0.3)
	menu.town_selected = get_index()

func _on_select_gui_input(event):
	if event is InputEventMouseButton:
		if event.double_click and menu.town_selected == get_index():
			menu.join_button.button_pressed = true
