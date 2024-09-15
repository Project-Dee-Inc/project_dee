extends "res://Scripts/skill_component.gd"
class_name ShootProjectiles

@export var projectile_obj:PackedScene

var projectile_count:int = 1
var cd:float = 0
var damage:int = 0
var proj_speed:int = 0

var skill_is_active:bool = false
var can_activate:bool = true
var is_homing:bool = false
var has_stats:bool = false
var base_node:Node3D

func _ready():
	base_node = get_parent().get_parent()
	_get_values()
	_set_values()

func _assign_new_values(new_stat_dict:Dictionary):
	_get_new_values(new_stat_dict)
	_set_values()

func _get_new_values(new_stat_dict:Dictionary):
	stat_dict = new_stat_dict

func _set_values():
	cd = stat_dict[Constants.get_enum_name_by_value(Constants.STATS.CD)]
	projectile_count = stat_dict[Constants.get_enum_name_by_value(Constants.STATS.PROJ_COUNT)]
	damage = stat_dict[Constants.get_enum_name_by_value(Constants.STATS.ATK)]
	proj_speed = stat_dict[Constants.get_enum_name_by_value(Constants.STATS.PROJ_SPD)]

func _set_target(value:Node):
	target = value

# Set behavior for projectile, homing or normal
func _set_homing(value:bool):
	is_homing = value

func _activate_skill():
	skill_is_active = true

func _deactivate_skill():
	skill_is_active = false

# If skill is active and within cd intervals, spawn projectile
func _physics_process(_delta: float):
	if (projectile_obj):
		if(skill_is_active && can_activate):
			attacking = true
			_start_projectiles()
		else:
			attacking = false

# Instantiate a copy of the base projectile scene based on how many projectiles to create at once
func _start_projectiles():
	can_activate = false
	var projectile_node = get_parent().parent_component
	var direction = Constants._get_direction(target.global_transform.origin, projectile_node.global_transform.origin)
	# Store base direction in case there's multiple projectiles
	var base_direction = direction

	# If more than 1 projectiles, create with offsets
	if(projectile_count > 1):
		# Total spread angle (in radians) - Adjust as needed
		var total_spread_angle = 0.5
		# Calculate the angle step based on the number of projectiles
		var angle_step = total_spread_angle / max(1, projectile_count - 1)

		# Calculate the direction with an offset for non-homing projectiles
		for i in range(projectile_count):
			if i < projectile_count / 2:
				# Left-side projectiles
				var angle_offset = -angle_step * (projectile_count / 2 - i)
				direction = direction.rotated(Vector3.UP, angle_offset)
			elif i > projectile_count / 2:
				# Right-side projectiles
				var angle_offset = angle_step * (i - projectile_count / 2)
				direction = direction.rotated(Vector3.UP, angle_offset)
			else:
				direction = base_direction

			_spawn_projectile(projectile_node.global_transform.origin, target, direction)
	# Else, just spawn one normally
	else:
		_spawn_projectile(projectile_node.global_transform.origin, target, direction)

	# Await for cd interval before looping and creating another instance
	await get_tree().create_timer(cd).timeout
	can_activate = true

# Spawn one instance of projectile towards a target node and position
func _spawn_projectile(location:Vector3, target_node:Node3D, target_pos:Vector3 = Vector3(0,0,0)):
	var projectile = projectile_obj.instantiate() as Node3D

	get_parent().add_child(projectile)
	projectile.global_transform.origin = location

	# Set collision layer to 1, the same as environment
	projectile._set_collision_layer(Constants.TARGETS.NEUTRAL)
	# Set collision mask so that it only detects player
	projectile._set_collision_masks(Constants.TARGETS.PLAYER)
	# Set projectile damage and speed values
	projectile._set_damage(damage)
	projectile._set_speed(proj_speed)

	# Set behavior if projectile is homing or not
	projectile.is_homing = is_homing
	# Start moving to target
	if(!is_homing):
		projectile._shoot(projectile, base_node, target_node, target_pos)
	else:
		projectile._shoot(projectile, base_node, target_node)
