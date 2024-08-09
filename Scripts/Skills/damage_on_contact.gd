extends "res://Scripts/skill_component.gd"
class_name DamageOnContact

@onready var skill_manager_component = $".."
var can_attack:bool = false
var damage:int = 0
var cd:int = 0

func _ready():
	_get_values()
	_set_values()

func _set_values():
	damage = stat_dict[Constants.get_enum_name_by_value(Constants.STATS.ATK)]
	cd = stat_dict[Constants.get_enum_name_by_value(Constants.STATS.CD)]

func _set_target(value:Node):
	#target = value.get_node("HealthComponent")
	pass

func _activate_skill():
	print("Damage On Contact activated");
	#target.damage(damage)

func _deactivate_skill():
	pass
