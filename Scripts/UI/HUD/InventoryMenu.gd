extends Control

@onready var card_display = preload("res://Scenes/UI/CardDisplay.tscn")
@onready var player = $"/root/World/Entities/Player"

@onready var grid = $CenterContainer/GridContainer
func _ready():
	get_inventory()
	pass

func get_inventory(): #gets the inventory size
	for item in player.inventory:
		var card = card_display.instantiate()
		card.data = player.inventory[player.inventory.find(item)]
		grid.add_child(card)
