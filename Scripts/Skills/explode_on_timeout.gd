extends "res://Scripts/skill_component.gd"
class_name ExplodeOnTimeout

@export var mesh_instance:MeshInstance3D 
@export var hit_collider:CollisionShape3D

var original_material:StandardMaterial3D 
var warning_color:Color = Color.RED
var hit_body:Area3D

var damage:int = 0
var radius:float = 0
var warning_time:float
var cd:float = 0

var entered_warning_state:bool = false
var cd_completed:bool = false
var skill_is_active:bool = false

func _ready():
	hit_collider.disabled = true
	_get_values()
	_set_values()

func _set_values():
	damage = stat_dict[Constants.get_enum_name_by_value(Constants.STATS.ATK)]
	radius = stat_dict[Constants.get_enum_name_by_value(Constants.STATS.AOE)]
	cd = stat_dict[Constants.get_enum_name_by_value(Constants.STATS.CD)]
	warning_time = int(cd * 0.3)
	_set_collider_values()

func _set_collider_values():
	original_material = mesh_instance.get_active_material(0).duplicate()
	hit_body = hit_collider.get_parent()
	var sphere = hit_collider.shape as SphereShape3D
	sphere.radius = radius

func _bomb_timeout():
	cd_completed = true

func _activate_skill():
	skill_is_active = true
	_set_collision_masks(cd_completed)
	_set_off_bomb()

func _deactivate_skill():
	skill_is_active = false

func _set_collision_masks(include_player:bool):
	if(include_player):
		hit_body.collision_mask  = (1 << 1) | (1 << 2)
	else:
		hit_body.collision_mask  = (1 << 2)

func _start_warning():
	entered_warning_state = true
	var new_material = original_material as StandardMaterial3D
	if (new_material):
		new_material.albedo_color = warning_color
		mesh_instance.material_override = new_material

func _set_off_bomb():
	hit_collider.disabled = false

func _on_hit_collider_component_body_entered(_body):
	_deal_damage_to_target(_body)

func _on_hit_collider_component_area_entered(_area):
	_deal_damage_to_target(_area)

func _deal_damage_to_target(target_node):
	#print("MASKS FOR ", hit_body.collision_mask)
	if(skill_is_active):
		var bomb_target
		if(target_node is CharacterBody3D):
			bomb_target = target_node.get_parent().get_parent()
		elif(target_node is Area3D):
			bomb_target = target_node.get_parent()

		if(bomb_target):
			bomb_target.health_component._damage(damage)
