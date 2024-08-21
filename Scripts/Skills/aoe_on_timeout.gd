extends "res://Scripts/skill_component.gd"
class_name AoeOnTimeout

@export var mesh_instance:MeshInstance3D 
@export var hit_body:PackedScene
@export var warning_color:Color = Color.RED

var original_material:StandardMaterial3D 

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

# Get common variables needed
func _set_values():
	if(stat_dict.has(Constants.get_enum_name_by_value(Constants.STATS.ATK))):
		damage = stat_dict[Constants.get_enum_name_by_value(Constants.STATS.ATK)]
	radius = stat_dict[Constants.get_enum_name_by_value(Constants.STATS.AOE)]
	cd = stat_dict[Constants.get_enum_name_by_value(Constants.STATS.CD)]

	# Warning time set to default at 30% of cd time
	warning_time = int(cd * 0.3)
	original_material = mesh_instance.get_active_material(0).duplicate()

# Raise flag if cd is completed fully
# Mainly for bomber, if cd is completed that means player hasn't killed it 
func _aoe_timeout():
	cd_completed = true

func _activate_skill():
	skill_is_active = true
	_set_off_aoe()

func _deactivate_skill():
	skill_is_active = false

# Start simple warning visual effects
# Change material color
func _start_warning():
	entered_warning_state = true
	var new_material = original_material as StandardMaterial3D
	if (new_material):
		new_material.albedo_color = warning_color
		mesh_instance.material_override = new_material

# Instantiate a copy of the base AoeHitCollider scene
func _set_off_aoe():
	var bomb_hit_collider = hit_body.instantiate() as Area3D
	var base_node = get_parent().parent_component

	var root_node = get_tree().current_scene
	root_node.add_child(bomb_hit_collider)
	bomb_hit_collider.global_transform.origin = base_node.global_transform.origin
	_set_aoe_values(bomb_hit_collider)

# Override this function to customize behavior per type
func _set_aoe_values(hit_collider:Area3D):
	pass
