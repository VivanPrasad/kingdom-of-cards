extends TextureRect

var data : Card
@onready var player = $"/root/World/Entities/Player"

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
	#$Tooltip.tooltip_text = data.desc
	#The type and card cover will be a bit complicated...
	#I have not made the icon sheet for every card yet.
	#I will add it in the next update

func flip_over(side: bool): #back is 0, front is 1
	if side: $".".texture.set_region(Rect2(0,(34*data.type),18,34)) #if front side
	else: $".".texture.set_region(Rect2(18,(34*data.type),18,34)) #if back side

var hovered : bool = false
func _physics_process(_delta):
	if hovered: modulate = Color(1.3,1.3,1.3,1.0) #when hovered
	else: modulate = Color(1.0,1.0,1.0,1.0)

func _input(event):
	if event is InputEventMouse:
		if get_global_rect().has_point(get_global_mouse_position()):
			hovered = true
		else:
			hovered = false
	#if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		#if get_global_rect().has_point(get_global_mouse_position()):
			#handle_use()
func _process(_delta):
	custom_minimum_size = Vector2(scale.x*144,272)
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
	


func _on_tooltip_pressed():
	handle_use()
