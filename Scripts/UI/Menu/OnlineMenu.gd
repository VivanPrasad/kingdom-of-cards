extends Control

#Towns
@onready var town_listings: VBoxContainer = $TabContainer/Explore/ScrollContainer/TownListings
@onready var no_towns_label: Label = $TabContainer/Explore/NoTowns

#Profile
@onready var player_name_line = $TabContainer/Profile/HBoxContainer/VBoxContainer/Name/LineEdit
@onready var character_name = $TabContainer/Profile/HBoxContainer/VBoxContainer/Character/OptionButton
@onready var character_icon = $TabContainer/Profile/HBoxContainer/VBoxContainer/Character/AnimatedSprite2D

#World
@onready var multiplayer_world = $"../.."

const TOWN_LISTING = preload("res://Scenes/UI/Instances/TownListing.tscn")
var town_selected : int = -1

class TownListing:
	const MAX_PLAYERS : int = 10
	var town_name : String
	var icon : int
	func _init(set_town_name:String="Town of ???",set_icon:int=Global.UI.ICON.DEFAULT) -> void:
		town_name = set_town_name
		icon = set_icon

func _ready():
	connect_profile()
	connect_buttons()
	update_town_list()
	if Audio.get_node_or_null("SFX/light_rain") != null:
		Audio.stop_sfx("light_rain")
	player_name_line.text = Config.save.player_name
	character_icon.play(Config.save.player_character)
	character_name.select(int(Config.save.player_character) - 1)

func connect_buttons() -> void:
	pass
	#host_button.pressed.connect(_on_host_pressed)
	#join_button.pressed.connect(_on_join_pressed)
func connect_profile() -> void:
	player_name_line.text_changed.connect(_on_profile_update)
	character_name.item_selected.connect(_on_profile_update)
func _on_profile_update(_text : Variant) -> void:
	Config.save.player_name = player_name_line.text
	Config.save.player_character = str(character_name.get_selected_id() + 1)
	if multiplayer_world:
		multiplayer_world.player_name = player_name_line.text
		multiplayer_world.player_character = str(character_name.selected+1)

func update_town_list():
	for child in town_listings.get_children():
		if not child is Label: child.queue_free()
	var town_list : Array[TownListing] = []
	for town:TownListing in town_list:
		var item = TOWN_LISTING.instantiate()
		town_listings.add_child(item)
		item.town_name_label.text = town.town_name
	no_towns_label.visible = bool(len(town_list) == 0)

func _on_town_listing_selected(index : int) -> void:
	town_selected = index
	
func _on_back_pressed():
	get_tree().set_pause(false)
	Audio.play_sfx(SFX.BACK,0.0,-0.1)
	Transition.change_scene(Global.Scenes.GAME_MODE_PATH)
	Audio.change_music(Music.TITLE)

#From profile
func _on_name_item_selected(id):
	character_icon.play(str(id+1))

func _on_clear_pressed():
	Audio.play_sfx(SFX.SELECT,0.0,2.0)
	town_selected = -1

func _on_deselect_pressed():
	Audio.play_sfx(SFX.SELECT,0.0,2.0)
	town_selected = -1

func _on_tab_container_tab_changed(_tab):
	Audio.play_sfx(SFX.SELECT,0.0,2.0)
	town_selected = -1

func _on_refresh_pressed():
	Audio.play_sfx(SFX.CONFIRM,0.0,-0.5)
	update_town_list()
