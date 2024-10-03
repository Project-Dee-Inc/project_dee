# pool_entry.gd

# This class defines the structure for each entry in the weapon pool.
# Each entry contains a reference to a weapon prefab and its pool size.
extends Resource

# Declare the class name to make it globally accessible
class_name PoolEntry

# Exported variable to hold the reference to the weapon prefab.
# This should be set to a PackedScene resource in the Inspector.
@export var prefab: PackedScene
# Exported variable to specify the size of the pool for this weapon.
# This represents how many instances of this prefab should be preloaded.
@export var pool_size: int
# The key used to identify the weapon in the pool
@export var key: String
