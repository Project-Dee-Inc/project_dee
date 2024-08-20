extends CharacterBody3D

@onready var animation_tree = $AnimationTree
@onready var dash_timer: Timer = $DashTimer

@export var dash_multiplier:float = 3

var speed:float = 5.0
var speed_multiplier = 1
var face_direction

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle dash.
	if Input.is_action_just_pressed("dash") and dash_timer.is_stopped():
		dash_timer.start()
		speed_multiplier = dash_multiplier
		return

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction
	
	if(!dash_timer.is_stopped()):
		direction = face_direction
	else:
		var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		face_direction = direction
	
	
	if direction:	
		velocity.x = direction.x * speed * speed_multiplier
		velocity.z = direction.z * speed * speed_multiplier
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	
	if(direction == Vector3.ZERO):
		animation_tree.get("parameters/playback").travel("Idle")
	else:
		if(!dash_timer.is_stopped()):
			animation_tree.get("parameters/playback").travel("Dash")
		else:
			animation_tree.get("parameters/playback").travel("Walk")
			animation_tree.set("parameters/Dash/blend_position",Vector2(direction.x,direction.z))
			animation_tree.set("parameters/Idle/blend_position",Vector2(direction.x,direction.z))
			animation_tree.set("parameters/Walk/blend_position",Vector2(direction.x,direction.z))
		move_and_slide()
	if(dash_timer.is_stopped()):
		speed_multiplier = 1
	
