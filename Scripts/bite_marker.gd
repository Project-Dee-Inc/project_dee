extends StaticBody3D

var moving:bool = false
var speed:float = 10
var target_pos:Vector3 = Vector3(0,0,0)

func _set_speed(value:float):
	speed = value

func _set_target_position(position:Vector3):
	target_pos = position
	moving = true

func _move_to_target_position(delta: float):
	if (moving):
		var direction = (target_pos - self.global_transform.origin).normalized()
		self.global_transform.origin += direction * speed * delta  # Adjust speed as needed

		# Check if close enough to stop
		if Constants.is_close_to_destination(self.global_transform.origin, target_pos, 0):
			_stop_movement()

func _stop_movement():
	moving = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float):
	_move_to_target_position(delta)
