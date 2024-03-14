extends Node

#Music


#Ambience
const LIGHT_RAIN : AudioStream = preload("res://Assets/Audio/Ambience/light_rain.mp3")

@onready var music = $Music 
@onready var sfx = $SFX

func _ready():
	create_tween().tween_property(music, "volume_db",Music.MUSIC_MAX["title"],1.0)
func lower_sfx_volume(sfx_name):
	var node_arr = []
	for node in sfx.get_children():
		if node.stream_name == sfx_name:
			node_arr.append(node)
	
	for node in node_arr:
		(node as SFX).volume_db = SFX.VOLUME_DATA[sfx_name] - 20.0
		(node as SFX).pitch_scale = SFX.PITCH_DATA[sfx_name] - 0.6
	
func reset_sfx_volume(sfx_name):
	var node_arr = []
	for node in sfx.get_children():
		if node.stream_name == sfx_name:
			node_arr.append(node)
	
	for node in node_arr:
		(node as SFX).volume_db = SFX.VOLUME_DATA[sfx_name]
		(node as SFX).pitch_scale = SFX.PITCH_DATA[sfx_name]

func change_music(music_file : AudioStream):
	music.set_stream(music_file)
	var music_name = get_file_name(music_file)
	music.volume_db = Music.MUSIC_MAX[music_name]
	music.play()

func play_sfx(sfx_file:AudioStream,volume_offset:float = 0.0, 
pitch_offset:float = 0.0 ,fade_in = false, fade_time : float = 1.0):
	var node = SFX.new(sfx_file,volume_offset, pitch_offset, fade_in, fade_time)
	sfx.add_child(node)
	node.play()
	if not fade_in:
		await node.finished
		node.queue_free()

func get_sfx(sfx_name : String) -> SFX:
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

func get_file_name(audio_file : AudioStream) -> String:
	return audio_file.resource_path.get_file().get_basename()
