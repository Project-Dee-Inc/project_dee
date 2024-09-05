extends Node

@export var navigation:NavigationRegion3D
@export var spawn_table: Dictionary = {}
@export var spawn_delay: float = 0
@export var spawn_range: float = 10

var active_spawns: Dictionary = {}

func _ready():
	for scene in spawn_table.keys():
		active_spawns[scene] = 0 

	_start_spawning()

func _start_spawning():
	while true:
		await get_tree().create_timer(spawn_delay).timeout
		_spawn_objects()

func _spawn_objects():
	var target = GameManager.player.global_transform.origin
	
	# Attempt to spawn objects for each scene in the spawn table
	for scene in spawn_table.keys():
		if active_spawns[scene] < spawn_table[scene]:
			var spawn_position = _get_random_position_around_object(target, spawn_range)
			_spawn_object(scene, spawn_position)

func _spawn_object(scene: PackedScene, location: Vector3):
	var instance = scene.instantiate()
	add_child(instance)  

	instance.global_transform.origin = location

	active_spawns[scene] += 1
	instance.connect("tree_exited", Callable(self, "_on_object_destroyed").bind(scene))

func _on_object_destroyed(scene: PackedScene):
	# When an object is destroyed, decrement the active count
	active_spawns[scene] -= 1

func _get_random_position_around_object(object_position: Vector3, radius: float) -> Vector3:
	var position_found = false
	var spawn_position = Vector3()

	while (!position_found):
	# Randomly pick a direction in 3D space (spherical coordinates)
		var theta = randf_range(0.0, PI * 2)   # Random angle around Y-axis
		var phi = randf_range(0.0, PI)         # Random angle around XZ-plane
		var r = randf_range(0.0, radius)       # Random distance from the object within the radius

		# Convert spherical coordinates to Cartesian coordinates
		var x = r * sin(phi) * cos(theta)
		var z = r * sin(phi) * sin(theta)

		# Add this offset to the object's position
		var tentative_position = object_position + Vector3(x, 0, z)
		spawn_position = NavigationServer3D.map_get_closest_point(navigation.get_navigation_map(), tentative_position)

		# Check if the generated position is walkable
		if _is_position_walkable(spawn_position):
			position_found = true

	return spawn_position

func _is_position_walkable(position: Vector3) -> bool:
	var navigation_map = navigation.get_navigation_map()
	var path = NavigationServer3D.map_get_path(navigation_map, position, position, false)
	return path.size() > 0
