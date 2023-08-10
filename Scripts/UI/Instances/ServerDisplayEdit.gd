extends Control

@onready var menu = $".."

@onready var server_icon_menu = $ServerIconMenu
@onready var server_name_line = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/LineEdit
@onready var server_ip_line = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer2/LineEdit
@onready var icon_button = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer3/Icon
@onready var icon = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer3/PanelContainer/TextureRect
var server : Server
var selected : int

func _ready():
	selected = menu.server_selected - 1
	if name == &"ServerDisplayEdit":
		server = menu.config_data.server_list[selected]
		server_name_line.text = server.server_name
		server_ip_line.text = server.server_ip
		icon.texture.region = Rect2i(5*(server.icon_id%5),5*int(floor(server.icon_id/5.0)),5,5)
	else:
		server = Server.new()

func _on_icon_pressed():
	$ServerIconMenu.show()
	$ServerIconMenu.get_icon()

func set_icon(icon_id):
	icon.texture.region = Rect2i(5*(icon_id%5),5*int(floor(icon_id/5.0)),5,5)
	server.icon_id = icon_id
func _on_save_pressed():
	server.server_name = server_name_line.text
	server.server_ip = server_ip_line.text
	if name == &"ServerDisplayEdit":
		menu.config_data.server_list[selected].server_name = server_name_line.text
		menu.config_data.server_list[selected].server_ip = server_ip_line.text
		menu.config_data.server_list[selected].icon_id = server.icon_id
	else:
		menu.config_data.server_list.append(server)
	menu.config_data.write_save()
	menu.update_server_list()
	queue_free()

func _on_delete_pressed():
	menu.config_data.server_list.erase(server)
	menu.config_data.write_save()
	menu.update_server_list()
	queue_free()

func _on_cancel_pressed():
	queue_free()

