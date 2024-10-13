extends Node

# Exported variable to hold an array of PoolEntry instances.
# Each PoolEntry contains a reference to a weapon prefab and its corresponding pool size.
@export var weapon_pool_entry: Array[PoolEntry] = []

# Dictionary to hold the weapon instances, organized by their keys
var weapon_pool: Dictionary = {}

func _ready():
	_preload_weapons()

# Preloads weapons based on the configuration defined in weapon_pool_entry
func _preload_weapons():
	# Iterate through each entry in the weapon pool configuration
	for entry in weapon_pool_entry:
		# Initialize an array to hold instances of the current weapon
		var instances = []
		# Variable to store the weapon's name
		var key
		# Create a number of instances based on the specified pool size for this weapon
		for i in range(entry.pool_size):
			# Instantiate the weapon prefab
			var weapon_instance = entry.prefab.instantiate()
			# Get the name of the weapon instance
			key = weapon_instance.name
			# Add the instance to the instances array
			instances.append(weapon_instance)
			# Add the instance as a child to the current node in the scene tree
			add_child(weapon_instance)
			# Set visibility to false (hides the node)	
			weapon_instance.hide()  
			# Stop processing for the node
			weapon_instance.set_process(false)  
		# Store the instances array in the weapon_pool dictionary using the weapon's key
		weapon_pool[key] = instances

# Retrieves a weapon instance from the weapon pool based on the specified weapon key	
func _get_weapon(weapon_key: String):
	# Check if the weapon pool contains the specified weapon key
	if weapon_pool.has(weapon_key):
		# Retrieve the instances array for the specified weapon key
		var instances = weapon_pool[weapon_key]
		# Check if there are any available instances in the pool
		if instances.size() > 0:
			# Remove the last instance from the array and return it
			var weapon_instance = instances.pop_back()
			# Make the weapon instance visible again
			weapon_instance.show()
			# Resume processing for the weapon instance, allowing it to update logic
			weapon_instance.set_process(true)
			return weapon_instance
		else:
			# If no instances are available, instantiate a new weapon from the prefab
			for entry in weapon_pool_entry:
				# Instantiate a new weapon prefab
				var weapon_instance = entry.prefab.instantiate()
				return weapon_instance
	else:
		print("Weapon not found in pool: ", weapon_key)
	return null

# Returns a weapon instance back to the weapon pool.	
func _return_weapon(weapon_key: String, weapon_instance: Node):
	# Set visibility to false (hides the node)	
	weapon_instance.hide()  
	# Stop processing for the node
	weapon_instance.set_process(false)  
	# Check if the weapon pool already has a list for the given weapon key
	if not weapon_pool.has(weapon_key):
		# If not, create a new empty array for this weapon key in the weapon pool
		weapon_pool[weapon_key] = []
	# Add the weapon instance to the list of instances for this weapon key
	weapon_pool[weapon_key].append(weapon_instance)
