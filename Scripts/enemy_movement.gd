extends Node

@onready var parent_component = $".."
var target:Node3D
var body:Node3D

var speed:int = 0
var gravity: float = 9.8
var velocity:Vector3 = Vector3.ZERO
var state_is_moving:bool = false

var is_surround:bool = false
var radius:float = 2.5
var randomnum:float

func _ready():
	body = get_parent()

func _get_rand() -> float:
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	return rng.randf()

# Set initial movement speed for mob
func _set_speed(value:int):
	speed = value

# Set if movement type surrounds or not
func _set_surround(value:bool):
	if(is_surround):
		randomnum = _get_rand()

	is_surround = value

# Set state to following or not
func _state_moving(value:bool):
	if(value && target == null):
		target = GameManager.player.movement_component.character_body_3d

	state_is_moving = value

# Move to position if in following state
func _physics_process(delta):
	if (state_is_moving && target != null):
		var target_position = target.global_transform.origin
		if(is_surround):
			move_to_pos(get_circle_position(target_position, randomnum), delta)
		else:
			move_to_pos(target_position, delta)

# Move to Vector3 position
func move_to_pos(target_pos:Vector3, delta:float):
	var direction = (target_pos - body.global_transform.origin).normalized()
	var desired_velocity: Vector3 = direction * speed
	var steering: Vector3 = (desired_velocity - velocity) * delta * 2.5

	# Add the gravity.
	#if not body.is_on_floor():
		#velocity.y -= gravity * delta

	velocity += steering
	velocity.y = 0

	body.global_transform.origin += velocity * delta

func get_circle_position(target_pos:Vector3, random: float) -> Vector3:
	var kill_circle_centre = target_pos
	# Calculate the position on the XZ plane
	var angle = random * PI * 2.0
	var x = kill_circle_centre.x + cos(angle) * radius
	var z = kill_circle_centre.z + sin(angle) * radius

	return Vector3(x, kill_circle_centre.y, z)

