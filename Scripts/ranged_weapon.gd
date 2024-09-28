extends Node3D

@export var projectile_obj:PackedScene

var cd:float = 0
@export var is_homing:bool = false
@onready var stat_component = $"../StatManager"

var enemies = []
var stat_dict: Dictionary = {}
var _shoot_timer: float = 0.0

# Projectile properties
var projectile_count: int
var damage: float
var projectile_speed: float

func _ready():
	stat_dict = stat_component.stat_dict
	_set_values()
	
func _set_values():
	cd = stat_dict[Constants.get_enum_name_by_value(Constants.STATS.CD)]
	projectile_count = stat_dict[Constants.get_enum_name_by_value(Constants.STATS.PROJ_COUNT)]
	damage = stat_dict[Constants.get_enum_name_by_value(Constants.STATS.ATK)]
	projectile_speed = stat_dict[Constants.get_enum_name_by_value(Constants.STATS.PROJ_SPD)]

# Set behavior for projectile, homing or normal
func _set_homing(value:bool):
	is_homing = value

# If skill is active and within cd intervals, spawn projectile
func _physics_process(_delta: float):
	if (projectile_obj):
		_shoot_timer -= _delta
		if _shoot_timer <= 0:
			enemies = get_tree().get_nodes_in_group("enemies")
			var nearest_enemy = get_nearest_enemies(10, 1) #Get the nearest enemy only
			if nearest_enemy.size() > 0:
				var nearest_enemy_direction = (nearest_enemy[0].global_transform.origin - global_transform.origin).normalized() #Get the normalized direction
				var base_direction = nearest_enemy_direction
			
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
							nearest_enemy_direction = nearest_enemy_direction.rotated(Vector3.UP, angle_offset)
						elif i > projectile_count / 2:
							# Right-side projectiles
							var angle_offset = angle_step * (i - projectile_count / 2)
							nearest_enemy_direction = nearest_enemy_direction.rotated(Vector3.UP, angle_offset)
						else:
							nearest_enemy_direction = base_direction

						_spawn_projectile(nearest_enemy[0], nearest_enemy_direction)
				# Else, just spawn one normally
				else:
					_spawn_projectile(nearest_enemy[0], nearest_enemy_direction)
			
			#_spawn_projectile()
			# Reset the timer
			_shoot_timer = cd

# Instantiate a copy of the base projectile scene
func _spawn_projectile(target: Node3D, target_pos:Vector3 = Vector3(0,0,0)):
		
		var projectile = projectile_obj.instantiate() as Node3D
	
		get_tree().root.add_child(projectile)
		projectile.global_transform.origin = global_transform.origin
		#projectile.scale = Vector3(0.5, 0.5, 0.5)

		# Set collision layer to 1, the same as environment
		projectile._set_collision_layer(Constants.TARGETS.NEUTRAL)
		# Set collision mask so that it only detects player
		projectile._set_collision_masks(Constants.TARGETS.ENEMY)
		
		projectile._set_damage(damage)
		projectile._set_speed(projectile_speed)

		# Set behavior if projectile is homing or not
		projectile.is_homing = is_homing
		# Start moving to target
		if(!is_homing):
			projectile._shoot(projectile, get_parent(), target, target_pos)
		else:
			projectile._shoot(projectile, get_parent(), target)
	
func get_nearest_enemies(max_distance: float, max_count: int) -> Array:
	var nearby_enemies = []
	
	# Filter enemies within the given max_distance
	for enemy in enemies:
		var distance = global_position.distance_to(enemy.global_position)
		if distance <= max_distance:
			nearby_enemies.append({"enemy": enemy, "distance": distance})
	
	# Sort enemies by distance (closest first) using the custom sort function
	nearby_enemies.sort_custom(Callable(self, "_sort_by_distance"))
	
	# Return up to max_count nearest enemies
	var result = []
	for i in range(min(max_count, nearby_enemies.size())):
		result.append(nearby_enemies[i]["enemy"])
	
	return result
