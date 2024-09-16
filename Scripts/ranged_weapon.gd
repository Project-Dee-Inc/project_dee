extends Node3D

# Reference to the projectile scene
@export var projectile_scene: PackedScene
@export var shoot_interval: float = 3.0
@export var speed: float = 20.0
@export var damage_amount: int = 50 
@export var penetrating_shot: bool = false

# Internal timer to track shooting time
var _shoot_timer: float = 0.0

func _ready():
	# Initialize the timer
	_shoot_timer = shoot_interval

func _process(delta: float) -> void:
	# Update the shoot timer
	_shoot_timer -= delta
	if _shoot_timer <= 0:
		shoot_projectile()
		# Reset the timer
		_shoot_timer = shoot_interval

func shoot_projectile() -> void:
	if projectile_scene:
		var dir: Vector3
		# Create a new projectile instance
		var projectile = projectile_scene.instantiate()
			
		# Add the projectile to the scene
		get_parent().add_child(projectile)
		
		# Get the cursor position in 3D world space
		var camera = GameManager.camera
		var mouse_position = camera.get_viewport().get_mouse_position()
		var ray_origin = camera.project_ray_origin(mouse_position)
		var ray_target = ray_origin + camera.project_ray_normal(mouse_position) * 1000.0
		var param = PhysicsRayQueryParameters3D.new()
		param.from = ray_origin
		param.to = ray_target
		param.collide_with_areas
		var space_state = get_world_3d().direct_space_state
		var result = space_state.intersect_ray(param)
		
		if result:
			var intersection_point = result.position
			# Ignore Y component for the direction vector
			var direction = (intersection_point - global_transform.origin).normalized()
			direction.y = 0
			dir = direction
		
		# Calculate the direction ignoring Y
		var projectile_direction = (dir - global_transform.origin).normalized()
		
		# Set the projectile's position and direction
		projectile.global_transform.origin = global_transform.origin
		projectile.look_at(global_transform.origin, Vector3.UP)
		
		# Set the projectile's velocity
		projectile.set_direction(dir)
		
		projectile.set_speed(speed)
		projectile.set_damage(damage_amount)
		projectile.set_is_penetrating_shot(penetrating_shot)
