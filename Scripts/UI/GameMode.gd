extends Control

@onready var options: VBoxContainer = $Options

func _ready() -> void:
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
	button.text = "~ " + str(button.name)
	
func _on_button_exited(button:Button) -> void:
	create_tween()\
		.tween_property(button,"position:x",0,0.1)\
		.set_trans(Tween.TRANS_CIRC)
	button.text = str(button.name)

func _on_button_pressed(button:Button) -> void:
	Audio.play_sfx(SFX.CONFIRM)
	match button.get_index():
		0:
			var scene : Game = load(Global.Scenes.WORLD_SCENE).duplicate().instantiate()
			scene.is_online = false
			
			var packed_scene = PackedScene.new()
			packed_scene.pack(scene)
			Transition.change_scene_packed(packed_scene)
			
		1:
			Audio.change_music(Music.ONLINE)
			Transition.change_scene(Global.Scenes.WORLD_SCENE)
		2:
			Transition.change_scene(Global.Scenes.TITLE_SCENE)
		_:
			pass
