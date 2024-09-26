extends Node

@onready var fsm_timer = %StateMachineTimer
var fsm: StateMachine
var movement_manager
var skill_manager
var include_in_state_rand:bool = false

@export var state_timeout:float = 10
var skill_num:int = 2
var state_active:bool = false
var moving_to_starting_point:bool = false
var is_buffing:bool = false
var target_pos:Vector3 = Vector3(0,0,0)

func enter():
	print("In GAGAMBOY 2nd PHASE state!")
	state_active = true

	skill_manager._change_skill(skill_num)
	movement_manager._set_surround(false)

	_enable_2nd_phase_state()
	_move_to_starting_point()
	_prep_randomize_next_attack()

func _enable_2nd_phase_state():
	fsm.states["ProjectileState"].is_second_phase = true
	fsm.states["BullRushState"].is_second_phase = true
	fsm.states["DevourState"].include_in_state_rand = true

func _move_to_starting_point():
	moving_to_starting_point = true
	movement_manager._set_independent_movement(true)
	movement_manager._set_target_position(target_pos)
	movement_manager._state_moving(true)

func _stationary_buff():
	moving_to_starting_point = false
	is_buffing = true
	movement_manager._state_moving(false)
	movement_manager._set_independent_movement(false)
	_buff_states()
	_spawn_minions()

func _physics_process(_delta: float):
	_check_if_moving_to_starting_point()

func _check_if_moving_to_starting_point():
	if(moving_to_starting_point):
		if(Constants.is_close_to_destination(movement_manager.body.global_transform.origin, target_pos, 1) && !is_buffing):
			_stationary_buff()

func _buff_states():
	movement_manager._set_speed(movement_manager.current_speed + (movement_manager.current_speed * skill_manager.current_skill.spd_buff))
	fsm.states["ProjectileState"]._buff_state(skill_manager.current_skill.atk_buff, skill_manager.current_skill.proj_spd_buff, skill_manager.current_skill.proj_count_buff)
	fsm.states["BullRushState"]._buff_state(skill_manager.current_skill.cd_buff, skill_manager.current_skill.atk_buff, skill_manager.current_skill.spd_buff)

func _spawn_minions():
	skill_manager._state_attacking(true)

func _prep_randomize_next_attack():
	if(state_active):
		Constants._start_timer_with_listener(fsm_timer, state_timeout, Callable(self, "_randomize_next_attack"))

func _randomize_next_attack():
	if(is_instance_valid(self) && state_active):
		Constants._stop_timer_and_remove_listener(fsm_timer, Callable(self, "_randomize_next_attack"))
		var next_state = "DevourState"
		print("NEXT STATE IS ", next_state)

		if(next_state != self.name):
			exit(next_state)
		else:
			_prep_randomize_next_attack()

func _cancel_state_mechanics():
	Constants._remove_all_timer_listeners(fsm_timer)

func exit(next_state):
	state_active = false
	_cancel_state_mechanics()
	fsm.change_to(next_state)
