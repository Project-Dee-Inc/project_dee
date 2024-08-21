extends Area3D
class_name AoeCollider

@export var allow_character_bodies:bool = false
@export var allow_area_bodies:bool = false
@export var hit_collider:CollisionShape3D

var base_node:Node
var hit_body:Area3D
var cd_collider:float = 0
var damage:float = 0

var is_damage_over_time:bool = false
var cd_time:float = 0
var cd_interval:float = 0

var is_damage_or_debuff:bool = false
var stat_to_debuff:Constants.STATS

# Called when the node enters the scene tree for the first time.
func _ready():
	hit_body = self
	_enable_collider(false)

func _set_base_node(value:Node):
	base_node = value

func _set_values(cd_value:float, damage_value:float, over_time:bool = false, interval:float = 0, full_time:float = 0):
	cd_collider = cd_value
	damage = damage_value
	is_damage_over_time = over_time
	cd_interval = interval
	cd_time = full_time

func _set_aoe_damage_type(normal:bool = false, stat_name:Constants.STATS = Constants.STATS.ATK):
	is_damage_or_debuff = normal
	stat_to_debuff = stat_name

func _enable_character_bodies():
	allow_character_bodies = true

func _enable_area_bodies():
	allow_area_bodies = true

func _enable_collider(value:bool):
	var visible_value = !value
	hit_collider.disabled = visible_value

	if(!visible_value):
		await get_tree().create_timer(cd_collider).timeout
		_enable_collider(false)
		queue_free()

func _set_collider_radius(value:float):
	var sphere = hit_collider.shape as SphereShape3D
	sphere.radius = value

func _set_collision_masks(target_type:Constants.TARGETS):
	Constants.set_collision_masks(hit_body, target_type)

func _set_collision_layer(target_type:Constants.TARGETS):
	Constants.set_collision_layer(hit_body, target_type)

func _on_area_entered(_area):
	if(allow_area_bodies):
		_deal_damage_to_target(_area)

func _on_body_entered(_body):
	if(allow_character_bodies):
		_deal_damage_to_target(_body)

func _deal_damage_to_target(target_node):
	var collision_target
	if(target_node is CharacterBody3D):
		collision_target = target_node.get_parent().get_parent()
	elif(target_node is Area3D):
		collision_target = target_node.get_parent()

	if(collision_target && collision_target != base_node):
		_on_deal_aoe_damage(collision_target)

func _on_deal_aoe_damage(aoe_target):
	#print("TARGET IS ", aoe_target.name)
	if(is_damage_or_debuff):
		aoe_target.health_component._damage(damage)
	else:
		var target_stats = aoe_target.stat_components.get_child(0).stat_dict
		var stat_value = target_stats[Constants.get_enum_name_by_value(stat_to_debuff)]
		#print("HERE INITIAL ", target_stats[Constants.get_enum_name_by_value(stat_to_debuff)])

		var reduction_amount: float = stat_value * damage
		stat_value -= reduction_amount
		target_stats[Constants.get_enum_name_by_value(stat_to_debuff)] = stat_value
		#print("HERE NEW ", target_stats[Constants.get_enum_name_by_value(stat_to_debuff)])

	#if (is_damage_over_time):
		#var total_time: float = 0
		#while total_time < cd_time:  # total_duration is the time over which the DOT should apply
			#await get_tree().create_timer(cd_interval).timeout
			#_on_deal_aoe_damage(aoe_target)
			#total_time += cd_interval
		#queue_free()  # After the total time has passed, free the object
	#else:
		#queue_free()
