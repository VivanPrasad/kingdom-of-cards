extends Control

@onready var emote_button := preload("res://Scenes/UI/Instances/EmoteButton.tscn")

const emote_name : Array[String] = [
	"Happy","Meh","Sad","Look","HI","OK","Bread","Banana","Berries","Eaten","Skull","Medicine","No","Yes","Gold","Good","Ill","Immune","Servant","Guard","Farmer","Miner","Fisher","Logger","Sus","Sus2","Hehe",":3","Flush","Poop"]
const emote_range = [0,]
@onready var container := $CenterContainer/GridContainer
func _ready():
	for id in range(12,42,1):
		var emote = emote_button.instantiate()
		emote.id = id
		emote.emote_name = emote_name[id - 12]
		container.add_child(emote)
	var dice_emote = emote_button.instantiate()
	dice_emote.id = 11
	dice_emote.emote_name = "Roll Me"
	container.add_child(dice_emote)
func _input(_event):
	if Input.is_action_just_pressed("ui_cancel"):
		$"../..".stop_thinking.rpc()
		queue_free()

func play_emote(id):
	$"../..".play_emote.rpc(id)
	queue_free()
