extends Node

#Music
@onready var title = preload("res://Assets/Audio/Music/title.ogg")
@onready var online = preload("res://Assets/Audio/Music/online.ogg")

@onready var day = preload("res://Assets/Audio/Music/day.ogg")

#SFX
@onready var back = preload("res://Assets/Audio/SFX/UI/back.wav")
@onready var select = preload("res://Assets/Audio/SFX/UI/select.wav")
@onready var confirm = preload("res://Assets/Audio/SFX/UI/confirm.wav")

@onready var select2 = preload("res://Assets/Audio/SFX/UI/select.wav")
const music_max = {"online":-11.0,"title":-7.0,"day":-7.0}
const sfx_volume = {"back":10.0,"confirm":-5.0,"select":15.0,"select2":15.0}
const sfx_pitch = {"back":1.0,"confirm":1.0,"select":1.0,"select2":2.0}
func _ready():
	var tween = create_tween()
	tween.tween_property($Music, "volume_db",2.0,1.0)
	tween.play()
	
func play_day():
	$day.play()

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

func play_sfx(sfx_name):
	var sfx = AudioStreamPlayer.new()
	sfx.name = sfx_name
	sfx.set_stream(get(sfx_name))
	sfx.volume_db = sfx_volume[sfx_name]
	sfx.mix_target = AudioStreamPlayer.MIX_TARGET_SURROUND 
	sfx.bus = &"SFX"
	sfx.pitch_scale = sfx_pitch[sfx_name]
	$SFX.add_child(sfx)
	sfx.play()
	await sfx.finished
	sfx.queue_free()
	
	
func is_music_playing():
	return $Music.is_playing()

