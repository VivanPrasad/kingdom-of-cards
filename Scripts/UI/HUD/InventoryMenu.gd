extends Control

@onready var card_display = preload("res://Scenes/UI/Instances/CardDisplay.tscn")
var player : Node 

func _ready():
	player = $"/root/World".get_node_or_null(Global.player_id)
	get_inventory()

func get_inventory(): #gets the inventory size
	for item in player.inventory:
		var card = card_display.instantiate()
		card.data = player.inventory[player.inventory.find(item)]
		$CenterContainer/GridContainer.add_child(card)
