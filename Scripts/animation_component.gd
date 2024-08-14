extends Node

#@export var sprite_3d: AnimatedSprite3D
#@onready var sprite_3d = $"../MovementComponent/CharacterBody3D/AnimatedSprite3D"
#@onready var animation_tree = $AnimationTree

# Called every frame. 'delta' is the elapsed time since the previous frame.
func change_idle_animation(direction:Vector3):
	pass
	#animation_tree.set("parameters/Idle/blend_position",direction)
		
