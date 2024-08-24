extends "res://Scripts/skill_component.gd"
class_name BuffOnAoe

@export var aoe_collision_shape:CollisionShape3D
@export var buff_stat_component:Node

var buff_stat_dict:Dictionary = {}
var cd:float = 0
var radius:float = 0
var skill_is_active:bool = false

func _ready():
	_get_values()
	_set_values()

func _get_values():
	super._get_values()
	buff_stat_dict = buff_stat_component.stat_dict

# Get needed values
func _set_values():
	cd = stat_dict[Constants.get_enum_name_by_value(Constants.STATS.CD)]
	radius = stat_dict[Constants.get_enum_name_by_value(Constants.STATS.AOE)]
	_set_collider_radius(radius)

# Set collider shape radius based on AOE
func _set_collider_radius(value:float):
	var sphere_shape = aoe_collision_shape.shape as SphereShape3D
	sphere_shape.radius = value

# Enable or disable skill and wait for cd before next
func _activate_skill():
	skill_is_active = true

	await get_tree().create_timer(0.2).timeout
	if (is_instance_valid(self)):
		_deactivate_skill()

func _deactivate_skill():
	skill_is_active = false

	await get_tree().create_timer(cd).timeout
	if (is_instance_valid(self)):
		_activate_skill()

# If ally within collider, buff
func _on_aoe_hit_collider_area_entered(area: Area3D):
	if(skill_is_active):
		print(area.get_parent().name, " ENTERED AREA")
