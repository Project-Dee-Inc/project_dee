extends "res://Scripts/skill_component.gd"
class_name ExplodeOnTimeout

@export var mesh_instance:MeshInstance3D 
@export var hit_body:PackedScene

var original_material:StandardMaterial3D 
var warning_color:Color = Color.RED

var damage:int = 0
var radius:float = 0
var warning_time:float
var cd:float = 0

var entered_warning_state:bool = false
var cd_completed:bool = false
var skill_is_active:bool = false

func _ready():
	_get_values()
	_set_values()

func _set_values():
	damage = stat_dict[Constants.get_enum_name_by_value(Constants.STATS.ATK)]
	radius = stat_dict[Constants.get_enum_name_by_value(Constants.STATS.AOE)]
	cd = stat_dict[Constants.get_enum_name_by_value(Constants.STATS.CD)]

	warning_time = int(cd * 0.3)
	original_material = mesh_instance.get_active_material(0).duplicate()

func _aoe_timeout():
	cd_completed = true

func _activate_skill():
	skill_is_active = true
	_set_off_aoe()

func _deactivate_skill():
	skill_is_active = false

func _start_warning():
	entered_warning_state = true
	var new_material = original_material as StandardMaterial3D
	if (new_material):
		new_material.albedo_color = warning_color
		mesh_instance.material_override = new_material

func _set_off_aoe():
	var bomb_hit_collider = hit_body.instantiate() as Area3D
	var base_node = get_parent().parent_component

	bomb_hit_collider.global_transform.origin = base_node.global_transform.origin
	var root_node = get_tree().current_scene
	root_node.add_child(bomb_hit_collider)
	#get_parent().add_child(bomb_hit_collider)
	_set_aoe_values(bomb_hit_collider)

func _set_aoe_values(hit_collider:Area3D):
	var targets = Constants.TARGETS.BOTH
	if(!cd_completed):
		targets = Constants.TARGETS.ENEMY
		
	hit_collider._set_values(0.2, damage)
	hit_collider._set_aoe_damage_type(true)
	hit_collider._set_collider_radius(radius)
	hit_collider._set_collision_layer(Constants.TARGETS.ENEMY)
	hit_collider._set_collision_masks(targets)
	hit_collider._enable_character_bodies()
	hit_collider._enable_area_bodies()
	hit_collider._enable_collider(true)
