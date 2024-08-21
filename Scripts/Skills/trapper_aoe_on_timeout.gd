extends "res://Scripts/Skills/aoe_on_timeout.gd"
class_name TrapperAoeOnTimeout

@export var debuff_stat_component:Node
var debuff_stat_dict:Dictionary = {}
var debuff_value:float = 0
var debuff_stat:Constants.STATS

func _get_values():
	super._get_values()
	debuff_stat_dict = debuff_stat_component.stat_dict

func _set_values():
	super._set_values()
	var key = debuff_stat_dict.keys()[1]
	debuff_value = debuff_stat_dict[key]
	debuff_stat = Constants.get_enum_value_by_name(key)
	#print("KEY IS ", key)
	#print("STAT IS ", debuff_stat)

func _set_aoe_values(hit_collider:Area3D):
	hit_collider._set_values(cd, debuff_value)
	hit_collider._set_aoe_damage_type(false, debuff_stat)
	hit_collider._set_collider_radius(radius)
	hit_collider._set_collision_layer(Constants.TARGETS.ENEMY)
	hit_collider._set_collision_masks(Constants.TARGETS.PLAYER)
	hit_collider._enable_character_bodies()
	hit_collider._enable_collider(true)
