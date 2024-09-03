extends "res://Scripts/status_manager.gd"
class_name WeaponStatManager

@export var melee_stat: StatComponent
@export var magic_stat: StatComponent
@export var range_stat: StatComponent

var heart:Constants.WEAPON_TYPES = Constants.WEAPON_TYPES.MELEE

func _buff_base_stat(stat:Constants.STATS, stackable:bool, value:float):
	if(base_stat[Constants.get_enum_name_by_value(stat)] > 0 or stackable == false):
		base_stat[Constants.get_enum_name_by_value(stat)] += value

func _buff_weapon_stat(weapon_type:Constants.WEAPON_TYPES, stat:Constants.STATS, stackable:bool, value:float):
	match weapon_type:
		Constants.WEAPON_TYPES.MELEE:
			if(!stackable or melee_stat[Constants.get_enum_name_by_value(stat)] > 0):
				base_stat[Constants.get_enum_name_by_value(stat)] += value
		Constants.WEAPON_TYPES.RANGE:
			if(!stackable or range_stat[Constants.get_enum_name_by_value(stat)] > 0):
				range_stat[Constants.get_enum_name_by_value(stat)] += value
		Constants.WEAPON_TYPES.MAGIC:
			if(!stackable or magic_stat[Constants.get_enum_name_by_value(stat)] > 0):
				magic_stat[Constants.get_enum_name_by_value(stat)] += value

func _debuff_weapon_stat(weapon_type:Constants.WEAPON_TYPES, stat:Constants.STATS, value:float):
	match weapon_type:
		Constants.WEAPON_TYPES.MELEE:
			melee_stat[Constants.get_enum_name_by_value(stat)] = min(melee_stat[Constants.get_enum_name_by_value(stat)] - value, 0)
		Constants.WEAPON_TYPES.RANGE:
			range_stat[Constants.get_enum_name_by_value(stat)] = min(range_stat[Constants.get_enum_name_by_value(stat)] - value, 0)
		Constants.WEAPON_TYPES.MAGIC:
			magic_stat[Constants.get_enum_name_by_value(stat)] = min(magic_stat[Constants.get_enum_name_by_value(stat)] - value, 0)

func _debuff_base_stat(stat:Constants.STATS, value:float):
	base_stat[Constants.get_enum_name_by_value(stat)] = min(base_stat[Constants.get_enum_name_by_value(stat)] - value, 0)
