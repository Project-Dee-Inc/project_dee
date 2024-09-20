extends Node

@onready var fsm_timer = %StateMachineTimer
@onready var skill_timer = %SkillTimer
var fsm: StateMachine
var movement_manager
var skill_manager
var include_in_state_rand:bool = true

@export var state_timeout:float = 20
var skill_num:int = 1
var state_active:bool = false
var check_phase:bool = false
var is_second_phase:bool = false
var is_rushing_active:bool = false
var moving_to_starting_point:bool = false

var rush_cd:float = 3
var target_pos:Vector3 = Vector3(0,0,0)

func enter():
	print("In GAGAMBOY BULLRUSH state!")
	skill_manager._change_skill(skill_num)

	_move_to_starting_point()

	state_active = true
	check_phase = true
	_prep_randomize_next_attack()

func _move_to_starting_point():
	target_pos = Vector3(0,0,0)
	moving_to_starting_point = true
	movement_manager._set_independent_movement(true)
	movement_manager._set_target_position(target_pos)
	movement_manager._state_moving(true)

func _wait_before_rushing_to_target(is_start:bool):
	movement_manager._state_moving(false)
	if(is_start):
		Constants._start_timer_with_listener(skill_timer, rush_cd, Callable(self, "_start_rushing_to_target"))
	else:
		Constants._start_timer_with_listener(skill_timer, rush_cd, Callable(self, "_stop_rushing_to_target"))

func _start_rushing_to_target():
	if(is_instance_valid(self)):
		Constants._stop_timer_and_remove_listener(skill_timer, Callable(self, "_start_rushing_to_target"))
		is_rushing_active = true
		skill_manager._state_attacking(true)

		movement_manager.current_speed = movement_manager.speed * skill_manager.current_skill.speed_multiplier
		movement_manager._set_independent_movement(true)
		movement_manager._set_static_movement(true)
		movement_manager._set_stay_in_range(false)

		target_pos = _get_extended_position(skill_manager.target, movement_manager.body, 5)
		movement_manager._set_target_position(target_pos)
		movement_manager._state_moving(true)

func _stop_rushing_to_target():
	Constants._stop_timer_and_remove_listener(skill_timer, Callable(self, "_stop_rushing_to_target"))
	movement_manager.current_speed = movement_manager.speed
	movement_manager._set_independent_movement(false)
	movement_manager._set_static_movement(false)
	movement_manager._set_stay_in_range(true, 1)
	movement_manager._state_moving(true)

	_wait_for_skill_cd()

func _wait_for_skill_cd():
	if(state_active):
		Constants._start_timer_with_listener(skill_timer, skill_manager.current_skill.cd, Callable(self, "_continue_rushing_to_target"))

func _continue_rushing_to_target():
	if(is_instance_valid(self)):
		Constants._stop_timer_and_remove_listener(skill_timer, Callable(self, "_continue_rushing_to_target"))
		_wait_before_rushing_to_target(true)

func _get_extended_position(player: Node3D, body:Node3D, offset_distance: float = 100) -> Vector3:
	var initial_direction = (player.global_transform.origin - body.global_transform.origin).normalized()

	# Extend the target position by the offset distance along the initial direction
	var extended_target_position = player.global_transform.origin + (initial_direction * offset_distance)

	# Check for closest walkable position
	var nav_map = GameManager.navregion.get_navigation_map()
	var closest_position = NavigationServer3D.map_get_closest_point(nav_map, extended_target_position)

	# Check if the generated position is walkable
	if !Constants._is_position_walkable(nav_map, closest_position):
		closest_position = initial_direction

	return closest_position

func _physics_process(_delta: float):
	_check_if_past_second_phase()
	_check_if_moving_to_starting_point()
	_check_if_rush_active()

func _buff_state(cd_buff:float, atk_buff:float, spd_buff:float):
	skill_manager.skills[skill_num].cd -= skill_manager.skills[skill_num].cd * cd_buff
	skill_manager.skills[skill_num].damage += skill_manager.skills[skill_num].damage * atk_buff
	skill_manager.skills[skill_num].speed_multiplier += skill_manager.skills[skill_num].speed_multiplier * spd_buff

func _cancel_state_mechanics():
	Constants._remove_all_timer_listeners(skill_timer)
	Constants._remove_all_timer_listeners(fsm_timer)
	check_phase = false
	_stop_rushing_to_target()

func _prep_randomize_next_attack():
	if(state_active):
		Constants._start_timer_with_listener(fsm_timer, state_timeout, Callable(self, "_randomize_next_attack"))

func _randomize_next_attack():
	if(is_instance_valid(self) && state_active):
		Constants._stop_timer_and_remove_listener(fsm_timer, Callable(self, "_randomize_next_attack"))
		var next_state = fsm._get_random_activatable_state()
		print("NEXT STATE IS ", next_state)

		if(next_state != self.name):
			exit(next_state)
		else:
			_prep_randomize_next_attack()

func _check_if_past_second_phase():
	if(!is_second_phase && check_phase):
		if(fsm.entity_health_percentage <= 50):
			print("STARTING SECOND PHASE FROM BULLRUSH PAST ", fsm.entity_health_percentage)
			check_phase = false
			exit("SecondPhaseState")

func _check_if_moving_to_starting_point():
	if(moving_to_starting_point):
		if(Constants.is_close_to_destination(movement_manager.body.global_transform.origin, target_pos, 1)):
			moving_to_starting_point = false
			_wait_before_rushing_to_target(true)

func _check_if_rush_active():
	if(is_rushing_active):
		if(Constants.is_close_to_destination(movement_manager.body.global_transform.origin, target_pos, 1.5)):
			is_rushing_active = false
			skill_manager._state_attacking(false)
			movement_manager.current_speed = 0
			_wait_before_rushing_to_target(false)

func exit(next_state):
	state_active = false
	_cancel_state_mechanics()
	fsm.change_to(next_state)
