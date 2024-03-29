extends PointLight2D

@export var on_surface : bool = true

var type
@onready var time = $"/root/World/HUD/Time"
@onready var player : Node

func _ready() -> void:
	player = $"/root/World".get_node_or_null(Global.player_id)
	if player != null:
		energy = 0.5 * float(bool(on_surface == player.on_surface))

func _physics_process(_delta) -> void:
	var _previous_value = enabled
	player = $"/root/World".get_node_or_null(Global.player_id)
	if player != null and not $AnimationPlayer.is_playing():
		if on_surface == player.on_surface:
			energy = 0.5
		else:
			energy = 0
	if on_surface:
		if time.hour == 7 and time.minute == 45:
			$AnimationPlayer.play("Fade")
		elif time.hour == 17 and time.minute == 0:
			$AnimationPlayer.play_backwards("Fade")
		if time.hour >= 8 and time.hour < 17:
			enabled = false
		else:
			enabled = true
	else:
		enabled = true
	"""
	if previous_value != enabled:
		if enabled == true:
			var atlas_coords = get_parent().get_cell_atlas_coords(2,position/8)
			if not atlas_coords in [Vector2(0,8),Vector2(0,0)]:
				get_parent().set_cell(2,position/8,2,Vector2i(atlas_coords.x+1,atlas_coords.y))
		else:
			var atlas_coords = get_parent().get_cell_atlas_coords(2,position/8)
			if not atlas_coords in [Vector2i(0,8),Vector2i(0,0)]:
				get_parent().set_cell(2,position/8,2,Vector2i(atlas_coords.x-1,atlas_coords.y))
	previous_value = enabled
	"""
