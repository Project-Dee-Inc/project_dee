extends Node3D
class_name MovingObject

@export var speed:float = 1

var moving_object_root_node: Node3D
var destinations:Array[Vector3] = []
var loop_to_first:bool = false
var is_moving:bool = false
var destroy_on_end:float = 1

var next_destination:int = 0

func set_root_node( node:Node3D):
	moving_object_root_node = node

func _physics_process(delta: float) -> void:
	if(!moving_is_valid()): pass
	if(is_moving):
		if(destinations[next_destination].distance_to(moving_object_root_node.global_position) < .1):
			# if the two obejct is close to the destination
			if(next_destination + 1 >=destinations.size()):
				#if the final destination has been reached
				if(!loop_to_first): 
					moving_object_root_node.queue_free()
				else:
					next_destination = 0
			else:
				next_destination +=1
		else:
			_move(delta)

func _start_moving():
	is_moving = true
	
func _move(delta):
	var direction = Constants._get_direction(destinations[next_destination], moving_object_root_node.global_position)
	moving_object_root_node.global_position += direction * speed * delta

func moving_is_valid() -> bool:
	var valid = true
	if(destinations.is_empty()): valid = false
	if(moving_object_root_node == null): valid = false
	return valid
	
