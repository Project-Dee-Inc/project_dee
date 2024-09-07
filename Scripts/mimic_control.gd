extends Node
class_name MimicControl

@export var enemy_spawn_table: Dictionary = {}

func _set_values(location_to_spawn:Vector3):
	_spawn_enemy(_get_random_enemy(), location_to_spawn)

func _get_random_enemy() -> PackedScene:
	var total_chance = 0.0
	
	# Calculate the total percentage
	for chance in enemy_spawn_table.values():
		total_chance += chance
	
	# Generate a random number between 0 and the total percentage
	var rng = randf() * total_chance
	var cumulative_chance = 0.0
	
	# Determine which enemy corresponds to the random number
	for enemy in enemy_spawn_table.keys():
		cumulative_chance += enemy_spawn_table[enemy]
		if (rng < cumulative_chance):
			return enemy
	
	return null  

func _spawn_enemy(spawn_scene:PackedScene, location:Vector3):
	EventManager.raise_event(str(EventManager.EVENT_NAMES.ON_SPAWN_OBJECT), ["Enemy", spawn_scene, location])
	queue_free()
