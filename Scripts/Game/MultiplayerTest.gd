extends Node2D

const port : int = 9998
var ip : String

const official_servers = {"kingdom.cards":"23.16.130.237","cards":"23.16.130.237","bamboo":"23.16.130.237","whispering.kingdom":"94.70.115.110"}

var peer = ENetMultiplayerPeer.new()
var udp = UDPServer.new()

@export var player_scene : PackedScene = preload("res://Scenes/Game/Entities/OnlinePlayer.tscn")

var player_name : String
var player_character : String

@onready var multiplayer_menu := $Lobby/MultiplayerMenu
@onready var host_button := $Lobby/MultiplayerMenu/TabContainer/Servers/VBoxContainer/HBoxContainer/Host
@onready var join_button := $Lobby/MultiplayerMenu/TabContainer/Servers/VBoxContainer/HBoxContainer/Join
@onready var direct_join_button := $Lobby/MultiplayerMenu/TabContainer/Direct/VBoxContainer/DirectJoin


###
@onready var time_cycle := $Shader/TimeCycle
@onready var time := $HUD/Time
@onready var server_updates := $HUD/ServerUpdates
@onready var connection_menu = $HUD/ConnectionMenu

@onready var light : PackedScene = preload("res://Scenes/Game/Objects/Light.tscn")

var lights = [] #all node instances of all lights
var lights_pos = [] #positions of all lights
var lights_on : bool = true

var market_locations = {}

func _ready():
	$HUD.hide(); $Lobby.show()
	host_button.connect("pressed",Callable(self,"_on_host_pressed"))
	join_button.connect("pressed",Callable(self,"_on_join_pressed"))
	direct_join_button.connect("pressed",Callable(self,"_on_direct_join_pressed"))
	get_tree().paused = true

func _on_host_pressed():
	peer.create_server(port)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_add_player)
	multiplayer.peer_disconnected.connect(remove_player)
	_add_player()
	create_udp_server()
	upnp_setup()
	transition_to_world("castle")
func _add_player(id = 1):
	var player = player_scene.instantiate()
	player.name = str(id)
	add_child(player)

func remove_player(peer_id):
	var player = get_node_or_null(str(peer_id))
	server_updates.player_left(player)
	remove_child(player)
	player.free()

func _on_direct_join_pressed():
	pass
	
func _on_join_pressed():
	var server_ip = Config.config_data.server_list[multiplayer_menu.server_selected-1].server_ip
	if server_ip in official_servers:
		ip = official_servers[server_ip]
	else:
		ip = server_ip
	peer.create_client(ip,port)
	multiplayer.multiplayer_peer = peer
	transition_to_world("day")

func transition_to_world(music):
	Transition.fade_in(0.8)
	await Transition.player.animation_finished
	get_tree().set_pause(false)
	multiplayer_menu.queue_free()
	instance_lights()
	$HUD.show()
	Transition.fade_out(0.8)
	Audio.change_music(music)
	
func _physics_process(_delta):
	if time_cycle.is_playing():
		time_cycle.seek(time.second / 3600.0,false)
	else:
		time_cycle.play("Cycle")

func instance_lights():
	var cell_data
	for i in $Dungeon.get_layers_count():
		$Dungeon.set_layer_enabled(i, true)
		#checks how many layers are there in the dungeon, and enables each of them
	for layer in [$Surface,$Dungeon]:
		for cell in layer.get_used_cells(2): #all the cells in decoration layer
			cell_data = layer.get_cell_tile_data(2, cell) #get the TileData of the cell
			if cell_data != null and cell_data.modulate != Color(1.0,1.0,1.0,1.0): #the lights do not have white modulate
				#layer.set_cell(2,)
				lights_pos.append(cell)
				var instance = light.instantiate()
				instance.position = cell * 8 #position on grid is 8x scale
				instance.on_surface = bool(layer == $Surface) #surface = 0, dungeon = 1
				layer.add_child(instance,true)
	for child in $Surface.get_children() + $Dungeon.get_children():
		if str(child.name).contains("Light"): lights.append(child) #Adds the light node paths to the 
	for i in $Dungeon.get_layers_count(): $Dungeon.set_layer_enabled(i, false)

func get_market_locations():
	for child in $Surface.get_children():
		print(child.name)
		if str(child.name) in ["FoodMarket","BankDesk","ItemMarket"]: #THERE CAN ONLY BE ONE MARKET INSTANCE FOR EACH!!!!
			market_locations[str(child.name)] = child.position

func _on_multiplayer_spawner_spawned(_node):
	pass

func _on_multiplayer_spawner_despawned(_node):
	pass

func show_connection_error():
	pass

func upnp_setup():
	var upnp = UPNP.new()
	
	upnp.discover()
	upnp.add_port_mapping(9999)
	upnp.add_port_mapping(9998)
	
func create_udp_server():
	udp.listen(9999,"0.0.0.0")

func _process(_delta):
	udp.poll()
	if udp.is_connection_available():
		var udp_peer : PacketPeerUDP = udp.take_connection()
		var packet = udp_peer.get_packet()
		print("Recieved : %s from %s:%s" %
		[
			packet.get_string_from_ascii(),
			udp_peer.get_packet_ip(),
			udp_peer.get_packet_port(),
		])
		var players : int = 0
		for child in get_children():
			if child is CharacterBody2D:
				players += 1
		udp_peer.put_packet(str(players).to_ascii_buffer())
