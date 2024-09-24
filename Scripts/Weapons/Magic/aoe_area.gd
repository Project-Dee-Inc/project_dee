extends Node3D
class_name AOEReference


@onready var area_3d: Area3D = $Area3D



func get_enemies()->Array:
	var enemies_in_collider:Array
	var overlapping_areas = area_3d.get_overlapping_areas()
	for area in overlapping_areas:
		enemies_in_collider.append(area.get_parent())
		print("Enemy already inside: ", area)
	return enemies_in_collider
