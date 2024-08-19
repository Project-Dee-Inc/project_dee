extends Node

@export var character_body_3d: CharacterBody3D
@export var dash_has_no_damage:bool

func _set_speed(value: float):
	if(character_body_3d != null):
		character_body_3d.speed = value
func _set_dash_multiplier(value: float):
	if(character_body_3d!=null):
		character_body_3d.dash_multiplier = value
