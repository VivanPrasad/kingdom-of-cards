extends Node2D

@onready var light = preload("res://Scenes/Game/Objects/Light.tscn")

@onready var time := $HUD/Time
@onready var time_cycle := $Shader/TimeCycle

# Format:
# mod: runtime (e.g. "testmod.kocm": "worldLoad"
var hooked_mods = {}

var weather = "Normal"
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
		#checks how many layers are there in the dungeon, and enables each of them
	for layer in [$Surface,$Dungeon]:
		for cell in layer.get_used_cells(2): #all the cells in decoration layer
			cell_data = layer.get_cell_tile_data(2, cell) #get the TileData of the cell
			if cell_data != null and cell_data.modulate != Color(1.0,1.0,1.0,1.0): #the lights do not have white modulate
				#layer.set_cell(2,)
				var instance = light.instantiate()
				instance.position = cell * 8 #position on grid is 8x scale
				instance.on_surface = [$Dungeon,$Surface].find(layer) #surface = 0, dungeon = 1
				layer.add_child(instance)

func _process(_delta):
	var local_player = get_node_or_null(Global.player_id)
	var on_surface : bool = true
	if local_player != null:
		on_surface = local_player.on_surface
	
	if time_cycle.is_playing():
		if weather != time_cycle.current_animation:
			time_cycle.play(weather)
		if on_surface:
			if weather == "HeavyRain":
				$Weather/Rain.emitting = true
			else:
				$Weather/Rain.emitting = false
			time_cycle.seek(time.second / 3600.0,false)
		else:
			$Weather/Rain.emitting = false
			time_cycle.seek(4.0,false)
	else:
		time_cycle.play(weather) #the dungeon looks dark, so it infinitely seeks at time = 4am

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
			Audio.change_music("day")

func _on_stair_body_entered(body):
	if body.name == "Player": descend(body)
	#causes dungeon transition if the body in the area is player

'''
func _unhandled_input(_event):
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
