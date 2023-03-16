extends TextureRect

var data : Card
@onready var player = $"/root/World/Entities/Player"
func _ready():
	$Name.text = data.name
	$Description.text = data.desc
	$Icon.frame = data.icon_id
	#$Shadow.texture = data.icon
	#The type and card cover will be a bit complicated...
	#I have not made the icon sheet for every card yet.
	#I will add it in the next update

func flip_over(side: bool): #back is 0, front is 1
	if side: pass #if front side
	else: pass #if back side

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
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if get_global_rect().has_point(get_global_mouse_position()):
			handle_use()

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
	queue_free()
	
