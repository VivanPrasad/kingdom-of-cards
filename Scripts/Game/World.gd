extends Node2D

var in_dungeon : bool = false
@onready var light = preload("res://Scenes/Game/Objects/Light.tscn")
var lights = []
var cell_lights = []
var cell_data
# Called when the node enters the scene tree for the first time.
func _ready():
	instance_lights()

func instance_lights():
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
	for child in $Surface.get_children():
		if str(child.name).contains("Light"):
			lights.append(child)
	for child in $Dungeon.get_children():
		if str(child.name).contains("Light"):
			lights.append(child)
	for i in $Dungeon.get_layers_count():
		$Dungeon.set_layer_enabled(i, false)

func _process(_delta):
	if $Shader/AnimationPlayer.is_playing():
		$Shader/AnimationPlayer.seek($UI/Time.second / 3600.0,false)
	else:
		$Shader/AnimationPlayer.play("Cycle")

func dungeon(_layer):
	in_dungeon = !in_dungeon #flips state
	if in_dungeon:
		$AnimationPlayer.play("Dungeon")
	else:
		$AnimationPlayer.play_backwards("Dungeon")

func update_light(type):
	for child in lights:
		child.update(type)
		#in the lights path array, each child is updated for the type of light desired
		# 0 = overworld on, 1 = dungeon on, 2 = overworld off
func _on_stair_body_entered(body):
	if body.name == "Player":
		dungeon($Entities/Player.layer)
	#causes dungeon transition if the body in the area is player
func _on_stair_body_exited(_body):
	pass
