extends Area3D

var immediate_geometry:ImmediateMesh
var damage = 0
@export var knockback:bool
@export var knockback_strength:float
@export var override_knockback_speed_multiplier:float = -1 
@export var player_root_location:Node3D
@export var stun:bool
@export var stun_length:float

@export var mesh1: MeshInstance3D
@export var mesh2: MeshInstance3D

func _ready():
	area_shape_entered
	area_entered.connect(_on_area_entered)

func _on_area_entered(body: Node3D):
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
	
func _apply_knockback(body: Node3D):
	print("knockback")
	#get values
	var parent = body.get_parent()
	#calculate new position
	var destination:Vector3
	print(player_root_location.global_position.distance_to(parent.global_position))
	if(player_root_location.global_position.distance_to(parent.global_position)>=1):
		destination = _calculate_knockback_location(player_root_location.global_position,parent.global_position)
	else:
		destination = _calculate_knockback_location(Vector3(0.01,0,0),parent.global_position)
	#raycast for collision
	
	destination = Vector3(destination.x,.5,destination.z)
	var source = Vector3(parent.global_position.x,.5,parent.global_position.z)
	
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(source, destination)
	query.collision_mask = 1 << 0
	query.collide_with_areas = false
	query.collide_with_bodies = true
	var result = space_state.intersect_ray(query)
	if(result):
		print("Collider ",result.collider.name)
		print(destination, " ", result.position)
			#if there was a collision move only to where the collision is, not beyond
		destination = result.position
	#print("Final: ", final_position, " Current: ", body.get_parent().global_position)

	_display_location(source, destination)
	_assign_knockback_target_pos(parent.movement_component, destination)
	
func _assign_knockback_target_pos(movement_component,final_position:Vector3):
	movement_component._set_independent_movement(true)
	movement_component._set_target_position(final_position)
	movement_component.current_speed = override_knockback_speed_multiplier * movement_component.speed
	var nav_agent:NavigationAgent3D =  movement_component.nav_agent

	await(nav_agent.navigation_finished)
	print("navigation finshed")
	_resume_movement(movement_component, nav_agent)
	
func _resume_movement(movement_component, nav_agent:NavigationAgent3D):
	if(stun):
		#to be changed when state manager is added
		pass
	movement_component._set_independent_movement(false)
	movement_component.current_speed = movement_component.speed
	
func _display_location(source:Vector3, destination:Vector3):
	mesh1.global_position = source
	mesh2.global_position = destination

func draw_ray(start: Vector3, end: Vector3):
	immediate_geometry.clear()
	immediate_geometry.begin(Mesh.PRIMITIVE_LINES, null)
	immediate_geometry.set_color(Color.GREEN)
	immediate_geometry.add_vertex(start)
	immediate_geometry.add_vertex(end)
	immediate_geometry.end()

func _calculate_knockback_location(root_location, target_location) -> Vector3:
	var direction = (target_location - root_location).normalized()
	var final_position:Vector3 =  target_location + (direction * knockback_strength)
	return final_position
