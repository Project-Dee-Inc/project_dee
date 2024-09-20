extends "res://Scripts/skill_component.gd"
class_name BuffAndSpawnMinions

@export var spawn_scene:PackedScene
@export var spawns_count:int = 15
var atk_buff:float = 0
var cd_buff:float = 0
var spd_buff:float = 0
var proj_count_buff:float = 0
var proj_spd_buff:float = 0
var skill_is_active:bool = false

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
	atk_buff = stat_dict[Constants.get_enum_name_by_value(Constants.STATS.ATK)]
	cd_buff = stat_dict[Constants.get_enum_name_by_value(Constants.STATS.CD)]
	spd_buff = stat_dict[Constants.get_enum_name_by_value(Constants.STATS.MOVE_SPD)]
	proj_count_buff = stat_dict[Constants.get_enum_name_by_value(Constants.STATS.PROJ_COUNT)]
	proj_spd_buff = stat_dict[Constants.get_enum_name_by_value(Constants.STATS.PROJ_SPD)]

# Set target to reference to the node's health component
func _set_target(value:Node):
	target = value.health_component

func _activate_skill():
	attacking = true
	skill_is_active = true

	await get_tree().create_timer(0.5).timeout
	if(is_instance_valid(self)):
		_spawn_minions()

func _spawn_minions():
	var half_past = false
	var base_node = get_parent().get_parent()
	for i in range(spawns_count):
		if(i < spawns_count/2 && !half_past):
			half_past = true
			await get_tree().create_timer(1.5).timeout

		var randomnum = Constants._get_rand()
		var spawn_location = base_node.movement_component._get_circle_position(base_node.global_transform.origin, randomnum)
		EventManager.raise_event(str(EventManager.EVENT_NAMES.ON_SPAWN_OBJECT), ["Enemy", spawn_scene, spawn_location])

	_deactivate_skill()

# On deactivate, wait for cd seconds
func _deactivate_skill():
	attacking = false
	skill_is_active = false
