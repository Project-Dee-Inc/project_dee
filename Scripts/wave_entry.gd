# pool_entry.gd

# This class defines the structure for each entry in the weapon pool.
# Each entry contains a reference to a weapon prefab and its pool size.
extends Resource

# Declare the class name to make it globally accessible
class_name WaveEntry

@export var enemy: PackedScene
@export var chance: float
@export var count: int
