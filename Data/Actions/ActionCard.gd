extends Resource
class_name ActionCard

@export var name : String
@export var icon_id : int
@export_enum("Mobility","Attack","Buff") var type := "Buff"
@export_multiline var desc : String
@export_range(1.0,100.0,1.0,"suffix:%") var rarity = 100

@export_range(1.0,10.0,0.1,"suffix:s") var recharge_rate : float
