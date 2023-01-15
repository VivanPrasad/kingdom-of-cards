extends Node

@export var second : int = 14400
@export var minute : int = 0
@export var hour : int = 0
@export var day : int = 1

var day_processed : bool = true
var speed = 350 #100 = 1 irl second is 1 minute ig
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if hour == 0 and day_processed == false and speed > 0:
		start_new_day()
	if day_processed:
		if hour > 4 and hour < 22: 
			speed = 425 #5am to 10pm; 17 hours in 4 minutes
		else:
			speed = 700#11pm to 5am; 7 hours in 1 minute
		#day = 4 minutes
		#night = 1 minute
	second += int(floor(delta*speed))
	minute = int(second / 60.0) % 60
	hour = int(second / 3600.0) % 24
	update_labels()

func update_labels():
	$MarginContainer/Day.text = "Day " + str(day)
	if hour < 12:
		if hour == 0:
			$MarginContainer/Hour.text = "12 am"
		else:
			$MarginContainer/Hour.text = str(hour) + " am"
	else:
		if hour == 12:
			$MarginContainer/Hour.text = "12 pm"
		else:
			$MarginContainer/Hour.text = str(hour % 12) + " pm"
func start_new_day():
	second = 0; minute = 0; hour = 0; day += 1
	day_processed = true
