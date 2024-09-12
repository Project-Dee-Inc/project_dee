extends Node3D

var cooldown: int = 0
var player_stat_dict: Dictionary = {}

# Variables to control the attack
var time_since_last_attack: float = 0.0
@export var attack_interval: float = 3.0
@export var attack_range: float = 10.0
@export var is_cone_attack: bool = false
@export var attack_angle_degrees: float = 90.0
@export var damage_amount: int = 10
@export var max_enemies_damaged: int = 3

@onready var weapon_skill = $WeaponSkill
var enemies = []
	
func _on_ready():
	cooldown = weapon_skill.stat_dict[Constants.get_enum_name_by_value(Constants.STATS.CD)]
	EventManager.add_listener(str(EventManager.EVENT_NAMES.ON_PLAYER_BASE_STATS_READY), self, "_get_player_stat") # Todo: Change this so it listens to "on weapon equipped" instead of "on player base stats ready"

func _get_player_stat(value: Dictionary):
	player_stat_dict = value
	
func _skill_activate():
	weapon_skill.player_stats = player_stat_dict
	weapon_skill._activate_skill()
 
func damage_nearest_enemies():
	var nearest_enemies = get_nearest_enemies(attack_range, max_enemies_damaged)
	
	if nearest_enemies.size() > 0:
		for enemy in nearest_enemies:
			print("Found enemy: ", enemy.name, " at position: ", enemy.global_position)
			enemy.health_component._damage(damage_amount)
	else:
		print("No enemies found within the distance.")

func damage_enemies_in_cone():
	var nearest_enemy = get_nearest_enemies(attack_range, 1) #Get the nearest enemy only
	var nearest_enemy_direction: Vector3 = Vector3.ZERO
	if nearest_enemy.size() > 0:
		nearest_enemy_direction = (nearest_enemy[0].global_transform.origin - global_transform.origin).normalized() #Get the normalized direction
	
	for enemy in enemies:
		var to_enemy = (enemy.global_transform.origin - global_transform.origin).normalized()
		to_enemy.y = 0
		var angle = rad_to_deg(nearest_enemy_direction.angle_to(to_enemy))
		if (angle <= attack_angle_degrees / 2 and is_enemy_in_range(enemy)) or enemy.global_transform.origin.distance_to(global_transform.origin) <= 0.5:
			enemy.health_component._damage(damage_amount)
			print("Dealing damage in a cone")
	
	
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

# Called every frame to update the attack timer
func _process(delta: float) -> void:
	time_since_last_attack += delta
		
	if time_since_last_attack >= attack_interval:
		time_since_last_attack = 0.0
		enemies = get_tree().get_nodes_in_group("enemies")
		if not is_cone_attack:
			damage_nearest_enemies()
		else:
			damage_enemies_in_cone()
		
		# Get the direction of the attack
		#var attack_direction = get_attack_direction()
		
		# If there's a valid direction, perform the attack
		#if attack_direction != Vector3.ZERO:
			#damage_enemies_in_cone(attack_direction)

# Helper method to check if an enemy is within range
func is_enemy_in_range(enemy: Node3D) -> bool:
	return global_transform.origin.distance_to(enemy.global_transform.origin) <= attack_range
	
# Helper function for sorting
func _sort_by_distance(a, b) -> bool:
	return a["distance"] < b["distance"]
