extends Node3D
class_name PoolManager

@export var object_reference:PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _get_unused_object()->Node3D:
	for tentacle:Node3D in get_children():
		if(!tentacle.visible):
			return tentacle
			pass
	var ten = object_reference.instantiate()
	add_child(ten)
	print("created, ", ten)
	return ten
