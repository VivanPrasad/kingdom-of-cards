extends Control

@onready var card_display = preload("res://Scenes/UI/Instances/CardDisplay.tscn")
@onready var player = $"/root/World/Entities/Player"

func _ready():
	get_inventory()

func get_inventory(): #gets the inventory size
	for item in player.inventory:
		var card = card_display.instantiate()
		card.data = player.inventory[player.inventory.find(item)]
		$CenterContainer/GridContainer.add_child(card)
