extends "res://Scripts/skill_component.gd"
class_name BuffOnAoe

@export var animated_sprite:AnimatedSprite3D
@export var aoe_collision_shape:CollisionShape3D
@export var buff_stat_component:Node

var buff_stat_dict:Dictionary = {}
var cd:float = 0
var heal:float = 0
var buff_value:float = 0
var buff_cd:float = 0
var radius:float = 0
var skill_is_active:bool = false
var stat_to_buff:Constants.STATS

func _ready():
	_get_values()
	_set_values()
	_set_collider_radius(radius)
	animated_sprite.pixel_size = radius * 0.035

func _assign_new_values(new_stat_dict:Dictionary):
	_get_new_values(new_stat_dict)
	_set_values()

func _get_new_values(new_stat_dict:Dictionary):
	stat_dict = new_stat_dict

func _get_values():
	super._get_values()
	buff_stat_dict = buff_stat_component.stat_dict

# Get needed values
func _set_values():
	stat_to_buff = Constants.STATS.ATK

	cd = stat_dict[Constants.get_enum_name_by_value(Constants.STATS.CD)]
	radius = stat_dict[Constants.get_enum_name_by_value(Constants.STATS.AOE)]

	heal = buff_stat_dict[Constants.get_enum_name_by_value(Constants.STATS.HP)]
	buff_value = buff_stat_dict[Constants.get_enum_name_by_value(stat_to_buff)]
	buff_cd = buff_stat_dict[Constants.get_enum_name_by_value(Constants.STATS.CD)]

# Set collider shape radius based on AOE
func _set_collider_radius(value:float):
	var sphere_shape = aoe_collision_shape.shape as SphereShape3D
	sphere_shape.radius = value

# Enable or disable skill and wait for cd before next
func _activate_skill():
	skill_is_active = true
	attacking = true
	animated_sprite.visible = attacking

	await get_tree().create_timer(0.45).timeout
	if (is_instance_valid(self)):
		_deactivate_skill()

func _deactivate_skill():
	skill_is_active = false
	attacking = false
	animated_sprite.visible = attacking

	await get_tree().create_timer(cd).timeout
	if (is_instance_valid(self)):
		_activate_skill()

# If ally within collider, buff
func _on_aoe_hit_collider_area_entered(area: Area3D):
	if(skill_is_active):
		var area_target = area.get_parent()
		if(area_target != get_parent().parent_component):
			_buff_allies(area_target)

func _buff_allies(buff_target:Node3D):
	var heal_amount = buff_target.health_component.max_health * heal
	buff_target.health_component._heal(heal_amount)
	#print("HERE HEALING ", buff_target.name, " FOR ", heal_amount)

	var target_status = buff_target.stat_components
	var string_name = Constants.get_enum_name_by_value(stat_to_buff) + " Buff"
	target_status._apply_status_effect(Constants.StatusEffect.new(string_name, buff_cd, false, {stat_to_buff: buff_value}))
	#print("HERE BUFFING ", buff_target.name)
