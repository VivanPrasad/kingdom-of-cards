extends Control

@onready var host_button = $"VBoxContainer/TabContainer/Host Game/VBoxContainer/Host"
@onready var join_button = $"VBoxContainer/TabContainer/Join Game/VBoxContainer/Join"

@onready var host_ip_line = $"VBoxContainer/TabContainer/Host Game/VBoxContainer/HBoxContainer/HostIP"
@onready var host_port_line = $"VBoxContainer/TabContainer/Host Game/VBoxContainer/HBoxContainer2/Port"
@onready var join_ip_line = $"VBoxContainer/TabContainer/Join Game/VBoxContainer/HBoxContainer/JoinIP"
@onready var join_port_line = $"VBoxContainer/TabContainer/Join Game/VBoxContainer/HBoxContainer2/Port"

@onready var player_name_line = $"VBoxContainer/TabContainer/Settings/VBoxContainer/HBoxContainer/Name"

@onready var multiplayer_world = $"../.."
func _ready():
	player_name_line.text = "Guest" + str(randi_range(100,999))
func _physics_process(_delta):
	host_button.disabled = bool(len(host_ip_line.text) == 0 or not host_port_line.text.is_valid_int())
	join_button.disabled = bool(len(join_ip_line.text) == 0 or not join_port_line.text.is_valid_int())
	multiplayer_world.player_name = player_name_line.text


func _on_back_pressed():
	$"../../Fade/AnimationPlayer".play_backwards("FadeIn")
	await $"../../Fade/AnimationPlayer".animation_finished
	get_tree().set_pause(false)
	get_tree().change_scene_to_file("res://Scenes/UI/GameMode.tscn")

func _on_back_mouse_entered():
	pass # Replace with function body.

func _on_back_mouse_exited():
	pass # Replace with function body.
