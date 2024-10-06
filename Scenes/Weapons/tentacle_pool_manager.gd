extends Node
class_name PoolManager

@export var object_reference:PackedScene


	
func _get_unused_object() -> Node3D:
	for tentacle:Node3D in get_children():
		if(!tentacle.visible):
			return tentacle
			pass
	var ten = object_reference.instantiate()
	add_child(ten)
	print("created, ", ten)
	return ten
