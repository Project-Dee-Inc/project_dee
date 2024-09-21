extends StaticBody3D

var moving:bool = false
var target_pos:Vector3 = Vector3(0,0,0)

func _set_target_position(position:Vector3):
	target_pos = position
	moving = true

func _move_to_target_position(delta: float):
	if(moving):
		var direction = (target_pos - global_transform.origin).normalized()
		global_transform.origin += global_transform.origin.lerp(direction * 5, 20 * delta)

func _stop_movement():
	if(moving && Constants.is_close_to_destination(global_transform.origin, target_pos)):
		moving = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float):
	_move_to_target_position(delta)
	_stop_movement()
