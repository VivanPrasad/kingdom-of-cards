extends Node

@export var second : int = 3600 * 5
@export var minute : int = 0
@export var hour : int = 5
@export var day : int = 1

@export_enum("am","pm") var meridiem : String = "am"

var day_processed : bool = true
var lights_processed : bool = true
var hunger_processed : bool = true

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
			speed = 240  #5am-10pm; 18 hours in 4.5 minutes
		else:
			speed = 280 #10pm-5am; 7 hours in 1.5 minutes
	
	if hour == 23:
		day_processed = false
		
		if day != 1: hunger_processed = false
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

func update_labels():
	day_label.text = "Day " + str(day)
	if hour == 0 or hour == 12:
		hour_label.text = " ".join(["12",meridiem])
	else:
		hour_label.text = " ".join([str(hour % 12),meridiem])

func start_new_day():
	second = 0; minute = 0; hour = 0; day += 1
	day_processed = true
