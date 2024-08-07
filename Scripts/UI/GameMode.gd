extends Control

@onready var buttons: VBoxContainer = $Buttons

func _ready() -> void:
	connect_buttons()

func connect_buttons() -> void:
	for button: Button in buttons.get_children():
		button.mouse_entered.connect(
			func(): button.grab_focus())
		button.mouse_exited.connect(
			func(): button.release_focus())
		button.focus_entered.connect(
			_on_button_entered.bind(button))
		button.focus_exited.connect(
			_on_button_exited.bind(button))
		button.pressed.connect(
			_on_button_pressed.bind(button))
		button.text = str(button.name)
		button["theme_override_styles/focus"] = StyleBoxEmpty.new()
	await Transition.faded
	buttons.get_child(0).grab_focus()

func _on_button_entered(button:Button) -> void:
	Audio.play_sfx(SFX.SELECT)
	create_tween()\
		.tween_property(button,"position:x",20,0.1)\
		.set_trans(Tween.TRANS_CIRC)
	button.text = "~%s" % button.name
	
func _on_button_exited(button:Button) -> void:
	create_tween()\
		.tween_property(button,"position:x",0,0.1)\
		.set_trans(Tween.TRANS_CIRC)
	button.text = "%s" % button.name

func _on_button_pressed(button:Button) -> void:
	Audio.play_sfx(SFX.CONFIRM)
	match str(button.name):
		"Solo":
			Multi.is_online = false
			Transition.change_scene(Global.Scenes.WORLD_SCENE)
		"Online":
			Multi.is_online = true
			Audio.change_music(Music.ONLINE)
			Transition.change_scene(Global.Scenes.WORLD_SCENE)
		"Back":
			Transition.change_scene(Global.Scenes.TITLE_PATH)

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		Audio.play_sfx(SFX.CONFIRM)
		Transition.change_scene(Global.Scenes.TITLE_PATH)
		set_process_unhandled_input(false)
