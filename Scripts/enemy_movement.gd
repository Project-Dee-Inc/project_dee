extends Node

@onready var animation_component: Node = $"../AnimationComponent"
@onready var nav_agent = $"../NavigationAgent3D"
@onready var parent_component = $".."
var raycast:RayCast3D
var target:Node3D
var body:Node3D

var speed:int = 0
var state_is_moving:bool = false

var is_surround:bool = false
var is_stay_in_range:bool = false
var is_blocked:bool = false
var needs_line_of_sight:bool = false
var override_follow_target:bool = false

var target_position:Vector3
var follow_range:float = 0
var kill_radius:float = 2.5
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
	if(value):
		randomnum = _get_rand()

	is_surround = value

# Set if movement type stays within range of player
func _set_stay_in_range(value:bool, range_to_follow:float = 0.0):
	if(value):
		follow_range = range_to_follow

	is_stay_in_range = value

# Set if movement needs to take into mind line of sight
func _set_line_of_sight(value:bool):
	if(value):
		raycast = $RayCast3D
		raycast.body = body

	needs_line_of_sight = value

# Set if movement doesn't have to follow a target, but to a position
func _set_independent_movement(value:bool):
	override_follow_target = value

# Manually set target position
func _set_target_position(value:Vector3):
	target_position = value

# Set state to following or not
func _state_moving(value:bool):
	if(value && target == null):
		target = GameManager.player

	state_is_moving = value

# Move to position if in following state
func _physics_process(delta):
	if (state_is_moving && target != null):
		if(!override_follow_target):
			target_position = target.global_transform.origin

		if(is_stay_in_range):
			if(!Constants.is_close_to_destination(body.global_transform.origin, target_position, follow_range) || is_blocked):
				_on_start_move(target_position, delta)
			else:
				_on_stop_move()
		else:
			_on_start_move(target_position, delta)

# Start movement, check if surround or simple follow movement
func _on_start_move(target_pos:Vector3, delta:float):
	if(is_surround):
		target_pos = _get_circle_position(target_pos, randomnum)

	_move_to_pos(target_pos, delta)

# Stop movement and stay stationary
func _on_stop_move():
	body.velocity = Vector3.ZERO  # Stop moving if within follow range
	_face_player()

# Move to Vector3 position
func _move_to_pos(target_pos:Vector3, delta:float):
	nav_agent.target_position = target_pos
	var direction = (nav_agent.get_next_path_position() - body.global_transform.origin).normalized()
	body.velocity = body.velocity.lerp(direction * speed, 20 * delta)

	if(body.velocity.x > 0):
		animation_component._flip_anim(true)
	else:
		animation_component._flip_anim(false)

	body.move_and_slide()

func _face_player():
	var direction = (target.global_transform.origin - body.global_transform.origin).normalized()

	# Flip the sprite based on the direction to the player
	if (direction.x > 0):
		animation_component._flip_anim(true)
	elif (direction.x < 0):
		animation_component._flip_anim(false)

func _get_circle_position(target_pos:Vector3, random: float) -> Vector3:
	var kill_circle_centre = target_pos
	# Calculate the position on the XZ plane
	var angle = random * PI * 2.0
	var x = kill_circle_centre.x + cos(angle) * kill_radius
	var z = kill_circle_centre.z + sin(angle) * kill_radius

	return Vector3(x, kill_circle_centre.y, z)

func _is_moving() -> bool:
	if(body.velocity != Vector3.ZERO):
		return true
	else:
		return false
