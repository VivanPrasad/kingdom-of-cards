extends Resource
class_name Card

@export var name : String = "Card"
@export_range(0,126) var icon_id : int = 83
@export_enum("Food", "Item", "Golden", "Material", "Attire", "Role", "Tool", "Other") var type : int
@export var amount : int = 1
@export_multiline var desc : String

@export_category("Properties")

@export_enum("Use","Equip","Hold") var clicked : String = "Use"

@export_group("Object Reference","object_")
@export var object_variables : Dictionary #key:value -> gets variable:sets variable
@export var object_functions : Dictionary #key:value -> calls function:parameters (either string, int or array for data)

@export_group("Role","role_")
@export var role_goal : String
@export var role_exp : int = 0
@export var role_level: int

@export_category("Economy")
@export_range(0, 20) var base_cost : int = 0
@export_flags("Food","Item","Secret","Merchant") var markets = 0
@export_range(1.0,100.0,1.0,"suffix:%") var rarity = 100

static func new_card(card_name : String) -> Card:
	var file_path = "res://Data/Cards/" + card_name + ".tres"
	if FileAccess.file_exists(file_path):
		return load(file_path).duplicate()
	
	push_error("Unable to create using premade card name")
	return null

func _init(n = null,id = null,des = null,typ=null,click=null) -> void:
	if n != null: self.name = n
	if id != null: self.icon_id = id
	if des != null: self.desc = des
	if typ != null: self.type = typ
	if click != null: self.clicked = click
	#if "gain_life" in properties["use"].keys():
	#	print("gain life from card")
