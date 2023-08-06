extends CanvasLayer

var joystick_active : bool = false
var vector = Vector2.ZERO
@onready var player := $".."

@onready var joystick_button := $Joystick/Ring/Button
@onready var joystick_ring := $Joystick/Ring
func _input(event):
	if event is InputEventScreenTouch:
		var distance = event.position.distance_to(joystick_ring.global_position)
		print(distance)
		if not joystick_active:
			if distance <= 96:
				joystick_active = true
		else:
			joystick_button.position = Vector2(0,0)
			joystick_active = false
			vector = Vector2.ZERO

func get_input_vector():
	vector = Vector2(joystick_button.position.x/16.0,joystick_button.position.y/16.0)
func _process(_delta):
	if joystick_active:
		joystick_button.global_position = get_viewport().get_mouse_position()
		joystick_button.position = joystick_button.position.limit_length(16.0)
		get_input_vector()
	
	if player.current_menu == "None":
		hide_exit()
	else:
		show_exit()
func show_exit():
	$Pause.hide()
	$Inventory.hide()
	$Emote.hide()
	if player.current_menu != "PauseMenu":
		$CanvasLayer/Exit.show()

func hide_exit():
	$Pause.show()
	$Inventory.show()
	$Emote.show()
	$CanvasLayer/Exit.hide()

func _on_pause_pressed():
	if player.current_menu != "PauseMenu":
		player.open_menu(player.pause_menu)
	else:
		hide_exit()
		player.close_menu()

func _on_inventory_pressed():
	if player.current_menu != "InventoryMenu":
		player.open_menu(player.inventory_menu)
	else:
		player.close_menu()

func _on_emote_pressed():
	if player.current_menu != "EmoteMenu":
		player.open_menu(player.emote_menu)
	else:
		player.close_menu()


func _on_exit_pressed():
	player.close_menu()
