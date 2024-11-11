extends Node3D
class_name RotatingSwordsManager

@onready var animation_tree: AnimationTree = $"Rotating Swords/Animation Component/AnimationTree"

@export var spawn_container:Node3D
@export var projectile_count:int
@export var weapon_scene:PackedScene
@export var projectile_script:Script
@export var sword_script:Script
var sword_references:Array[Node3D]
var spawn_points:Array[Vector3]


func _ready():
	calculate_points_for_projectile_count(projectile_count)

func calculate_points_for_projectile_count(count):
	projectile_count = count
	var angles = []
	for i in range(projectile_count):
		angles.append((2 * PI * i) / projectile_count)
		
	# Calculate the coordinates for each point
	for angle in angles:
		var x = 1 * cos(angle)
		var z = 1 * sin(angle)
		spawn_points.append(Vector3(x, 0, z))

func calculate_locations_in_location_with_radius(center,radius, height) -> Array[Vector3]:
	var points:Array[Vector3] = []
	for i in range(8):
		var angle = randf() * TAU  # Random angle between 0 and 2π
		var distance = randf() * radius  # Random distance from center within the radius
		var x = distance * cos(angle)
		var z = distance * sin(angle)
		var random_point:Vector3 = center + Vector3(x, 0, z)  # Adjust y if it's 3D, otherwise set to 0
		random_point = Vector3(random_point.x, height, random_point.z)
		
		points.append(random_point)
	return points

#spawns projectiles to shoot to the enemy
func spawn_eight_projectiles():
	create_weapons(projectile_script,spawn_points)
	animate_in(false)

func spawn_eight_bullets_above(center:Vector3, radius:float, height:float):
	_empty_swords()
	var locations = calculate_locations_in_location_with_radius(center, radius, height)
	create_weapons(sword_script, locations, true, true)
		

func spawn_eight_rotating_swords(attack_immediately:bool = true):
	create_weapons(sword_script,spawn_points, attack_immediately)
	animate_in(true)
	
func create_weapons(script:Script, locations:Array, attack_immediately = true, is_top_level = false):
	#if necessary create a new set of weapons
	if(sword_references.size() != projectile_count or sword_references[0] == null):
		_empty_swords()
		for i in projectile_count:
			var p:Node3D = weapon_scene.instantiate()
			sword_references.append(p)
			spawn_container.add_child(p)
	# set values for weapons
	for i in projectile_count:
		if(is_top_level):
			sword_references[i].global_position = locations[i]
			sword_references[i].top_level = true
		else:
			sword_references[i].top_level = false
			sword_references[i].position = locations[i]
	#set script values for weapons
	for weapon:Node3D in spawn_container.get_children():
		if(weapon.get_script() != script):
			weapon.set_script(script)
			weapon.set_process(true)
		if(weapon.get_script() ==  sword_script):
			var sword_script_ref:Sword = weapon as Sword
			sword_script_ref.area_active = attack_immediately
			sword_script_ref.set_moving_object_values()
			sword_script_ref._add_object_destination(Vector3(weapon.global_position.x,0,weapon.global_position.z))


func pick_random_projectile() -> Node3D:
	sword_references.shuffle()
	var node = sword_references[sword_references.size()-1]
	return node
	
func destroy_projectile(projectile:Node3D):
	projectile.queue_free()
	
func pick_and_remove_random_projectile() -> Node3D:
	sword_references.shuffle()
	var node = sword_references.pop_back()
	return node

func move_sword_to(node:Node3D):
	reparent(node,false)
	self.position = Vector3(0,-0.484,0)

func set_weapon_visible(is_visible:bool):
	if(is_visible):
		spawn_container.scale = Vector3(1,1,1)
	else:
		spawn_container.scale = Vector3(.001,.001,.001)

func animate_in(rotating):
	animation_tree["parameters/conditions/rotating"] = rotating
	animation_tree["parameters/conditions/attacking_start"] = true
	animation_tree["parameters/conditions/attacking_stopped"] = false
		
func animate_out():
	animation_tree["parameters/conditions/attacking_stopped"] = true
	animation_tree["parameters/conditions/attacking_start"] = false

func _empty_swords():
	sword_references.clear()
	for child in spawn_container.get_children():
		child.free()
		
