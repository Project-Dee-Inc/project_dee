extends Node
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
		
func spawn_eight_projectiles():
	create_weapons(projectile_script)
	animate_in(false)

func spawn_eight_rotating_swords():
	create_weapons(sword_script)
	animate_in(true)
	
func create_weapons(script:Script):
	if(spawn_container.get_children().size() != projectile_count):
		_empty_swords()
		for point in spawn_points:
			var p = weapon_scene.instantiate()
			sword_references.append(p)
			spawn_container.add_child(p)
			p.position = point
	for weapon:Node in spawn_container.get_children():
		print("Marvi changing scripts")
		if(weapon.get_script() != script):
			weapon.set_script(script)
			weapon.set_process(true)

func pick_random_projectile() -> Node3D:
	sword_references.shuffle()
	var node = sword_references[sword_references.size()-1]
	return node
	
func pick_and_remove_random_projectile() -> Node3D:
	sword_references.shuffle()
	var node = sword_references.pop_back()
	return node
	
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
