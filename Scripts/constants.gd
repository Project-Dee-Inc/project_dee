extends Node

enum ANIM_STATE {
	IDLE,
	WALK,
	ATTACK,
	HIT,
	CUE,
	DEATH
}

enum TARGETS { 
	NEUTRAL,
	PLAYER,
	ENEMY,
	BOTH
}

enum WEAPON_TYPES{
	MELEE,
	RANGE,
	MAGIC
}

enum STATS { 
	ATK,
	C_RATE, 
	C_DMG, 
	PEN, 
	HP,
	HP_REGEN,
	DEF,
	ATK_SPD,
	MOVE_SPD,
	CD,
	CD_HASTE,
	ENERGY,
	ENERGY_REGEN,
	AOE,
	SKILL_DURATION,
	PROJ_COUNT,
	PROJ_SPD,
	EXP_GAIN,
	GOLD_GAIN,
	RNG
}

var custom_status_effects = [
	"Silenced"
]

var stats_enum_mapping = {
	"ATK": STATS.ATK,
	"C_RATE": STATS.C_RATE, 
	"C_DMG": STATS.C_DMG, 
	"PEN": STATS.PEN, 
	"HP": STATS.HP,
	"HP_REGEN": STATS.HP_REGEN,
	"DEF": STATS.DEF,
	"ATK_SPD": STATS.ATK_SPD,
	"MOVE_SPD": STATS.MOVE_SPD,
	"CD": STATS.CD,
	"CD_HASTE": STATS.CD_HASTE,
	"ENERGY": STATS.ENERGY,
	"ENERGY_REGEN": STATS.ENERGY_REGEN,
	"AOE": STATS.AOE,
	"SKILL_DURATION": STATS.SKILL_DURATION,
	"PROJ_COUNT": STATS.PROJ_COUNT,
	"PROJ_SPD": STATS.PROJ_SPD,
	"EXP_GAIN": STATS.EXP_GAIN,
	"GOLD_GAIN": STATS.GOLD_GAIN,
	"RNG": STATS.RNG
}

class StatusEffect:
	var name: String
	var duration: float
	var stackable: bool
	var stat_modifiers: Dictionary

	func _init(_name: String, _duration: float, _stackable: bool, _stat_modifiers: Dictionary):
		name = _name
		duration = _duration
		stackable = _stackable
		stat_modifiers = _stat_modifiers

var reverse_stats_enum_mapping = {}

const item_tscn = preload("res://Scenes/item.tscn")

func _ready():
	for key in stats_enum_mapping.keys():
		reverse_stats_enum_mapping[stats_enum_mapping[key]] = key

func get_enum_value_by_name(str_name: String) -> int:
	return stats_enum_mapping.get(str_name, -1)  # Return -1 if not found

func get_enum_name_by_value(value: int) -> String:
	return reverse_stats_enum_mapping.get(value, "Unknown Stat")  # Return "Unknown Stat" if not found

func is_close_to_destination(current_position: Vector3, destination: Vector3, threshold: float = 0.5) -> bool:
	var distance = current_position.distance_to(destination)
	return distance <= threshold

func set_collision_masks(collider_component:Area3D, target_type:Constants.TARGETS):
	match target_type:
		Constants.TARGETS.PLAYER:
			collider_component.collision_mask = (1 << 1)
		Constants.TARGETS.ENEMY:
			collider_component.collision_mask  = (1 << 2)
		Constants.TARGETS.BOTH:
			collider_component.collision_mask  = (1 << 1) | (1 << 2)
		_:
			pass

func set_collision_layer(collider_component:Area3D, target_type:Constants.TARGETS):
	#print("HERE LAYER ", collider_component)
	match target_type:
		Constants.TARGETS.NEUTRAL:
			collider_component.collision_layer = (1 << 0)
		Constants.TARGETS.PLAYER:
			collider_component.collision_layer = (1 << 1)
		Constants.TARGETS.ENEMY:
			collider_component.collision_layer  = (1 << 2)
		_:
			pass

#find enemies
func get_group_positions(group_value:String) -> Array:
	var group_positions = []
	for group in get_tree().get_nodes_in_group(group_value):
		if group and group.is_inside_tree():
			group_positions.append(group.global_transform.origin)
	return group_positions

#find enemies
func get_group_nodes(group_value:String) -> Array[Node]:
	var group_positions:Array[Node]
	for group in get_tree().get_nodes_in_group(group_value):
		if group and group.is_inside_tree():
			group_positions.append(group)
	return group_positions

func find_group_center(group_positions: Array) -> Vector3:
	var total_position = Vector3()
	for pos in group_positions:
		total_position += pos
	return total_position / group_positions.size() 

func _get_direction(start:Vector3, end:Vector3) -> Vector3:
	var dir = (start - end).normalized()
	return dir

func _get_health_percentage(current: float, max_health: float) -> float:
	if max_health == 0:
		return 0  # Avoid division by zero
	return (current / max_health) * 100

# Start the timer and connect a listener dynamically
func _start_timer_with_listener(reusable_timer:Timer, wait_time: float, listener_func: Callable):
	_remove_all_timer_listeners(reusable_timer)
	reusable_timer.stop()
	reusable_timer.wait_time = wait_time
	reusable_timer.connect("timeout", listener_func)
	reusable_timer.start()

# Stop the timer and disconnect a listener dynamically
func _stop_timer_and_remove_listener(reusable_timer:Timer, listener_func: Callable):
	if reusable_timer.is_connected("timeout", listener_func):
		reusable_timer.disconnect("timeout", listener_func)
	reusable_timer.stop()

# Remove all current listeners for a specific timer
func _remove_all_timer_listeners(reusable_timer:Timer):
	var connections = reusable_timer.get_signal_connection_list("timeout")

	for connection in connections:
		var method = connection.callable
		if (method):
			reusable_timer.disconnect("timeout", method)

# Calculate the bounds (AABB) of a NavigationMesh and cache them
func _calculate_navigation_mesh_bounds(navigation_mesh: NavigationMesh) -> AABB:
	var vertices = navigation_mesh.get_vertices()
	var min_extents = Vector3(INF, INF, INF)
	var max_extents = Vector3(-INF, -INF, -INF)

	# Loop through each vertex to find the min and max extents
	for vertex in vertices:
		min_extents.x = min(min_extents.x, vertex.x)
		min_extents.y = min(min_extents.y, vertex.y)
		min_extents.z = min(min_extents.z, vertex.z)

		max_extents.x = max(max_extents.x, vertex.x)
		max_extents.y = max(max_extents.y, vertex.y)
		max_extents.z = max(max_extents.z, vertex.z)

	return AABB(min_extents, max_extents - min_extents)

func _is_position_walkable(navigation_map, position: Vector3) -> bool:
	var path = NavigationServer3D.map_get_path(navigation_map, position, position, false)
	return path.size() > 0

func _get_rand() -> float:
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	return rng.randf()
