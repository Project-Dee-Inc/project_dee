extends CharacterBody3D

@export var speed = 2.0
@export var gravity = -9.81

@export var camera : Camera3DTexelSnapped

var target_velocity = Vector3.ZERO

func _ready():
	floor_snap_length = camera._texel_size * 2.0

func _process(delta):
	# We create a local variable to store the input direction.
	var direction = Vector3.ZERO
	# We check for each move input and update the direction accordingly.
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_up"):
		# Notice how we are working with the vector's x and z axes.
		# In 3D, the XZ plane is the ground plane.
		direction.z -= 1
	if Input.is_action_pressed("move_down"):
		direction.z += 1
	if direction != Vector3.ZERO:
		direction = direction.normalized()
	target_velocity.x = direction.x * speed
	target_velocity.z = direction.z * speed
	
	if not is_on_floor():
		target_velocity.y += (gravity * delta)
	else:
		target_velocity.y = 0.0
	
	velocity = target_velocity
	move_and_slide()
	# snap position to nearest texel
	#global_position = global_position.snapped(Vector3(
	#camera._texel_size * 0.5, 
	#camera._texel_size * 0.5 * 1.15470053838,
	#camera._texel_size))
