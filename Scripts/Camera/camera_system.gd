extends Node

@export var target : CameraTarget
@export var target_override : CameraTarget
var has_override : bool = false

func get_target() -> CameraTarget:
	if has_override:
		return target_override
	else:
		return target
	
func set_target(new_target : CameraTarget):
	target = new_target

func override_target(new_override : CameraTarget):
	target_override = new_override
	has_override = true

func clear_override():
	target_override = null
	has_override = false
