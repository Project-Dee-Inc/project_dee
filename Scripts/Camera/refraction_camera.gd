extends Camera3D

@export var main_camera : Camera3D

func _process(_delta: float) -> void:
	if main_camera:
		global_position = main_camera.global_position
		global_rotation = main_camera.global_rotation
		h_offset = main_camera.h_offset
		v_offset = main_camera.v_offset
