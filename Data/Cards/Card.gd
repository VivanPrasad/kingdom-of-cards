extends Resource
class_name Card

@export var name : String
@export var icon_id : int = 83
@export_enum("Food", "Item", "Golden", "Material", "Attire", "Role", "Tool", "Other") var type : int
@export_multiline var desc : String

@export_category("Properties")

@export_enum("Use","Equip","Hold") var clicked : String = "Use"

@export_group("Object Reference","object_")
@export_enum("Player") var object_name : String = "Player"
@export var object_variables : Dictionary #key:value -> gets variable:sets variable
@export var object_functions : Dictionary #key:value -> calls function:parameters (either string, int or array for data)
#get("life"):get("life") + 1

@export_group("Role","role_")
@export var role_goal : String
@export var role_exp : int = 0
@export var role_level: int

@export_category("Economy")
@export_range(0, 20) var base_cost : int = 0
@export_flags("Food","Item","Secret","Merchant") var markets = 0
@export_range(1.0,100.0,1.0,"suffix:%") var rarity = 100

func _init(n = null,id = null,des = null) -> void:
	if n != null: self.name = n
	if id != null: self.icon_id = id
	if des != null: self.desc = des
	#if "gain_life" in properties["use"].keys():
	#	print("gain life from card")

