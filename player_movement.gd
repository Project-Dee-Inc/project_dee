extends Node3D

@onready var dash_timer: Timer = $DashTimer
@onready var player_component:CharacterBody3D

@export var dash_multiplier:float = 3
@export var animation_component: AnimationManager

var speed:float = 5.0
var speed_multiplier = 1
var face_direction

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _set_speed(value: float):
	speed = value
func _set_dash_multiplier(value: float):
	dash_multiplier = value

func _physics_process(delta):
	if player_component == null :
		player_component = get_parent()
		print("player_component not found")
		return
	# Add the gravity.
	if not player_component.is_on_floor():
		player_component.velocity.y -= gravity * delta

	# Handle dash.
	if Input.is_action_just_pressed("dash") and dash_timer.is_stopped():
		dash_timer.start()
		speed_multiplier = dash_multiplier
		return
		
	var direction
	
	if(!dash_timer.is_stopped()):
		direction = face_direction
	else:
		var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		face_direction = direction
	
	
	if direction:	
		player_component.velocity.x = direction.x * speed * speed_multiplier
		player_component.velocity.z = direction.z * speed * speed_multiplier
	else:
		player_component.velocity.x = move_toward(player_component.velocity.x, 0, speed)
		player_component.velocity.z = move_toward(player_component.velocity.z, 0, speed)
		
# sends to animation fo reflect movement
	if(animation_component != null):
		animation_component.change_idle_animation(direction, !dash_timer.is_stopped())
		
#if player needs to move, moves on screen
	if(direction != Vector3.ZERO):
		player_component.move_and_slide()
		
#resets dash multiplier
	if(dash_timer.is_stopped()):
		speed_multiplier = 1
	
