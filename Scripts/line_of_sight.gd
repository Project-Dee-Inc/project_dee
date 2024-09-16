extends RayCast3D

var body:Node3D

func _has_line_of_sight(target: Node3D) -> bool:
	self.global_transform.origin = body.global_transform.origin
	self.target_position = target.global_transform.origin - self.global_transform.origin

	# Ensure the raycast is enabled and update it
	self.force_raycast_update()

	# Check if the RayCast3D is colliding with the target or something else
	if self.is_colliding():
		var collider = self.get_collider()
		#print("Raycast collided with: ", collider.name)
		if collider == target:
			return true  # Direct line of sight
	return false  # There's an obstacle
