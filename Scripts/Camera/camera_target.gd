class_name CameraTarget
extends Node

@export var is_initial_target : bool

func _ready():
	if is_initial_target:
		CameraSystem.set_target(self)
