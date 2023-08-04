extends Node2D

var online = false
var in_dungeon : bool = false
@onready var light = preload("res://Scenes/Game/Objects/Light.tscn")

# UI Menu Instancing
@onready var inventory_menu := preload("res://Scenes/UI/Menu/In-Game/InventoryMenu.tscn")
@onready var action_hud := preload("res://Scenes/UI/HUD/ActionHUD.tscn")
@onready var market_menu := preload("res://Scenes/UI/Menu/In-Game/MarketMenu.tscn")
@onready var emote_menu := preload("res://Scenes/UI/Menu/In-Game/EmoteMenu.tscn")
@onready var game_over := preload("res://Scenes/UI/HUD/GameOver.tscn")

@onready var time := $HUD/Time

enum menu {none=0,inventory=1,market=2,combat=3,escape=4,chat=5,emote=6}

@export var current_menu : int = menu.none

var lights = []
var lights_pos = [] #positions of all lights
var lights_on : bool = true

var market_locations = {}

# Format:
# mod: runtime (e.g. "testmod.kocm": "worldLoad"
var hooked_mods = {}

func _started(): # worldLoad mod hook
	print("[KOCM/WorldLoadHook] Executing worldLoad mods...")
	var ModExec = load("res://Scripts/Modding/Executor.gd")
	for hm in hooked_mods:
		if hooked_mods.get(hm) == "worldLoad":
			ModExec.runMod(hm, self)
func addMod(modInformation, hook):
	print("[KOCM/ModLoader] Adding mod to World hook...")
	hooked_mods.merge({modInformation["file"]: hook})

# Called when the node enters the scene tree for the first time.
func _ready():
	instance_lights()
	var moddingScript = load("res://Scripts/Modding/Main.gd")
	moddingScript.start()
	var wlm = moddingScript.getModsByRuntime("worldLoad")
	for mod in wlm:
		addMod(mod, "worldLoad")
	
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
func _process(_delta):
	if not in_dungeon:
		if $Shader/AnimationPlayer.is_playing():
			$Shader/AnimationPlayer.seek(time.second / 3600.0,false)
		else:
			$Shader/AnimationPlayer.play("Cycle")
	else:
		$Shader/AnimationPlayer.seek(4) #the dungeon looks dark, so it infinitely seeks at time = 4am
	
	#MENU HANDLER
	handle_menu()

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

func dungeon(): #flips state
	$Entities/Player.layer = in_dungeon
	in_dungeon = !in_dungeon
	if in_dungeon: $AnimationPlayer.play("Dungeon")
	else: $AnimationPlayer.play_backwards("Dungeon")

func get_market_locations():
	for child in $Surface.get_children():
		print(child.name)
		if str(child.name) in ["FoodMarket","BankDesk","ItemMarket"]: #THERE CAN ONLY BE ONE MARKET INSTANCE FOR EACH!!!!
			market_locations[str(child.name)] = child.position

func update_light(type):
	for child in lights: child.update(type)
		#in the lights path array, each child is updated for the type of light desired
		# 0 = overworld on, 1 = dungeon on, 2 = overworld off

func _on_stair_body_entered(body):
	if body.name == "Player": dungeon()
	#causes dungeon transition if the body in the area is player

func handle_menu():
	if $Entities/Player.in_combat:
		current_menu = menu.combat
	elif current_menu == menu.combat:
		current_menu = menu.none
	if current_menu != menu.inventory:
		if get_node_or_null("HUD/InventoryMenu") != null:
			$HUD/InventoryMenu.queue_free()
	else:
		if get_node_or_null("HUD/InventoryMenu") == null:
			$HUD.add_child(inventory_menu.instantiate())
	
	if current_menu != menu.market:
		if get_node_or_null("HUD/MarketMenu") != null:
			$HUD/MarketMenu.queue_free()
	else:
		if get_node_or_null("HUD/MarketMenu") == null:
			$HUD.add_child(market_menu.instantiate())
	if current_menu != menu.combat:
		if get_node_or_null("HUD/ActionHUD") != null:
			$HUD/ActionHUD.queue_free()
	else:
		if get_node_or_null("HUD/ActionHUD") == null:
			$HUD.add_child(action_hud.instantiate())
	
	if current_menu != menu.chat:
		$HUD/Chat.isInputActive = false
		$HUD/Chat/ChatWindow.visible = false
	else:
		$HUD/Chat.isInputActive = true
		$HUD/Chat/ChatWindow.visible = true

func _unhandled_input(_event):
	if Input.is_action_just_pressed("interact"): #Just inv menu for now... will need to make a handler later
		if current_menu == menu.inventory:
			current_menu = menu.none
		elif current_menu == menu.none:
			current_menu = menu.inventory
	
	if Input.is_action_just_pressed("ui_cancel"):
		current_menu = menu.none
	#owner
	if Input.is_action_just_pressed("chat"):
		if current_menu == menu.chat:
			current_menu = menu.none
		elif current_menu != menu.combat:
			current_menu = menu.chat
	'''
	if event is InputEventMouseButton and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		$Surface.set_cell(0,Vector2i(get_global_mouse_position().floor() / 37),0,Vector2i(0,1))
	if event is InputEventMouse:
		print(Vector2i($Surface.get_global_mouse_position().floor() / 37))
	'''

'''
func _on_pressed():
	var prop_instance = load("res://Props/" + str($".".get_prop_files()[get_index()])).instantiate()
	prop_instance.position = Vector3(0, 1.5, 0)
	$"/root/devtest_01".add_child(prop_instance)
'''
