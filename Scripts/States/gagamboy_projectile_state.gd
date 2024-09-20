extends Node

@onready var fsm_timer = %StateMachineTimer
var fsm: StateMachine
var movement_manager
var skill_manager
var include_in_state_rand:bool = true

@export var state_timeout:float = 15
var state_active:bool = false
var check_phase:bool = false
var check_los:bool = false
var is_second_phase:bool = false

func enter():
	print("In GAGAMBOY BASIC PROJECTILE AND FOLLOWING state!")
	state_active = true

	# Set that movement is blocked on spawn to make sure it has correct sight of player
	movement_manager.is_blocked = true
	skill_manager._change_skill(0)
	skill_manager._state_attacking(true)
	skill_manager.current_skill._set_homing(false)

	# Start moving but make sure it stays in range of player and has line of sight
	movement_manager._set_surround(false)
	movement_manager._set_stay_in_range(true, 20)
	movement_manager._set_line_of_sight(true)
	movement_manager._state_moving(true)

	check_los = true
	check_phase = true
	_prep_randomize_next_attack()

func _physics_process(_delta: float):
	_check_if_past_second_phase()
	_check_if_los()

func _cancel_state_mechanics():
	Constants._remove_all_timer_listeners(fsm_timer)
	movement_manager._set_stay_in_range(false)
	movement_manager._set_line_of_sight(false)
	skill_manager._state_attacking(false)
	check_los = false
	check_phase = false

func _prep_randomize_next_attack():
	if(state_active):
		Constants._start_timer_with_listener(fsm_timer, state_timeout, Callable(self, "_randomize_next_attack"))

func _randomize_next_attack():
	if(is_instance_valid(self)):
		Constants._stop_timer_and_remove_listener(fsm_timer, Callable(self, "_randomize_next_attack"))
		#var next_state = fsm._get_random_activatable_state()
		var next_state = "BullRushState"
		print("NEXT STATE IS ", next_state)

		if(next_state != self.name):
			exit(next_state)
		else:
			_prep_randomize_next_attack()

func _check_if_past_second_phase():
	if(!is_second_phase && check_phase):
		if(fsm.entity_health_percentage <= 50):
			print("STARTING SECOND PHASE PAST ", fsm.entity_health_percentage)

func _check_if_los():
	if(check_los):
		if movement_manager.raycast._has_line_of_sight(movement_manager.target):
			if(movement_manager.is_blocked):
				await get_tree().create_timer(0.3).timeout
				if(is_instance_valid(movement_manager)):
					movement_manager.is_blocked = false
			if(is_instance_valid(skill_manager) && !skill_manager.state_is_attacking):
				skill_manager._state_attacking(true)
				_prep_randomize_next_attack()
		else:
			if(skill_manager.state_is_attacking):
				skill_manager._state_attacking(false)
				movement_manager.is_blocked = true

func exit(next_state):
	state_active = false
	_cancel_state_mechanics()
	fsm.change_to(next_state)
