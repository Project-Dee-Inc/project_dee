extends Node3D

var cooldown: int = 0
var player_stat_dict: Dictionary = {}

# Variables to control the attack
var attack_interval: float = 3.0
var time_since_last_attack: float = 0.0
var attack_range: float = 10.0
var attack_angle_degrees: float = 90.0
var damage_amount: int = 10

@onready var weapon_skill = $WeaponSkill
	
func _on_ready():
	cooldown = weapon_skill.stat_dict[Constants.get_enum_name_by_value(Constants.STATS.CD)]
	EventManager.add_listener(str(EventManager.EVENT_NAMES.ON_PLAYER_BASE_STATS_READY), self, "_get_player_stat") # Todo: Change this so it listens to "on weapon equipped" instead of "on player base stats ready"

func _get_player_stat(value: Dictionary):
	player_stat_dict = value
	
func _skill_activate():
	weapon_skill.player_stats = player_stat_dict
	weapon_skill._activate_skill()
 
# Placeholder method to handle enemies
func damage_enemies_in_cone(direction: Vector3):
	# Get all potential enemies in the scene
	var enemies = get_tree().get_nodes_in_group("enemies")
	
	for enemy in enemies:
		# Calculate the vector from the player to the enemy
		var to_enemy = (enemy.global_transform.origin - global_transform.origin).normalized()
		to_enemy.y = 0  # Ignore Y component to maintain horizontal plane
		# Calculate the angle between the attack direction and the vector to the enemy
		var angle = rad_to_deg(direction.angle_to(to_enemy))
		# Check if the enemy is within the attack cone
		if angle <= attack_angle_degrees / 2 and is_enemy_in_range(enemy):
			# Access the health component of the enemy
			enemy.apply_damage(damage_amount)
			

# Function to get the direction towards the cursor
func get_attack_direction() -> Vector3:
	var camera = get_viewport().get_camera_3d()
	var mouse_position = get_viewport().get_mouse_position()
	var ray_origin = camera.project_ray_origin(mouse_position)
	var ray_target = ray_origin + camera.project_ray_normal(mouse_position) * 1000.0
	
	# Cast the ray and get the intersection point with the ground (assuming Y = 0)
	var space_state = get_world_3d().direct_space_state
	var param = PhysicsRayQueryParameters3D.new()
	param.from = ray_origin
	param.to = ray_target
	param.collide_with_areas

	var result = space_state.intersect_ray(param)
	
	if result:
		var intersection_point = result.position
		# Ignore Y component for the direction vector
		var direction = (intersection_point - global_transform.origin).normalized()
		direction.y = 0
		return direction.normalized()
	
	return Vector3.ZERO

# Called every frame to update the attack timer
func _process(delta: float) -> void:
	time_since_last_attack += delta
	
	if time_since_last_attack >= attack_interval:
		time_since_last_attack = 0.0
		
		# Get the direction of the attack
		var attack_direction = get_attack_direction()
		
		# If there's a valid direction, perform the attack
		print(attack_direction)
		if attack_direction != Vector3.ZERO:
			damage_enemies_in_cone(attack_direction)

# Helper method to check if an enemy is within range
func is_enemy_in_range(enemy: Node3D) -> bool:
	return global_transform.origin.distance_to(enemy.global_transform.origin) <= attack_range
