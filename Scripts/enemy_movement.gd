extends Node

@onready var parent_component = $".."
var target:CharacterBody3D
var body:CharacterBody3D

var speed:int = 0
var gravity: float = 9.8
var velocity:Vector3 = Vector3.ZERO
var state_is_moving:bool = false

func _ready():
	body = get_parent().get_child(0)

# Set initial movement speed for mob
func _set_speed(value:int):
	speed = value
	target = parent_component.target
	_state_moving(true)

# Set state to following or not
func _state_moving(value:bool):
	state_is_moving = value

# Move to position if in following state
func _physics_process(delta):
	if state_is_moving:
		move_to_pos(target.global_transform.origin, delta)

# Move to Vector3 position
func move_to_pos(target_pos:Vector3, delta:float):
	var direction = (target_pos - body.global_transform.origin).normalized()
	var horizontal_velocity: Vector3 = direction * speed
	
	# Update horizontal velocity only
	velocity.x = horizontal_velocity.x
	velocity.z = horizontal_velocity.z

	# Apply gravity to the vertical velocity
	#if not body.is_on_floor():
		#velocity.y -= gravity * delta
	#else:
	velocity.y = 0  # Reset Y velocity when on the floor

	body.global_transform.origin += velocity * delta

