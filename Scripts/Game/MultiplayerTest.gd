extends Node2D

var port : int
var ip : String

var peer = ENetMultiplayerPeer.new()
@export var player_scene : PackedScene
var player_name : String

func _ready():
	$UI/MainMenu/VBoxContainer/TabContainer/Settings/VBoxContainer/HBoxContainer/Name.text = "Guest" + str(randi() % 10) + str(randi() % 10) + str(randi() % 10)

func _physics_process(_delta):
	$"UI/MainMenu/VBoxContainer/TabContainer/Host Game/VBoxContainer/Host".disabled = bool(len($"UI/MainMenu/VBoxContainer/TabContainer/Host Game/VBoxContainer/HBoxContainer/HostIP".text) == 0 or not $"UI/MainMenu/VBoxContainer/TabContainer/Host Game/VBoxContainer/HBoxContainer2/Port".text.is_valid_int())
	$"UI/MainMenu/VBoxContainer/TabContainer/Join Game/VBoxContainer/Join".disabled = bool(len($"UI/MainMenu/VBoxContainer/TabContainer/Join Game/VBoxContainer/HBoxContainer/JoinIP".text) == 0 or not $"UI/MainMenu/VBoxContainer/TabContainer/Join Game/VBoxContainer/HBoxContainer2/Port".text.is_valid_int())
	player_name = $UI/MainMenu/VBoxContainer/TabContainer/Settings/VBoxContainer/HBoxContainer/Name.text

func _on_host_pressed():
	ip = $"UI/MainMenu/VBoxContainer/TabContainer/Host Game/VBoxContainer/HBoxContainer/HostIP".text
	port = int($"UI/MainMenu/VBoxContainer/TabContainer/Host Game/VBoxContainer/HBoxContainer2/Port".text)
	peer.set_bind_ip(ip)
	peer.create_server(port)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_add_player)
	_add_player()
	$UI.visible = false
func _add_player(id = 1):
	var player = player_scene.instantiate()
	player.name = str(id)
	call_deferred("add_child",player)
	
func _on_join_pressed():
	ip = $"UI/MainMenu/VBoxContainer/TabContainer/Join Game/VBoxContainer/HBoxContainer/JoinIP".text
	port = int($"UI/MainMenu/VBoxContainer/TabContainer/Join Game/VBoxContainer/HBoxContainer2/Port".text)
	peer.create_client(ip,port)
	multiplayer.multiplayer_peer = peer
	$UI.visible = false
