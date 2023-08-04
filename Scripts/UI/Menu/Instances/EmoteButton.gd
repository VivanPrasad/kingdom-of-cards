extends Button

var id : int
var emote_name : String
func _ready():
	$Icon.frame = id
	$Name.text = emote_name
	if emote_name == "Roll Me":
		$Name.modulate = Color("bc69ff")
func _on_pressed():
	if id != 11:
		$"../../..".play_emote(id)
	else:
		$"../../..".play_emote(randi_range(6,12))
