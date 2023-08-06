extends Control

@onready var emote_button := preload("res://Scenes/UI/Instances/EmoteButton.tscn")

const emote_name : Array[String] = [
	"Happy","Meh","Sad","Look","HI","OK","Bread","Banana","Berries","Eaten","Skull","Medicine","No","Yes","Gold","Good","Ill","Immune","Servant","Guard","Farmer","Miner","Fisher","Logger","Sus","Ayo","Hehe",":3","Poopy","Royal","Flushed",":P","Coolio","Teehee","Sob","Eyes","Player","Go Up","Go Down","Go Left","Go Right","Star","E","Thank You","No Problem","?","Panda","Progress"]
const emote_range = [0,]
@onready var container := $CenterContainer/GridContainer
func _ready():
	for id in range(12,60,1):
		var emote = emote_button.instantiate()
		emote.id = id
		emote.emote_name = emote_name[id - 12]
		container.add_child(emote)
	var dice_emote = emote_button.instantiate()
	dice_emote.id = 11
	dice_emote.emote_name = "Roll Me"
	container.add_child(dice_emote)

func play_emote(id):
	$"../..".play_emote.rpc(id)
	queue_free()
