extends Node

# Preload the scene you want to spawn
@export var spawn_table: Dictionary = {}
@export var spawn_delay: float = 0

var camera: Camera3D

func _ready():
	camera = get_viewport().get_camera_3d()

	await get_tree().create_timer(spawn_delay).timeout
	_start_spawning()

func _start_spawning():
	var target = GameManager.player.movement_component.character_body_3d
	for spawn_key in spawn_table.keys():
		var spawn_count = spawn_table[spawn_key]
		for i in range(spawn_count):
			var spawn_position = get_random_position_around_object(target.global_transform.origin, 10)
			_spawn_object(spawn_key, spawn_position)

func _spawn_object(object_to_spawn, location):
	var instance = object_to_spawn.instantiate()
	instance.global_transform.origin = location
	get_parent().add_child(instance)

func get_random_position_around_object(object_position: Vector3, radius: float) -> Vector3:
	# Randomly pick a direction in 3D space (spherical coordinates)
	var theta = randf_range(0.0, PI * 2)   # Random angle around Y-axis
	var phi = randf_range(0.0, PI * 2)     # Random angle around XZ-plane
	var r = randf_range(0.0, radius)       # Random distance from the object within the radius
	
	# Convert spherical coordinates to Cartesian coordinates
	var x = r * sin(phi) * cos(theta)
	var z = r * cos(phi)
	
	# Add this offset to the object's position
	var spawn_position = object_position + Vector3(x, 1, z)
	
	return spawn_position
