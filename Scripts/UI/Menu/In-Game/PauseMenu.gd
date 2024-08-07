extends Control

@onready var world : Node = $"/root/World"
@onready var buttons: VBoxContainer = $Panel/CenterContainer/Buttons

func _ready() -> void:
	connect_buttons()

func connect_buttons() -> void:
	for button:Button in buttons.get_children():
		button.pressed.connect(
			_on_button_pressed.bind(button))
		match str(button.name):
			"Quit to Menu":
				if Multi.is_online:
					button.name = &"Disconnect"
			"Invite":
				button.disabled = !Multi.is_online
				button.visible = Multi.is_online
		button.text = str(button.name)

func _on_button_pressed(button : Button) -> void:
	Audio.play_sfx(SFX.CONFIRM)
	match str(button.name):
		"Back to Game": 
			$"../..".current_menu = "None" ## Player
			queue_free()
		"Settings": 
			add_child(Global.Scenes.SETTINGS_SCENE\
				.instantiate())
		"Invite":
			pass
		"Quit to Menu":
			Transition.change_scene(Global.Scenes.GAME_MODE_PATH)
			Audio.change_music(Music.ONLINE)
		"Disconnect":
			get_tree().paused = true
			Transition.change_scene(Global.Scenes.GAME_MODE_PATH)
			await get_tree().create_timer(0.4).timeout
			get_tree().paused = false
			Audio.change_music(Music.ONLINE)
			for node in world.get_children():
				if node is Player:
					world.remove_child(node)
			world.multiplayer.multiplayer_peer = null
