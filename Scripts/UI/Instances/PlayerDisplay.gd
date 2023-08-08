extends HBoxContainer

var player_name : String
var icon : String

func _ready():
	$MarginContainer/TextureRect.frame = int(icon)
	$Label.text = player_name
