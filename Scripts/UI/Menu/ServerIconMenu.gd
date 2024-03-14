extends Control
class_name ServerIconMenu
@onready var server_display_menu = $".."
@onready var grid = $PanelContainer/MarginContainer/VBoxContainer/GridContainer
@onready var icon_display = preload("res://Scenes/UI/Instances/ServerIconDisplay.tscn")

static var icon_selected : int

func _ready():
	for i in range(20):
		var icon = icon_display.instantiate()
		grid.add_child(icon)
		
func get_icon():
	for child in grid.get_children():
			if server_display_menu.server.icon_id == child.get_index():
				child.get_child(0).grab_focus()
				icon_selected = child.get_child(1).frame

func _on_use_pressed():
	server_display_menu.set_icon(icon_selected)
	hide()


func _on_cancel_pressed():
	hide()
