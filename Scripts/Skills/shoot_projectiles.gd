extends "res://Scripts/skill_component.gd"
class_name ShootProjectiles

@export var projectile_obj:PackedScene

var cd:float = 0
var skill_is_active:bool = false
var can_activate:bool = true
var is_homing:bool = false
var has_stats:bool = false

func _ready():
	_get_values()
	_set_values()

func _set_values():
	cd = stat_dict[Constants.get_enum_name_by_value(Constants.STATS.CD)]

func _set_target(value:Node):
	target = value

func _set_homing(value:bool):
	is_homing = value

func _activate_skill():
	skill_is_active = true

func _deactivate_skill():
	skill_is_active = false

func _physics_process(_delta: float):
	if (projectile_obj):
		if(skill_is_active && can_activate):
			_spawn_projectile()

func _spawn_projectile():
	can_activate = false
	var projectile = projectile_obj.instantiate() as Node3D
	var base_node = get_parent().parent_component

	projectile.global_transform.origin = base_node.global_transform.origin
	get_parent().add_child(projectile)
	projectile.scale = Vector3(0.5, 0.5, 0.5)

	projectile.is_homing = is_homing
	projectile._shoot(projectile, target)

	await get_tree().create_timer(cd).timeout
	can_activate = true
