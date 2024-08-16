extends Node3D
class_name Projectile

@export var turn_speed: float = 5.0

@onready var stat_component = $StatComponent
var stat_dict: Dictionary = {}
var base_target:Node3D
var target:Node
var body:Node

var speed:int = 0
var damage:int = 0
var is_homing:bool = false
var is_shooting:bool = false

var velocity:Vector3 = Vector3.ZERO
var manual_dir:Vector3

# Init
func _ready():
	_get_values()
	_set_values()

# Get copy of dictionary from referenced stats
func _get_values():
	stat_dict = stat_component.stat_dict

# Override method to get neccessary values from stat dictionary
func _set_values():
	damage = stat_dict[Constants.get_enum_name_by_value(Constants.STATS.ATK)]
	speed = stat_dict[Constants.get_enum_name_by_value(Constants.STATS.MOVE_SPD)]

func _shoot(base:Node3D, value:Node3D):
	body = base
	base_target = value.movement_component.character_body_3d
	target = value.health_component

	if(!is_homing):
		manual_dir = _get_direction(base_target.global_transform.origin, body.global_transform.origin)

	is_shooting = true

func _physics_process(delta:float):
	if(is_shooting):
		if(is_homing):
			_home_to_target(base_target.global_transform.origin, delta)
		else:
			_move_to_direction(manual_dir, delta)

func _get_direction(start:Vector3, end:Vector3) -> Vector3:
	var dir = (start - end).normalized()
	return dir

func _move_to_direction(direction:Vector3, delta:float):
	direction.y = 0
	body.global_transform.origin += direction * speed * delta

func _home_to_target(target_pos:Vector3, delta:float):
	if (base_target):
		var direction = _get_direction(base_target.global_transform.origin, body.global_transform.origin)
		var desired_velocity:Vector3 = direction * speed
		var steering:Vector3 = (desired_velocity - velocity) * delta * 2.5
		velocity += steering
		velocity.y = 0

		body.global_transform.origin += velocity * delta
		look_at(body.global_transform.origin + velocity * delta, Vector3.UP)
	else:
		# If no target, just move forward
		body.global_transform.origin = body.global_transform.basis.z.normalized() * speed

func _on_hit_collider_component_body_entered(_body):
	target._damage(damage)