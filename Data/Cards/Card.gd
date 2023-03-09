extends Resource
class_name Card

@export var name : String
@export var icon : Texture
@export var desc : String
@export_enum("Food", "Item", "Golden", "Material", "Attire", "Role", "Tool", "Other") var type

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
	print(hello)
	if "gain_life" in properties["use"].keys():
		print("hi")

