extends "res://Scripts/skill_component.gd"
class_name DamageOnContact

var damage:int = 0
var cd:float = 0
var skill_is_active:bool = false

func _ready():
	_get_values()
	_set_values()

# Get needed values
func _set_values():
	damage = stat_dict[Constants.get_enum_name_by_value(Constants.STATS.ATK)]
	cd = stat_dict[Constants.get_enum_name_by_value(Constants.STATS.CD)]

# Set target to reference to the node's health component
func _set_target(value:Node):
	target = value.health_component

func _activate_skill():
	skill_is_active = true

# On deactivate, wait for cd seconds
# If node is still in scene, reactivate skill so that it goes on a loop
func _deactivate_skill():
	skill_is_active = false
	await get_tree().create_timer(cd).timeout
	if (is_instance_valid(self)):
		_activate_skill()

# If target is hit by the collider, deal damage
func _on_hit_collider_component_body_entered(_body):
	if(skill_is_active):
		target._damage(damage)
		_deactivate_skill()
