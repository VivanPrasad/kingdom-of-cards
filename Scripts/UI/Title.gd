extends Control

# Called when the node enters the scene tree for the first time.

@onready var buttons: VBoxContainer = $MarginContainer/Buttons

func _ready():
	get_tree().paused = false
	connect_buttons()

func connect_buttons() -> void:
	for button:Button in buttons.get_children():
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
		button["theme_override_styles/focus"] = StyleBoxEmpty.new()
	await Transition.faded
	buttons.get_child(0).grab_focus()

func _on_button_entered(button:Button) -> void:
	Audio.play_sfx(SFX.SELECT)
	create_tween()\
		.tween_property(button,"position:x",20,0.1)\
		.set_trans(Tween.TRANS_CIRC)
	button.text = "~%s" %button.name
	
func _on_button_exited(button:Button) -> void:
	create_tween()\
		.tween_property(button,"position:x",0,0.1)\
		.set_trans(Tween.TRANS_CIRC)
	button.text = "%s" %button.name

func _on_button_pressed(button:Button) -> void:
	match str(button.name):
		"Play":
			Audio.play_sfx(SFX.CONFIRM)
			Transition.change_scene(Global.Scenes.GAME_MODE_PATH)
		"Settings":
			Audio.play_sfx(SFX.CONFIRM)
			var settings = Global.Scenes.SETTINGS_SCENE.instantiate()
			add_child(settings)
			settings.audio_sliders.get_child(0).get_child(1).grab_focus()
		"Quit":
			get_tree().quit()
