#extends Node3D
#
## Reference to the projectile scene
#@export var projectile_scene: PackedScene
#@export var shoot_interval: float = 3.0
#@export var speed: float = 1.0
#@export var damage_amount: int = 50 
#@export var penetrating_shot: bool = false
#
#var enemies = []
#var _shoot_timer: float = 0.0
#
#func _ready():
	## Initialize the timer
	#_shoot_timer = shoot_interval
#
#func _process(delta: float) -> void:
	## Update the shoot timer
	#_shoot_timer -= delta
	#if _shoot_timer <= 0:
		#enemies = get_tree().get_nodes_in_group("enemies")
		#shoot_projectile()
		## Reset the timeraaaa
		#_shoot_timer = shoot_interval
#
#func shoot_projectile() -> void:
	#if projectile_scene:
		#var dir: Vector3
		#var nearest_enemy_direction: Vector3 = Vector3.ZERO
		#
		#var projectile = projectile_scene.instantiate()
		#
		#var nearest_enemy = get_nearest_enemies(10, 1)
		#if nearest_enemy.size() > 0:
			#nearest_enemy_direction = (nearest_enemy[0].global_transform.origin - global_transform.origin).normalized() #Get the normalized direction
			#
		#projectile.global_transform.origin = global_position
		#projectile.look_at(global_transform.origin, Vector3.UP)
		#get_tree().root.add_child(projectile)
		#
		#projectile._set_collision_layer(Constants.TARGETS.NEUTRAL)
		#projectile._set_collision_masks(Constants.TARGETS.ENEMY)
#
#func get_nearest_enemies(max_distance: float, max_count: int) -> Array:
	#var nearby_enemies = []
	#
	## Filter enemies within the given max_distance
	#for enemy in enemies:
		#var distance = global_position.distance_to(enemy.global_position)
		#if distance <= max_distance:
			#nearby_enemies.append({"enemy": enemy, "distance": distance})
	#
	## Sort enemies by distance (closest first) using the custom sort function
	#nearby_enemies.sort_custom(Callable(self, "_sort_by_distance"))
	#
	## Return up to max_count nearest enemies
	#var result = []
	#for i in range(min(max_count, nearby_enemies.size())):
		#result.append(nearby_enemies[i]["enemy"])
	#
	#return result

extends Node3D

@export var projectile_obj:PackedScene

var cd:float = 0
@export var is_homing:bool = false
var has_stats:bool = false
@export var shoot_interval: float = 3.0

var enemies = []
var _shoot_timer: float = 0.0

#func _ready():
	#_get_values()
	#_set_values()

#func _assign_new_values(new_stat_dict:Dictionary):
	#_get_new_values(new_stat_dict)
	#_set_values()
#
#func _get_new_values(new_stat_dict:Dictionary):
	#stat_dict = new_stat_dict
#
#func _set_values():
	#cd = stat_dict[Constants.get_enum_name_by_value(Constants.STATS.CD)]
#
#func _set_target(value:Node):
	#target = value

# Set behavior for projectile, homing or normal
func _set_homing(value:bool):
	is_homing = value

# If skill is active and within cd intervals, spawn projectile
func _physics_process(_delta: float):
	if (projectile_obj):
		_shoot_timer -= _delta
		if _shoot_timer <= 0:
			enemies = get_tree().get_nodes_in_group("enemies")
			_spawn_projectile()
			# Reset the timer
			_shoot_timer = shoot_interval

# Instantiate a copy of the base projectile scene
func _spawn_projectile():
	var target: Node3D
	var nearest_enemy = get_nearest_enemies(10, 1) #Get the nearest enemy only
	if nearest_enemy.size() > 0:
		target = nearest_enemy[0]
		var nearest_enemy_direction = (target.global_transform.origin - global_transform.origin).normalized() #Get the normalized direction
		var projectile = projectile_obj.instantiate() as Node3D
	
		get_tree().root.add_child(projectile)
		projectile.global_transform.origin = global_transform.origin
		#projectile.scale = Vector3(0.5, 0.5, 0.5)

		# Set collision layer to 1, the same as environment
		projectile._set_collision_layer(Constants.TARGETS.NEUTRAL)
		# Set collision mask so that it only detects player
		projectile._set_collision_masks(Constants.TARGETS.ENEMY)

		# Set behavior if projectile is homing or not
		projectile.is_homing = is_homing
		# Start moving to target
		projectile._shoot(projectile, get_parent(), target, nearest_enemy_direction)
	
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
