extends Node3D
class_name  AnimationManager

@onready var animation_tree = $AnimationTree

func change_idle_animation(direction:Vector3, is_dashing: bool):
	if(direction == Vector3.ZERO):
		animation_tree.get("parameters/playback").travel("Idle")
	else:
		if(is_dashing):
			animation_tree.get("parameters/playback").travel("Dash")
		else:
			animation_tree.get("parameters/playback").travel("Walk")
			animation_tree.set("parameters/Dash/blend_position",Vector2(direction.x,direction.z))
			animation_tree.set("parameters/Idle/blend_position",Vector2(direction.x,direction.z))
			animation_tree.set("parameters/Walk/blend_position",Vector2(direction.x,direction.z))
