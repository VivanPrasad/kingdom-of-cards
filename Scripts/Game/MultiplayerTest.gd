extends Node2D

var port : int
var ip : String

var peer = ENetMultiplayerPeer.new()

@export var connection_menu : PackedScene = preload("res://Scenes/UI/Menu/ConnectionMenu.tscn")
@export var player_scene : PackedScene = preload("res://Scenes/Game/Entities/OnlinePlayer.tscn")

var player_name : String
var player_character : String

@onready var host_button := $"Lobby/MultiplayerMenu/VBoxContainer/TabContainer/Host Game/VBoxContainer/Host"
@onready var join_button := $"Lobby/MultiplayerMenu/VBoxContainer/TabContainer/Join Game/VBoxContainer/Join"

@onready var multiplayer_menu := $Lobby/MultiplayerMenu

###
@onready var time_cycle := $Shader/TimeCycle
@onready var time := $HUD/Time
@onready var server_updates := $HUD/ServerUpdates

@onready var light : PackedScene = preload("res://Scenes/Game/Objects/Light.tscn")

var lights = [] #all node instances of all lights
var lights_pos = [] #positions of all lights
var lights_on : bool = true

var market_locations = {}

func _ready():
	$HUD.hide(); $Lobby.show()
	host_button.connect("pressed",Callable(self,"_on_host_pressed"))
	join_button.connect("pressed",Callable(self,"_on_join_pressed"))
	get_tree().set_pause(true)

func _on_host_pressed():
	ip = multiplayer_menu.host_ip_line.text
	port = int(multiplayer_menu.host_port_line.text)
	#peer.set_bind_ip(ip)
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
	if player:	player.queue_free()

func _on_join_pressed():
	ip = multiplayer_menu.join_ip_line.text
	port = int(multiplayer_menu.join_port_line.text)
	peer.create_client(ip,port)
	multiplayer.multiplayer_peer = peer
	transition_to_world("day")

func transition_to_world(music):
	get_tree().set_pause(false)
	Transition.fade_in()
	await Transition.player.animation_finished
	multiplayer_menu.queue_free()
	instance_lights()
	$HUD.show()
	Transition.fade_out()
	Audio.change_music(music)
	
func _process(_delta):
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
