extends Node

@export var second : int = 14400
@export var minute : int = 0
@export var hour : int = 0
@export var day : int = 1

@export_enum("am","pm") var meridiem : String = "am"

var day_processed : bool = true
var lights_processed : bool = true
var hunger_processed : bool = true

var speed : int = 350 #100 = 1 irl second is 1 minute

@onready var world = $"../.."
@onready var hour_label := $MarginContainer/Hour
@onready var day_label := $MarginContainer/Day

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if hour == 0 and day_processed == false and speed > 0:
		start_new_day()
	if day_processed:
		if hour > 4 and hour < 22: 
			speed = 425 #5am to 10pm; 17 hours in 5 minutes
		else:
			speed = 700 #11pm to 5am; 7 hours in 2 minute
	
	if hour == 23:
		day_processed = false
	
	if (hour == 7 or hour == 17):
		lights_processed = false
		if day != 1: hunger_processed = false
	if (hour == 8 or hour == 18):
		if lights_processed == false:
			lights_processed = true
			update_lights()
		if hunger_processed == false:
			hunger_processed = true
			#update_hunger()
		
	second += int(floor(delta*speed))
	minute = int(second / 60.0) % 60
	hour = int(second / 3600.0) % 24
	meridiem = ["am","pm"][int(hour >= 12 and hour < 24)]
	
	update_labels()

"""
func update_hunger():
	if player.hunger > 0:
		player.hunger -= 1
	else:
		player.status = 1
		print(player.life)
	player.update_HUD()
"""

func update_lights():
	if hour == 8:
		world.toggle_lights(false)
	elif hour == 18:
		world.toggle_lights(true)

func update_labels():
	day_label.text = "Day " + str(day)
	if hour == 0 or hour == 12:
		hour_label.text = " ".join(["12",meridiem])
	else:
		hour_label.text = " ".join([str(hour % 12),meridiem])

func start_new_day():
	second = 0; minute = 0; hour = 0; day += 1
	day_processed = true
