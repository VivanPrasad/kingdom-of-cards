extends TextureRect

var data : Card
@onready var player = $"/root/World/Entities/Player"

var hovered : bool = false
var selected : bool = false

func _get_drag_data(_at_position):
	pass
func _ready():
	$Name.text = data.name
	if len(data.name) > 10:
		$Name.label_settings.font_size = 8
	$Description.text = data.desc
	$Icon.frame = data.icon_id
	$".".texture = $".".texture.duplicate()
	$".".texture.set_region(Rect2(0,(34*data.type),18,34))
	
	$Tooltip.tooltip_text = ["Food", "Item", "Golden", "Material", "Attire", "Role", "Tool", "Other"][data.type]
	$Name.label_settings = $Name.label_settings.duplicate()
	$Name.label_settings.set_shadow_color(Color(["522d3d","342842","b37a59","323f4d","321b2c","2c4c47","403b5f","522d3d"][data.type]))
	$Description.add_theme_color_override("font_shadow_color",Color(["522d3d","342842","b37a59","323f4d","321b2c","2c4c47","403b5f","522d3d"][data.type]))
	#The type and card cover will be a bit complicated...
	#I have not made the icon sheet for every card yet.
	#I will add it in the next update

func flip_over(side: bool): #back is 0, front is 1
	if side: $".".texture.set_region(Rect2(0,(34*data.type),18,34)) #if front side
	else: $".".texture.set_region(Rect2(18,(34*data.type),18,34)) #if back side

func _input(event):
	if event is InputEventMouse:
		if get_global_rect().has_point(get_global_mouse_position()):
			hovered = true
		else:
			hovered = false
	if event is InputEventMouseButton and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if get_global_rect().has_point(get_global_mouse_position()):
			selected = true
		else:
			selected = false
	#if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		#if get_global_rect().has_point(get_global_mouse_position()):
			#handle_use()
func _process(_delta):
	custom_minimum_size = Vector2(scale.x*144,272)
	if hovered: modulate = Color(1.1,1.1,1.1,1.0); position.y -= 3.0 * float(position.y > -8) #when hovered
	else: modulate = Color(1.0,1.0,1.0,1.0); position.y += 3.0 * float(position.y < 0)
	if selected: $Use.visible = true #when clicked to be selected
	else: $Use.visible = false

func handle_use():
	var object = $"/root/World/Entities".find_child(data.object_name)
	
	var key_index = 0
	for var_string in data.object_variables.keys():
		object.set(var_string,data.object_variables.values()[key_index])
		key_index += 1
	
	key_index = 0
	for func_string in data.object_functions.keys():
		object.call(func_string,data.object_functions.values()[key_index])
		key_index += 1
	player.inventory.pop_at(get_index())
	$AnimationPlayer.play("Flip")
	await $AnimationPlayer.animation_finished
	queue_free()
	

func _on_use_pressed():
	handle_use()
	selected = false
	hovered = false
