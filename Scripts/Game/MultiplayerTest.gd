extends Node2D

var port : int
var ip : String

@onready var host_button := $"UI/MultiplayerMenu/VBoxContainer/TabContainer/Host Game/VBoxContainer/Host"
@onready var join_button := $"UI/MultiplayerMenu/VBoxContainer/TabContainer/Join Game/VBoxContainer/Join"

@onready var multiplayer_menu := $UI/MultiplayerMenu
@onready var animation_player := $Fade/AnimationPlayer
var peer = ENetMultiplayerPeer.new()
@export var player_scene : PackedScene

var player_name : String

func _ready():
	get_tree().set_pause(true)
	host_button.connect("pressed",Callable(self,"_on_host_pressed"))
	join_button.connect("pressed",Callable(self,"_on_join_pressed"))
	$HUD.hide()
	$UI.show()
	$Fade.show()

func _on_host_pressed():
	ip = $"UI/MultiplayerMenu/VBoxContainer/TabContainer/Host Game/VBoxContainer/HBoxContainer/HostIP".text
	port = int($"UI/MultiplayerMenu/VBoxContainer/TabContainer/Host Game/VBoxContainer/HBoxContainer2/Port".text)
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
	
	
