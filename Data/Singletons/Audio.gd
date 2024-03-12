extends Node

#Music
var title : AudioStream = preload("res://Assets/Audio/Music/title.ogg")
var online : AudioStream = preload("res://Assets/Audio/Music/online.ogg")

var day : AudioStream = preload("res://Assets/Audio/Music/day.ogg")
var castle : AudioStream = preload("res://Assets/Audio/Music/castle.ogg")
var dungeon : AudioStream = preload("res://Assets/Audio/Music/dungeon.ogg")
var mines : AudioStream = preload("res://Assets/Audio/Music/mines.ogg")
#SFX
var back : AudioStream = preload("res://Assets/Audio/SFX/UI/back.wav")
var select : AudioStream = preload("res://Assets/Audio/SFX/UI/select.wav")
var confirm : AudioStream = preload("res://Assets/Audio/SFX/UI/confirm.wav")
var select2 : AudioStream = preload("res://Assets/Audio/SFX/UI/select.wav")

#Ambience
var light_rain : AudioStream = preload("res://Assets/Audio/Ambience/light_rain.mp3")

const MUSIC_MAX = {"online":-14.0,"title":-4.0,"day":-7.0,"castle":-11.0,"dungeon":-5.0,"mines":0.0}
const sfx_volume = {"back":10.0,"confirm":-5.0,"select":15.0,"select2":15.0,"light_rain":-7.0}
const sfx_pitch = {"back":1.0,"confirm":1.0,"select":1.0,"select2":2.0,"light_rain":0.8}

@onready var music = $Music 
@onready var sfx = $SFX 
func _ready():
	var tween = create_tween()
	tween.tween_property(music, "volume_db",MUSIC_MAX["title"],1.0)
	tween.play()

@warning_ignore("shadowed_variable")
func lower_sfx_volume(sfx):
	var node = music.get_node_or_null(sfx)
	node.volume_db = sfx_volume[sfx] - 20.0
	node.pitch_scale = sfx_pitch[sfx] - 0.6
	
func reset_sfx_volume(sfx_name):
	var node = sfx.get_node_or_null(sfx_name)
	node.volume_db = sfx_volume[sfx_name]
	node.pitch_scale = sfx_pitch[sfx_name]

func change_music(stream_name):
	var tween = create_tween()
	tween.tween_property(music, "volume_db",-80,0.0)
	tween.play()
	await tween.finished
	music.set_stream(get(stream_name))
	music.play()
	create_tween()\
	.tween_property(music, "volume_db",MUSIC_MAX[stream_name],0.0)

func play_sfx(sfx_file:AudioStream,fade_in = false):
	var sfx_node = AudioStreamPlayer.new()
	sfx_node.name = sfx_file.resource_name.get_basename()
	sfx_node.set_stream(sfx_file)
	sfx_node.mix_target = AudioStreamPlayer.MIX_TARGET_SURROUND
	sfx_node.bus = &"SFX"
	sfx_node.pitch_scale = sfx_pitch[sfx_file]
	
	sfx.add_child(sfx_node)
	
	if fade_in:
		sfx.volume_db = -80.0
		create_tween()\
		.tween_property(sfx_node, "volume_db",sfx_volume[sfx_file],1.0)
	else:
		sfx_node.volume_db = sfx_volume[sfx_file]
	
	sfx_node.play()
	
	if not fade_in:
		await sfx_node.finished
		sfx_node.queue_free()

func get_sfx(sfx_name : String) -> AudioStreamPlayer:
	return sfx.get_node_or_null(sfx_name)

func is_sfx_playing(sfx_name : String) -> bool:
	return get_sfx(sfx_name).is_playing()
	
func is_music_playing() -> bool:
	return music.is_playing()

func stop_sfx(sfx_name,fade_out = false):
	var sfx_node = sfx.get_node_or_null(sfx_name)
	if fade_out:
		await create_tween()\
		.tween_property(sfx, "volume_db",-80.0,1.0)\
		.finished
		
	if sfx_node != null:
		sfx_node.stop()
		sfx_node.queue_free()
