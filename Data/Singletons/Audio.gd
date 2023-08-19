extends Node

#Music
@onready var title = preload("res://Assets/Audio/Music/title.ogg")
@onready var online = preload("res://Assets/Audio/Music/online.ogg")

@onready var day = preload("res://Assets/Audio/Music/day.ogg")
@onready var castle = preload("res://Assets/Audio/Music/castle.ogg")
@onready var dungeon = preload("res://Assets/Audio/Music/dungeon.ogg")
@onready var mines = preload("res://Assets/Audio/Music/mines.ogg")
#SFX
@onready var back = preload("res://Assets/Audio/SFX/UI/back.wav")
@onready var select = preload("res://Assets/Audio/SFX/UI/select.wav")
@onready var confirm = preload("res://Assets/Audio/SFX/UI/confirm.wav")

@onready var select2 = preload("res://Assets/Audio/SFX/UI/select.wav")

@onready var light_rain = preload("res://Assets/Audio/Ambience/light_rain.mp3")
const music_max = {"online":-14.0,"title":-4.0,"day":-7.0,"castle":-11.0,"dungeon":-5.0,"mines":0.0}
const sfx_volume = {"back":10.0,"confirm":-5.0,"select":15.0,"select2":15.0,"light_rain":-7.0}
const sfx_pitch = {"back":1.0,"confirm":1.0,"select":1.0,"select2":2.0,"light_rain":0.8}

func _ready():
	var tween = create_tween()
	tween.tween_property($Music, "volume_db",music_max["title"],1.0)
	tween.play()
func play_day():
	$day.play()

func lower_sfx_volume(sfx):
	var node = $SFX.get_node_or_null(sfx)
	node.volume_db = sfx_volume[sfx] - 20.0
	node.pitch_scale = sfx_pitch[sfx] - 0.6
	

func reset_sfx_volume(sfx):
	var node = $SFX.get_node_or_null(sfx)
	node.volume_db = sfx_volume[sfx]
	node.pitch_scale = sfx_pitch[sfx]
func change_music(stream_name):
	var tween = create_tween()
	tween.tween_property($Music, "volume_db",-80,0.0)
	tween.play()
	await tween.finished
	$Music.set_stream(get(stream_name))
	$Music.play()
	var tween2 = create_tween()
	tween2.tween_property($Music, "volume_db",music_max[stream_name],0.0)
	tween2.play()

func play_sfx(sfx_name,fade_in = false):
	var sfx = AudioStreamPlayer.new()
	sfx.name = sfx_name
	sfx.set_stream(get(sfx_name))
	sfx.mix_target = AudioStreamPlayer.MIX_TARGET_SURROUND
	sfx.bus = &"SFX"
	sfx.pitch_scale = sfx_pitch[sfx_name]
	$SFX.add_child(sfx)
	if fade_in:
		sfx.volume_db = -80.0
		var tween3 = create_tween()
		tween3.tween_property(sfx, "volume_db",sfx_volume[sfx_name],1.0)
		tween3.play()
	else:
		sfx.volume_db = sfx_volume[sfx_name]
	sfx.play()
	if not fade_in:
		await sfx.finished
		sfx.queue_free()
	
func is_music_playing():
	return $Music.is_playing()

func stop_sfx(sfx_name,fade_out = false):
	var sfx = $SFX.get_node_or_null(sfx_name)
	if fade_out:
		var tween4 = create_tween()
		tween4.tween_property(sfx, "volume_db",-80.0,1.0)
		tween4.play()
		await tween4.finished
		if sfx != null:
			sfx.stop()
			sfx.queue_free()
	else:
		if sfx != null:
			sfx.stop()
			sfx.queue_free()
