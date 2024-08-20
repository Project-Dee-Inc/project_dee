extends Node

var fsm: StateMachine
var movement_manager
var skill_manager

func enter():
	#print("In SHOOTER BASIC ATTACK AND FOLLOWING state!")
	movement_manager.is_blocked = true
	skill_manager._change_skill(0)
	skill_manager.current_skill._set_homing(false)

	movement_manager._set_surround(false)
	movement_manager._set_stay_in_range(true, 10)
	movement_manager._set_line_of_sight(true)
	movement_manager._state_moving(true)

func exit(next_state):
	fsm.change_to(next_state)

func _physics_process(_delta: float):
	if movement_manager.raycast._has_line_of_sight(movement_manager.target):
		if(movement_manager.is_blocked):
			await get_tree().create_timer(0.3).timeout
			if(is_instance_valid(movement_manager)):
				movement_manager.is_blocked = false
		if(is_instance_valid(skill_manager) && !skill_manager.state_is_attacking):
			skill_manager._state_attacking(true)
	else:
		if(skill_manager.state_is_attacking):
			skill_manager._state_attacking(false)
			movement_manager.is_blocked = true
