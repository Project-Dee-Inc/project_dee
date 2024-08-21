extends Area3D
class_name AoeCollider

@export var allow_character_bodies:bool = false
@export var allow_area_bodies:bool = false
@export var hit_collider:CollisionShape3D

var hit_body:Area3D
var cd_collider:float = 0
var damage:float = 0

var is_damage_over_time:bool = false
var cd_time:float = 0
var cd_interval:float = 0

var is_damage_or_debuff:bool = false
var stat_name_to_debuff:String

# Called when the node enters the scene tree for the first time.
func _ready():
	hit_body = self
	_enable_collider(false)

func _set_values(cd_value:float, damage_value:float, over_time:bool = false, interval:float = 0, full_time:float = 0):
	cd_collider = cd_value
	damage = damage_value
	is_damage_over_time = over_time
	cd_interval = interval
	cd_time = full_time
	
func _set_aoe_damage_type(normal:bool = false, stat_name:String = ""):
	is_damage_or_debuff = normal
	stat_name_to_debuff = stat_name

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

func _set_collider_radius(value:float):
	var sphere = hit_collider.shape as SphereShape3D
	sphere.radius = value

func _set_collision_masks(target_type:Constants.TARGETS):
	match target_type:
		Constants.TARGETS.PLAYER:
			hit_body.collision_mask = (1 << 1)
		Constants.TARGETS.ENEMY:
			hit_body.collision_mask  = (1 << 2)
		Constants.TARGETS.BOTH:
			hit_body.collision_mask  = (1 << 1) | (1 << 2)

func _set_collision_layer(target_type:Constants.TARGETS):
	match target_type:
		Constants.TARGETS.PLAYER:
			hit_body.collision_layer = 2
		Constants.TARGETS.ENEMY:
			hit_body.collision_layer  = 3

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

	if(collision_target && collision_target != hit_body.get_parent()):
		#print("TARGET IS ", collision_target.name)
		_on_deal_aoe_damage(collision_target)

func _on_deal_aoe_damage(aoe_target):
	if(is_damage_or_debuff):
		aoe_target.health_component._damage(damage)
	else:
		var target_stats = aoe_target.stat_components.get_child(0)
		var stat_value = target_stats[stat_name_to_debuff]
		var reduction_amount: float = stat_value * damage
		stat_value -= reduction_amount
		target_stats[stat_name_to_debuff] = stat_value

	if (is_damage_over_time):
		var total_time: float = 0
		while total_time < cd_time:  # total_duration is the time over which the DOT should apply
			await get_tree().create_timer(cd_interval).timeout
			_on_deal_aoe_damage(aoe_target)
			total_time += cd_interval
		queue_free()  # After the total time has passed, free the object
	else:
		queue_free()
