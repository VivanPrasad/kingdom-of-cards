extends PanelContainer

@onready var menu = $"../../../../../.."
@onready var world = $"/root/World"

var udp_client := PacketPeerUDP.new()
var udp_server_found = false
var udp_requests = 3
var delta_time = 0.0

var locating = false
@onready var name_label = $MarginContainer/HBoxContainer/VBoxContainer/Label
@onready var icon = $MarginContainer/HBoxContainer/PanelContainer/TextureRect
@onready var player_count = $MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/Label2

@onready var locating_status = $MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/Status/Locating
@onready var online_status = $MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/Status/Online
@onready var unavailable_status = $MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/Status/Unavailable
@onready var offline_status = $MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/Status/Offline
@onready var status_container = $MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/Status
@onready var select_button = $Select
var id : int
 
var ip : String
var server : Server
var status : int = 0
var current_player_count : int
var max_player_count : int = 20

func _ready():
	var sub_port = Config.config_data.port - 1
	if server.server_ip in world.official_servers:
		ip = world.official_servers[server.server_ip]
	else:
		ip = server.server_ip
	name_label.text = server.server_name
	var texture = icon.texture
	icon.texture = texture.duplicate()
	icon.texture.region = Rect2i(5*(server.icon_id%5),5*int(floor(server.icon_id/5.0)),5,5)
	udp_client.set_broadcast_enabled(true)
	udp_client.set_dest_address("255.255.255.255",sub_port)
	#udp_client.connect_to_host(ip, 9999)
	locating = true
	await get_tree().create_timer(1.5).timeout
	locating = false

func _process(delta):
	delta_time += delta
	if delta_time >= 1.5:
		delta_time = 0.2
		if not udp_server_found:
			udp_client.put_packet("Valid_Request".to_ascii_buffer())
			udp_requests -= 1
			if udp_requests == 0:
				pass
	if udp_client.get_available_packet_count() > 0:
		udp_server_found = true
		current_player_count = int(udp_client.get_packet().get_string_from_ascii())
		player_count.text = str(current_player_count) + "/20"
	if locating:
		set_status(0)
	elif udp_server_found:
		set_status(1)
	elif not ip.is_valid_ip_address() and not udp_server_found and ip != "localhost":
		set_status(3)
	else:
		set_status(2)
func server_unavailable():
	set_status(3)
func server_offline():
	set_status(2)
func server_online():
	set_status(1)

func set_status(index : int) -> void:
	status = index
	for child in status_container.get_children():
		if child.get_index() == index:
			child.show()
		else:
			child.hide()
func _on_select_pressed():
	menu.server_selected = id
	
	
func _on_select_focus_entered():
	menu.server_selected = id

func _on_select_gui_input(event):
	if event is InputEventMouseButton and event.double_click and menu.server_selected == id:
		menu.join_button.button_pressed = true
