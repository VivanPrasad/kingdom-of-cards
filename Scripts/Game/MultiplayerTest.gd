extends Node2D

var port : int = 9999

var ip : String

const official_servers = {"kingdom.cards":"23.16.130.237"}

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
@onready var player_list := $HUD/PlayerList
@onready var connection_menu = $HUD/ConnectionMenu

@onready var light : PackedScene = preload("res://Scenes/Game/Objects/Light.tscn")

var lights = [] #all node instances of all lights
var lights_pos = [] #positions of all lights
var lights_on : bool = true

func _ready():
	port = Config.config_data.port
	$HUD.hide(); $Lobby.show()
	host_button.connect("pressed",Callable(self,"_on_host_pressed"))
	join_button.connect("pressed",Callable(self,"_on_join_pressed"))
	direct_join_button.connect("pressed",Callable(self,"_on_direct_join_pressed"))
	$Stair.connect("body_entered",Callable(self,"descend"))
	get_tree().paused = true

func _on_host_pressed():
	var setup = await setup_server()
	if not setup:	return
	peer.create_server(port)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_add_player)
	multiplayer.peer_disconnected.connect(remove_player)
	_add_player()
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
	transition_to_world("day")
	var server_ip = multiplayer_menu.direct_join_ip_line.text
	if server_ip in official_servers:
		ip = official_servers[server_ip]
	else:
		ip = server_ip
	peer.create_client(ip,port)
	multiplayer.multiplayer_peer = peer
	
func _on_join_pressed():
	transition_to_world("day")
	var server_ip = Config.config_data.server_list[multiplayer_menu.server_selected-1].server_ip
	if server_ip in official_servers:
		ip = official_servers[server_ip]
	else:
		ip = server_ip
	peer.create_client(ip,port)
	multiplayer.multiplayer_peer = peer
	
func transition_to_world(music):
	if music == "day":
		Transition.fade_in(0.8)
		await Transition.player.animation_finished
	get_tree().set_pause(false)
	multiplayer_menu.queue_free()
	instance_lights()
	$HUD.show()
	Audio.change_music(music)
	Transition.fade_out(0.8)

func _physics_process(_delta):
	var local_player = get_node_or_null(Global.player_id)
	var on_surface : bool = true
	if local_player != null:
		on_surface = local_player.on_surface
	
	if time_cycle.is_playing():
		if on_surface:
			time_cycle.seek(time.second / 3600.0,false)
		else:
			time_cycle.seek(4.0,false)
	else:
		time_cycle.play("Cycle")
func instance_lights():
	var cell_data
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

func descend(body):
	if body is CharacterBody2D and body.is_multiplayer_authority():
		if body.on_surface:
			Transition.fade_in(1.5)
			await Transition.player.animation_finished
			body.on_surface = false
			$Surface.tile_set.set_physics_layer_collision_layer(0,0)
			$Surface.hide()
			$Dungeon.tile_set.set_physics_layer_collision_layer(0,2)
			$Stair.scale = Vector2(-1,-1)
			Transition.fade_out(1.5)
			Audio.change_music("dungeon")
		else:
			Transition.fade_in(1.5)
			await Transition.player.animation_finished
			body.on_surface = true
			$Surface.tile_set.set_physics_layer_collision_layer(0,2)
			$Surface.show()
			$Dungeon.tile_set.set_physics_layer_collision_layer(0,0)
			$Stair.scale = Vector2(1,1)
			Transition.fade_out(1.5)
			if player_character == "0":
				Audio.change_music("castle")
			else:
				Audio.change_music("day")

func _on_multiplayer_spawner_spawned(node):
	await get_tree().create_timer(0.5).timeout
	server_updates.player_joined(node)

func _on_multiplayer_spawner_despawned(node):
	await get_tree().create_timer(0.5).timeout
	server_updates.player_left(node)

func show_connection_error():
	pass

func setup_server() -> bool:
	Transition.fade_in()
	await Transition.player.animation_finished
	udp.listen(port - 1,IP.get_local_addresses()[-1])
	var upnp = UPNP.new()
	
	upnp.discover()
	if upnp.discover() == 0:
		print("UPnP is Enabled, finding ports")
	else:
		Transition.change_scene("res://Scenes/Game/OnlineWorld.tscn")
		return false
	upnp.add_port_mapping(port)
	upnp.add_port_mapping(port - 1)
	return true

func _process(_delta):
	udp.poll()
	if udp.is_connection_available():
		var udp_peer : PacketPeerUDP = udp.take_connection()
		var packet = udp_peer.get_packet()
		print("Recieved Packet: %s from %s:%s" %
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
