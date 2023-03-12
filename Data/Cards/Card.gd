extends Resource
class_name Card

@export var name : String
@export var icon : Texture
@export_multiline var desc : String
@export_enum("Food", "Item", "Golden", "Material", "Attire", "Role", "Tool", "Other") var type : int

@export_category("Properties")
@export_range(0, 20) var base_cost : int
@export_group("Usage","use_")

@export var properties : Dictionary = {
	"use":{},
	"hold":{},
	"drop":{}
}

func use():
	for command in properties["use"].keys():
		if command == "gain_life":
			print("You gain " + str(properties["use"][command]) + "health.")
	
func _init(hello = null) -> void:
	#print(hello)
	if "gain_life" in properties["use"].keys():
		print("gain life from card")

