extends Node

@onready var collision_shape: CollisionShape3D = $"../../BodyHitCollider/CollisionShape3D"
@onready var fsm_timer = %StateMachineTimer
@onready var skill_timer = %SkillTimer
var fsm: StateMachine
var movement_manager
var skill_manager
var health_manager
var include_in_state_rand:bool = false

var skill_num:int = 3
var state_active:bool = false
var started_attack:bool = false
var moving_to_starting_point:bool = false

var initial_collider_radius:float
var target_pos:Vector3 = Vector3(0,0,0)

func enter():
	print("In GAGAMBOY DEVOUR state!")
	state_active = true

	skill_manager._change_skill(skill_num)

	_set_invulnerable()
	_set_collider_radius(skill_manager.current_skill.aoe)
	_move_to_starting_point()

func _set_invulnerable():
	health_manager = get_parent().get_parent().health_component
	health_manager._set_can_damage(false)

func _set_collider_radius(radius:float):
	if (collision_shape.shape is CapsuleShape3D):
		var capsule_shape: CapsuleShape3D = collision_shape.shape
		if(!initial_collider_radius):
			initial_collider_radius = capsule_shape.radius
		capsule_shape.radius = radius

func _move_to_starting_point():
	started_attack = false
	target_pos = Vector3(0,0,0)
	moving_to_starting_point = true
	movement_manager._set_independent_movement(true)
	movement_manager._set_target_position(target_pos)
	movement_manager._state_moving(true)

func _physics_process(_delta: float):
	_check_if_moving_to_starting_point()

func _check_if_moving_to_starting_point():
	if(moving_to_starting_point):
		if(Constants.is_close_to_destination(movement_manager.body.global_transform.origin, target_pos, 1)):
			moving_to_starting_point = false
			movement_manager._state_moving(false)

			skill_manager.current_skill._prep_skill()
			started_attack = true

	if(started_attack && skill_manager.current_skill._finished_skill()):
		started_attack = false
		_randomize_next_attack()

func _randomize_next_attack():
	if(is_instance_valid(self) && state_active):
		Constants._stop_timer_and_remove_listener(fsm_timer, Callable(self, "_randomize_next_attack"))
		var next_state = fsm._get_random_activatable_state()
		print("NEXT STATE IS ", next_state)

		if(next_state != self.name):
			exit(next_state)
		else:
			_randomize_next_attack()

func _cancel_state_mechanics():
	_set_collider_radius(initial_collider_radius)
	health_manager._set_can_damage(true)
	Constants._remove_all_timer_listeners(skill_timer)
	Constants._remove_all_timer_listeners(fsm_timer)

func exit(next_state):
	state_active = false
	_cancel_state_mechanics()
	fsm.change_to(next_state)
