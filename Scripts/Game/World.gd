extends Node2D
class_name Game

var ip : String

var peer : ENetMultiplayerPeer = ENetMultiplayerPeer.new()

# Local Player
@export var player_name : String
@export var player_character : String
@export_enum("Normal","Rain","BloodMoon") var weather : String = "Normal"

# Lobby
@onready var multiplayer_menu := $Lobby/OnlineMenu
###
@onready var time_cycle := $Shader/TimeCycle
@onready var chat := $HUD/Chat
@onready var player_list := $HUD/PlayerList
@onready var connection_menu := $HUD/ConnectionMenu
@onready var rain: GPUParticles2D = $Weather/Rain

@onready var surface: TileMap = $Surface
@onready var dungeon: TileMap = $Dungeon
@onready var dungeon_stair: Area2D = $DungeonStair

@onready var hud : CanvasLayer = $HUD
@onready var lobby : CanvasLayer = $Lobby

@onready var shader : CanvasModulate = $Shader

const PLAYER_SCENE : PackedScene = preload("res://Scenes/Game/Entities/Player.tscn")
const LIGHT_SCENE : PackedScene = preload("res://Scenes/Game/Objects/Light.tscn")

func _ready():
	surface.show()
	hud.hide(); lobby.show()
	get_tree().set_pause(true)
	
	if not Multi.is_online:
		multiplayer_menu.queue_free()
		chat.queue_free()
		_add_player(1)
		transition_to_world("day")

func _on_host_pressed():
	Audio.play_sfx(SFX.CONFIRM,0.5,-0.2)
	var setup = await setup_server()
	if not setup: return
	peer.create_server(Multi.PORT)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_add_player)
	multiplayer.peer_disconnected.connect(remove_player)
	_add_player()
	transition_to_world("castle")

func _add_player(id = 1):
	var player = PLAYER_SCENE.instantiate()
	player.name = str(id)
	add_child(player)

func remove_player(peer_id):
	var player = get_node_or_null(str(peer_id))
	chat.player_left(player)
	player.queue_free()
	
func _on_join_pressed():
	Audio.play_sfx(SFX.CONFIRM,0.5,-0.2)
	#transition_to_world("day")
	#var server_ip = Config.config_data.server_list[multiplayer_menu.town_selected]
	#ip = server_ip
	#peer.create_client(ip,Multi.PORT)
	#multiplayer.multiplayer_peer = peer
	
func transition_to_world(music : String) -> void:
	Transition.fade_out(0.5)
	if music == "day":
		Audio.change_music(Music.DAY)
	else:
		Audio.change_music(Music.CASTLE)
	get_tree().set_pause(false)
	multiplayer_menu.queue_free()
	instance_lights()
	hud.show()

func _physics_process(_delta) -> void:
	handle_weather()

func handle_weather() -> void:
	var local_player = get_node_or_null(Global.player_id)
	var on_surface : bool = true
	if local_player != null:
		on_surface = local_player.on_surface
	if time_cycle.is_playing():
		if weather != time_cycle.current_animation:
			time_cycle.play(weather)
		if on_surface:
			if weather == "HeavyRain":
				if Audio.get_node_or_null("SFX/light_rain") == null:
					Audio.play_sfx(Audio.LIGHT_RAIN,true)
				else:
					Audio.reset_sfx_volume("light_rain")
				rain.emitting = true
			else:
				if Audio.get_node_or_null("SFX/light_rain") != null:
					Audio.stop_sfx("light_rain",true)
				rain.emitting = false
			time_cycle.seek(GameTime.second * GameTime.SECOND_TO_HOUR,false)
		else:
			if time_cycle.current_animation != "Normal":
				time_cycle.play("Normal")
			rain.emitting = false
			time_cycle.seek(4.0,false)
			
			if Audio.get_node_or_null("SFX/light_rain") != null:
				Audio.lower_sfx_volume("light_rain")
	else:
		time_cycle.play(weather)

func instance_lights():
	var cell_data : TileData
	# checks how many layers are there in the dungeon, 
	# and enables each of them
	for layer in [surface,dungeon]:
		for cell in layer.get_used_cells(2): #all the cells in decoration layer
			cell_data = layer.get_cell_tile_data(2, cell) #get the TileData of the cell
			if cell_data != null and cell_data.modulate != Color(1.0,1.0,1.0,1.0): #the lights do not have white modulate
				var instance = LIGHT_SCENE.instantiate()
				instance.position = cell * 8 #position on grid is 8x scale
				instance.on_surface = bool(layer == $Surface)
				layer.add_child(instance,true)

func descend_to_mines(body):
	descend(body,Music.MINES)

func descend_to_dungeon(body):
	descend(body,Music.DUNGEON)

func descend(body,music) -> void:
	if body is Player and body.is_multiplayer_authority():
		if body.on_surface:
			await Transition.fade_in(1.5)
			body.on_surface = false
			surface.tile_set.set_physics_layer_collision_layer(0,0)
			surface.hide()
			dungeon.tile_set.set_physics_layer_collision_layer(0,2)
			dungeon_stair.scale = Vector2(-1,-1)
			Transition.fade_out(1.5)
			Audio.change_music(music)
		else:
			
			await Transition.fade_in(1.5)
			body.on_surface = true
			surface.tile_set.set_physics_layer_collision_layer(0,2)
			surface.show()
			dungeon.tile_set.set_physics_layer_collision_layer(0,0)
			dungeon_stair.scale = Vector2(1,1)
			Transition.fade_out(1.5)
			if body.character == Player.ROYAL:
				Audio.change_music(Music.CASTLE)
			else:
				Audio.change_music(Music.DAY)

func _on_multiplayer_spawner_despawned(node):
	chat.player_left(node.player_name.text)

func setup_server() -> bool:
	Transition.fade_in()
	await Transition.faded
	var upnp = UPNP.new()
	
	var result = upnp.discover()
	
	if result == 0:
		print_rich("[color=aqua][b]<Host>[/b][/color] UPnP is Enabled")
	else:
		Transition.change_scene(Global.Scenes.WORLD_SCENE)
		return false
	upnp.add_port_mapping(Multi.PORT)
	return true
