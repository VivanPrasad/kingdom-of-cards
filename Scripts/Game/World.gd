extends Node2D

var in_dungeon : bool = false
@onready var light = preload("res://Scenes/Game/Objects/Light.tscn")
var lights = []
var doors = []
# Called when the node enters the scene tree for the first time.
func _ready():
	instance_lights()
	var bread = preload("res://Data/Cards/Bread.tres")
	print(bread.use())
	Card.new("papa")
func instance_lights():
	var cell_lights = []
	var cell_data
	for i in $Dungeon.get_layers_count():
		$Dungeon.set_layer_enabled(i, true)
		#checks how many layers are there in the dungeon, and enables each of them
	for layer in [$Surface,$Dungeon]:
		for cell in layer.get_used_cells(2): #all the cells in decoration layer
			cell_data = layer.get_cell_tile_data(2, cell) #get the TileData of the cell
			if cell_data != null and cell_data.modulate != Color(1.0,1.0,1.0,1.0): #the lights do not have white modulate
				cell_lights.append(cell_data)
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
			$Shader/AnimationPlayer.seek($UI/Time.second / 3600.0,false)
		else:
			$Shader/AnimationPlayer.play("Cycle")
	else:
		$Shader/AnimationPlayer.seek(4) #the dungeon looks dark, so it infinitely seeks at time = 4am
	

func dungeon(_layer): #flips state
	in_dungeon = !in_dungeon
	if in_dungeon: $AnimationPlayer.play("Dungeon")
	else: $AnimationPlayer.play_backwards("Dungeon")
	
func update_light(type):
	for child in lights: child.update(type)
	if type == 1: 
		for child in doors: 
			print(child.name)
	elif type == 2: for child in doors: print(child.name)
		#in the lights path array, each child is updated for the type of light desired
		# 0 = overworld on, 1 = dungeon on, 2 = overworld off

func _on_stair_body_entered(body):
	if body.name == "Player": dungeon($Entities/Player.layer)
	#causes dungeon transition if the body in the area is player
