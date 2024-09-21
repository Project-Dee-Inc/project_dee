extends "res://Scripts/skill_component.gd"
class_name BullRush

var damage:int = 0
var cd:float = 0
var skill_is_active:bool = false
var speed_multiplier:float = 0

func _ready():
	_get_values()
	_set_values()

func _assign_new_values(new_stat_dict:Dictionary):
	_get_new_values(new_stat_dict)
	_set_values()

func _get_new_values(new_stat_dict:Dictionary):
	stat_dict = new_stat_dict

# Get needed values
func _set_values():
	damage = stat_dict[Constants.get_enum_name_by_value(Constants.STATS.ATK)]
	cd = stat_dict[Constants.get_enum_name_by_value(Constants.STATS.CD)]
	speed_multiplier = stat_dict[Constants.get_enum_name_by_value(Constants.STATS.MOVE_SPD)]

# Set target to reference to the node's health component
func _set_target(value:Node):
	target = value.health_component

func _activate_skill():
	attacking = true
	skill_is_active = true

# On deactivate, wait for cd seconds
# If node is still in scene, reactivate skill so that it goes on a loop
func _deactivate_skill():
	attacking = false
	skill_is_active = false

# If target is hit by the collider, deal damage
func _on_hit_collider_component_body_entered(_body):
	if(skill_is_active):
		target._damage(damage)
		skill_is_active = false

func _get_extended_position(player: Node3D, body:Node3D, offset_distance: float = 100) -> Vector3:
	var initial_direction = (player.global_transform.origin - body.global_transform.origin).normalized()

	# Extend the target position by the offset distance along the initial direction
	var extended_target_position = player.global_transform.origin + (initial_direction * offset_distance)

	# Check for closest walkable position
	var nav_map = GameManager.navregion.get_navigation_map()
	var closest_position = NavigationServer3D.map_get_closest_point(nav_map, extended_target_position)

	# Check if the generated position is walkable
	if !Constants._is_position_walkable(nav_map, closest_position):
		closest_position = initial_direction

	return closest_position
