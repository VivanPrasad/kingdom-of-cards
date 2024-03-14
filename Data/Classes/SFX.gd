class_name SFX
extends AudioStreamPlayer

const SELECT : AudioStream = preload("res://Assets/Audio/SFX/UI/select.wav")
const BACK : AudioStream = preload("res://Assets/Audio/SFX/UI/back.wav")
const CONFIRM : AudioStream = preload("res://Assets/Audio/SFX/UI/confirm.wav")

const VOLUME_DATA = {
	"back":10.0,
	"confirm":-8.0,
	"select":10.0,
	"light_rain":-7.0}
const PITCH_DATA = {
	"back":1.0,
	"confirm":1.06,
	"select":1.1,
	"light_rain":0.8}

var stream_name : String
func _init(file : AudioStream,volume_offset:float = 0.0, pitch_offset : float = 0.0, fade_in : bool = false, fade_time : float = 1.0) -> void:
	stream_name = Audio.get_file_name(file)
	self.name = stream_name
	self.stream = file
	self.mix_target = AudioStreamPlayer.MIX_TARGET_SURROUND
	self.bus = &"SFX"
	self.pitch_scale = PITCH_DATA[stream_name] + pitch_offset
	
	if fade_in:
		volume_db = -80.0
		create_tween()\
		.tween_property(self, "volume_db",
			VOLUME_DATA[stream_name]+volume_offset,fade_time)
	else:
		volume_db = VOLUME_DATA[stream_name] + volume_offset
