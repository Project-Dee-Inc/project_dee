extends Node

@export var loot_scene:PackedScene
@export var loot_table: Dictionary = {}

# Function to roll for loot
func get_random_loot() -> String:
	var roll = randf() * 100  # Roll a random number between 0 and 100
	var cumulative_chance = 0

	var rng_loot_keys = loot_table.keys()
	rng_loot_keys.shuffle()

	# Iterate through the loot table
	for item in rng_loot_keys:
		cumulative_chance += loot_table[item]

		if roll < cumulative_chance:
			return item  # Return the item that matches the roll

	return "nothing"  # In case nothing is found, though ideally, chances should sum to 100

# Spawn one instance of projectile towards a target node and position
func _spawn_item(item_name:String, location:Vector3, op_number:int = 0):
	var item = loot_scene.instantiate()

	var root_node = get_tree().current_scene
	root_node.add_child(item)

	location.y += 0.5
	item.global_transform.origin = location

	item._set_item(item_name, op_number)
