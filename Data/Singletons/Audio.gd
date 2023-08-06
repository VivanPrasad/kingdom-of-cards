extends Node

@onready var title = preload("res://Assets/Audio/Music/title.ogg")
@onready var online = preload("res://Assets/Audio/Music/online.ogg")

@onready var day = preload("res://Assets/Audio/Music/day.ogg")

const music_max = {"online":-10.0,"title":-2.0,"day":-2.0}

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

func is_music_playing():
	return $Music.is_playing()

