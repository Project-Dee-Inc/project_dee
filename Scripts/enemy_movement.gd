extends Node

@onready var animation_component: Node = $"../AnimationComponent"
@onready var nav_agent = $"../NavigationAgent3D"
@onready var parent_component = $".."
@export var override_face_player:bool = false
var raycast:RayCast3D
var target:Node3D
var body:Node3D
var dir_suffix:String

var speed:int = 0
var current_speed:float
var state_is_moving:bool = false

var is_surround:bool = false
var is_stay_in_range:bool = false
var is_blocked:bool = false
var is_static_movement:bool = false
var needs_line_of_sight:bool = false
var override_follow_target:bool = false
var reset_surround_target:bool = false
var away_from_target:bool = false

var target_position:Vector3
var surround_timer:float = 0.0
var follow_range:float = 0
var kill_radius:float = 1
var randomnum:float

func _ready():
	body = get_parent()
	current_speed = speed

# Set initial movement speed for mob
func _set_speed(value:int):
	speed = value
	current_speed = speed

# Set if movement type surrounds or not
func _set_surround(value:bool):
	if(value):
		reset_surround_target = false
		randomnum = Constants._get_rand()

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

# Set movement to static, only one direction
func _set_static_movement(value:bool):
	is_static_movement = value

func _set_movement_away_from_target(value:bool):
	away_from_target = value

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
		if(is_surround):
			surround_timer += delta
			if (surround_timer >= 2):
				surround_timer = 0
				reset_surround_target = true

		# If normal target following, get target's position at all times
		if(!override_follow_target):
			target_position = target.global_transform.origin

		# If in range and normal target
		if(is_stay_in_range and !override_follow_target):
			# Move to target position if any of the following conditions are met:
			# If not close to destination
			# If sight is blocked
			# If not within 1 distance of the target
			if((!Constants.is_close_to_destination(body.global_transform.origin, target_position, follow_range) || is_blocked) && !Constants.is_close_to_destination(body.global_transform.origin, target.global_transform.origin, 1)):
				_on_start_move(target_position, delta)
			else:
				_on_stop_move()
		else: 
			if(is_static_movement && Constants.is_close_to_destination(body.global_transform.origin, target_position)):
				_on_stop_move()

			_on_start_move(target_position, delta)

# Start movement, check if surround or simple follow movement
func _on_start_move(target_pos:Vector3, delta:float):
	if(is_surround):
		if(reset_surround_target):
			reset_surround_target = false
			_set_surround(true)
		target_position = _get_circle_position(target_pos, randomnum)

	if(away_from_target):
		_move_away_from_pos(target_position, delta)
	else:
		_move_to_pos(target_position, delta)

# Stop movement and stay stationary
func _on_stop_move():
	body.velocity = Vector3.ZERO  # Stop moving if within follow range
	var direction = (target.global_transform.origin - body.global_transform.origin).normalized()

	if(!override_face_player):
		_face_player(direction)

# Move to Vector3 position
func _move_to_pos(target_pos:Vector3, delta:float):
	nav_agent.target_position = target_pos

	var direction = (nav_agent.get_next_path_position() - body.global_transform.origin).normalized()
	body.velocity = body.velocity.lerp(direction * current_speed, 20 * delta)
	body.move_and_slide()

	if(!Constants.is_close_to_destination(body.global_transform.origin, target.global_transform.origin) && !override_face_player):
		_face_player(body.velocity)

# Move away from Vector3 position
func _move_away_from_pos(target_pos:Vector3, delta:float, distance:float = 3):
	var init_direction = (body.global_transform.origin - target_pos).normalized()
	var desired_position = body.global_transform.origin + init_direction * distance
	
	var nav_map = GameManager.navregion.get_navigation_map()
	var nav_mesh_position = NavigationServer3D.map_get_closest_point(nav_map, desired_position)

	nav_agent.target_position = nav_mesh_position
	var direction = (nav_agent.get_next_path_position() - body.global_transform.origin).normalized()

	body.velocity = body.velocity.lerp(direction * current_speed, 20 * delta)
	body.move_and_slide()

	if(!Constants.is_close_to_destination(body.global_transform.origin, target.global_transform.origin) && !override_face_player):
		_face_player(-body.velocity)

func _face_player(direction:Vector3):
	# Determine direction based on the x axis
	var abs_x = abs(direction.x)
	var abs_z = abs(direction.z)

	# Horizontal movement (left/right)
	if direction.x >= 0:
		animation_component._flip_anim(false)
	else:
		animation_component._flip_anim(true)
	# Vertical movement (up/down)
	if direction.z >= 0:
		dir_suffix = "_d"
	else:
		dir_suffix = "_u"

func _get_circle_position(target_pos:Vector3, random: float) -> Vector3:
	var kill_circle_centre = target_pos
	# Calculate the position on the XZ plane
	var angle = random * PI * 2.0
	var x = kill_circle_centre.x + cos(angle) * kill_radius
	var z = kill_circle_centre.z + sin(angle) * kill_radius

	return Vector3(x, kill_circle_centre.y, z)

func _is_moving() -> bool:
	if(body.velocity != Vector3.ZERO && state_is_moving):
		return true
	else:
		return false
