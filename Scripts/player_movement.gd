extends Node

@export var character_body_3d: CharacterBody3D

func _set_speed(value: float):
	if(character_body_3d != null):
		character_body_3d.speed = value
