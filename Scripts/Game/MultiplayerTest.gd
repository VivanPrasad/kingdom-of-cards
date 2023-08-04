extends Node2D

var port : int
var ip : String

var peer = ENetMultiplayerPeer.new()
@export var player_scene : PackedScene

var player_name : String

@onready var host_button := $"Lobby/MultiplayerMenu/VBoxContainer/TabContainer/Host Game/VBoxContainer/Host"
@onready var join_button := $"Lobby/MultiplayerMenu/VBoxContainer/TabContainer/Join Game/VBoxContainer/Join"

@onready var multiplayer_menu := $Lobby/MultiplayerMenu
@onready var animation_player := $Fade/AnimationPlayer

###
@onready var time_cycle := $Shader/TimeCycle
@onready var time := $HUD/Time

@onready var light = preload("res://Scenes/Game/Objects/Light.tscn")

var lights = [] #all node instances of all lights
var lights_pos = [] #positions of all lights
var lights_on : bool = true

var market_locations = {}

func _ready():
	get_tree().set_pause(true)
	instance_lights()
	host_button.connect("pressed",Callable(self,"_on_host_pressed"))
	join_button.connect("pressed",Callable(self,"_on_join_pressed"))
	$HUD.hide()
	$Lobby.show()
	$Fade.show()

func _on_host_pressed():
	ip = multiplayer_menu.host_ip_line.text
	port = int(multiplayer_menu.host_port_line.text)
	#peer.set_bind_ip(ip)
	peer.create_server(port)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_add_player)
	multiplayer.peer_disconnected.connect(remove_player)
	_add_player()
	transition_to_world()
	
func _add_player(id = 1):
	var player = player_scene.instantiate()
	player.name = str(id)
	call_deferred("add_child",player)

func remove_player(peer_id):
	var player = get_node_or_null(str(peer_id))
	if player:	player.queue_free()

func _on_join_pressed():
	ip = multiplayer_menu.join_ip_line.text
	port = int(multiplayer_menu.join_port_line.text)
	peer.create_client(ip,port)
	multiplayer.multiplayer_peer = peer
	transition_to_world()

func transition_to_world():
	get_tree().set_pause(false)
	animation_player.play_backwards("FadeIn")
	await animation_player.animation_finished
	multiplayer_menu.queue_free()
	$HUD.show()
	animation_player.play("FadeIn")
	await animation_player.animation_finished
	$Fade.queue_free()
	
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
				instance.layer = [$Surface,$Dungeon].find(layer) #surface = 0, dungeon = 1
				layer.add_child(instance)
	for child in $Surface.get_children() + $Dungeon.get_children():
		if str(child.name).contains("Light"): lights.append(child) #Adds the light node paths to the 
	for i in $Dungeon.get_layers_count(): $Dungeon.set_layer_enabled(i, false)

func toggle_lights(is_on : bool):
	var atlas_coords
	if not is_on:
		for pos in lights_pos:
			atlas_coords = $Surface.get_cell_atlas_coords(2,pos)
			if not atlas_coords in [Vector2i(0,8),Vector2i(0,0)]:
				$Surface.set_cell(2,pos,2,Vector2i(atlas_coords.x-1,atlas_coords.y))
	else:
		for pos in lights_pos:
			atlas_coords = $Surface.get_cell_atlas_coords(2,pos)
			if not atlas_coords in [Vector2i(0,8),Vector2i(0,0)]:
				$Surface.set_cell(2,pos,2,Vector2i(atlas_coords.x+1,atlas_coords.y))
	
	#TEMP GATE STATES
	for child in $Surface.get_children():
		if str(child.name).contains("Gate"):
			if time.hour == 8:
				child.get_child(0).get_child(0).play("Gate")
			else:
				child.get_child(0).get_child(0).play_backwards("Gate")


func _on_multiplayer_spawner_spawned(_node):
	pass

func _on_multiplayer_spawner_despawned(_node):
	pass
