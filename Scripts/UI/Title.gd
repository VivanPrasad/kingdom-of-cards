extends Control

# Called when the node enters the scene tree for the first time.

@onready var options: VBoxContainer = $Options

func _ready():
	get_tree().set_pause(false)
	connect_buttons()

func connect_buttons() -> void:
	for button: Button in options.get_children():
		button.mouse_entered.connect(
			_on_button_entered.bind(button))
		button.mouse_exited.connect(
			_on_button_exited.bind(button))
		button.pressed.connect(
			_on_button_pressed.bind(button))
	

func _on_button_entered(button:Button) -> void:
	Audio.play_sfx(SFX.SELECT)
	create_tween()\
		.tween_property(button,"position:x",20,0.1)\
		.set_trans(Tween.TRANS_CIRC)
	button.text = "~ " +str(button.name)
	
func _on_button_exited(button:Button) -> void:
	create_tween()\
		.tween_property(button,"position:x",0,0.1)\
		.set_trans(Tween.TRANS_CIRC)
	button.text = str(button.name)

func _on_button_pressed(button:Button) -> void:
	match button.get_index():
		0:
			Audio.play_sfx(SFX.CONFIRM)
			Transition.change_scene(Global.Scenes.GAME_MODE_SCENE)
		1:
			Audio.play_sfx(SFX.CONFIRM)
			add_child(load(Global.Scenes.SETTINGS_SCENE).instantiate())
		2:
			get_tree().quit()
		_:
			pass
