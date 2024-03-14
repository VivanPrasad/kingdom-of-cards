class_name GameTime
extends Node

static var second : int = 3600 * 5
static var minute : int = 0
static var hour : int = 5
static var day : int = 1

static var weather : String = "Normal"
static var weather_change
static var meridiem : String = "am"

static var day_processed : bool = true
static var lights_processed : bool = true
static var hunger_processed : bool = true
static var weather_processed : bool = false

const DAY_SPEED : int = 240
const NIGHT_SPEED : int = 280

const SECOND_TO_HOUR : float = (1/3600.0)
const SECOND_TO_MINUTE : float = (1/60.0)
const HOUR_TO_SECOND : float = 3600.0

const MAX_SEC_MIN : int = 60
const MAX_HOUR : int = 24
#Not inclusive start and end times for day
const DAY_FIRST_HOUR : int = 5
const DAY_FINAL_HOUR : int = 21

enum TIME {MIDNIGHT=0,NOON=12} 
static var speed : int = DAY_SPEED #60 = 1 irl second is 1 minute

@onready var world = $"../.."
@onready var hour_label := $MarginContainer/Hour
@onready var day_label := $MarginContainer/Day

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if get_tree().paused: return
	if hour==TIME.MIDNIGHT and not day_processed and speed>0:
		start_new_day()
	if day_processed:
		if hour>=DAY_FIRST_HOUR and hour<=DAY_FINAL_HOUR: 
			speed = DAY_SPEED #5am-10pm; 18 hours in 4.5 minutes
		else:
			speed = NIGHT_SPEED #10pm-5am; 7 hours in 1.5 minutes
	
	if hour==(TIME.NOON-1):
		hunger_processed = false
	if hour == (MAX_HOUR-1):
		hunger_processed = false
		day_processed = false

	if hour == TIME.NOON or hour == TIME.MIDNIGHT:
		if hunger_processed == false:
			hunger_processed = true
			update_hunger()
	
	if hour == 5:
		weather_processed = false
	if hour == 6 and not weather_processed:
		if Global.player_id in ["1","Entities/Player"]:
			weather = ["HeavyRain","Normal","BloodMoon"].pick_random() #"HeavyRain"
			weather_processed = true
	
	second += int(floor(delta*speed))
	minute = int(second * SECOND_TO_MINUTE) % MAX_SEC_MIN
	hour = int(second * SECOND_TO_HOUR) % MAX_HOUR
	meridiem = ["am","pm"][int(hour >= TIME.NOON and hour < MAX_HOUR)]
	world.weather = weather
	update_labels()

func update_hunger():
	var player = world.get_node_or_null(Global.player_id)
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
	second=0; minute=0; hour=0; 
	day += 1
	day_processed = true
