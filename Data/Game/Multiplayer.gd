extends Node

var port : int = 25565
var host_ip : String
var ip : String = "23.16.130.237"

var mode : String = "host"
var peer = ENetMultiplayerPeer.new()
@export var player_scene : PackedScene
var player_path : CharacterBody2D
var player_name : String = "Player" + str(randi_range(100,999))

func _ready():
	get_host_ipv4()
	get_public_ipv4()

func get_host_ipv4():
	for address in IP.get_local_addresses():
		if (address.split('.').size() == 4):
			host_ip = address
	print("IPv4: " + host_ip)
func get_public_ipv4():
	var http = HTTPRequest.new()
	add_child(http)
	http.connect("request_completed", Callable(self, "print_ip"))
	http.request("https://api.ipify.org")
	
func print_ip(_result, _response_code, _headers, _body):
	#ip = body.get_string_from_utf8()
	print("Public IP: ", ip)
func create_server():
	peer.set_bind_ip("localhost")
	peer.create_server(port)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_add_player)
	_add_player()

func _add_player(id = 1):
	var player = player_scene.instantiate()
	player.name = str(id)
	$"../World/Entities".call_deferred("add_child",player)

func join_server():
	peer.create_client(ip,port)
	multiplayer.multiplayer_peer = peer
