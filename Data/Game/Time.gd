extends Node
class_name GameTime

@export var second : int = 3600 * 5
@export var minute : int = 0
@export var hour : int = 5
@export var day : int = 1
@export var weather : String = "Normal"

@export_enum("am","pm") var meridiem : String = "am"

var day_processed : bool = true
var lights_processed : bool = true
var hunger_processed : bool = true
var weather_processed : bool = false
var speed : int = 350 #60 = 1 irl second is 1 minute


@onready var world = $"../.."
@onready var hour_label := $MarginContainer/Hour
@onready var day_label := $MarginContainer/Day

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if get_tree().paused: return
	if hour == 0 and day_processed == false and speed > 0:
		start_new_day()
	if day_processed:
		if hour > 4 and hour < 22: 
			speed = 240 #5am-10pm; 18 hours in 4.5 minutes
		else:
			speed = 280 #10pm-5am; 7 hours in 1.5 minutes
	
	if hour == 11 or hour == 23:
		hunger_processed = false
		
	if hour == 12 or hour == 0:
		if hunger_processed == false:
			hunger_processed = true
			update_hunger()
			
	if hour == 5:
		weather_processed = false
	if hour == 6 and weather_processed == false:
		if Global.player_id in ["1","Entities/Player"]:
			weather = ["HeavyRain","Normal","BloodMoon"].pick_random() #"HeavyRain"
			weather_processed = true
	
	if hour == 23:
		day_processed = false
	
	second += int(floor(delta*speed))
	minute = int(second / 60.0) % 60
	hour = int(second / 3600.0) % 24
	meridiem = ["am","pm"][int(hour >= 12 and hour < 24)]
	world.weather = weather
	update_labels()

func update_hunger():
	var player = $"/root/World".get_node_or_null(Global.player_id)
	if player.hunger > 0:
		player.hunger -= 1
	elif player.status != 1:
		player.status = 1
	else:
		var n = randi() % 4
		if n == 0 or n == 1:
			player.life -= 1
		elif n == 3:
			player.status = 0
	player.update_profile()


func update_labels():
	day_label.text = "Day " + str(day)
	if hour == 0 or hour == 12:
		hour_label.text = " ".join(["12",meridiem])
	else:
		hour_label.text = " ".join([str(hour % 12),meridiem])

func start_new_day():
	second = 0; minute = 0; hour = 0; day += 1
	day_processed = true
