extends Area3D

var damage = 0
@export var knockback:bool
@export var knockback_strength:float
@export var override_knockback_speed_multiplier:float = -1 
@export var player_root_location:Node3D
@export var stun:bool
@export var stun_length:float

func _ready():
	body_entered.connect(_on_area_entered)
	area_entered.connect(_on_area_entered)

func _on_area_entered(body: Node3D):
	print("areaentered")
	_apply_damage(body)
	if(knockback):
		_apply_knockback(body)

func _apply_damage(body:Node3D):
	var parent = body.get_parent()
	var health
	if(parent!=null and parent.get_script()):
		health = parent.health_component
	if(health!=null):
		health._damage(damage)
	else:
		print("Health not available")
	print("Damage! ", damage," ", body)
	
func _apply_knockback(body: Node3D):
	#get values
	var parent = body.get_parent()
	var direction = (body.get_parent().global_position - player_root_location.global_position).normalized()
	#check for obstacles
	#parent.global_position += direction * knockback_strength
	var final_position:Vector3 =  parent.global_position + (direction * knockback_strength)
	#raycast for collision
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(parent.global_position, final_position)
	var result = space_state.intersect_ray(query)
	
	if(result):
		#if there was a collision move only to where the collision is, not beyond
		final_position = result.position
	_assign_knockback_target_pos(parent.movement_component, final_position)
	
func _assign_knockback_target_pos(movement_component,final_position:Vector3):
	movement_component._set_independent_movement(true)
	movement_component._set_target_position(final_position)
	movement_component.current_speed = override_knockback_speed_multiplier * movement_component.speed
	var nav_agent:NavigationAgent3D =  movement_component.nav_agent
	nav_agent.navigation_finished.connect(_resume_movement.bind(movement_component, nav_agent))
	
func _resume_movement(movement_component, nav_agent:NavigationAgent3D):
	nav_agent.navigation_finished.disconnect(_resume_movement)
	if(stun):
		#to be changed when state manager is added
		pass
	movement_component._set_independent_movement(false)
	movement_component.current_speed = movement_component.speed
	
