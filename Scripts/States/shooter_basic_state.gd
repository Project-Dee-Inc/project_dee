extends Node

var fsm: StateMachine
var movement_manager
var skill_manager

func enter():
	#print("In SHOOTER BASIC ATTACK AND FOLLOWING state!")
	skill_manager._change_skill(0)
	skill_manager.current_skill._set_homing(false)
	skill_manager._state_attacking(true)

	movement_manager._set_surround(false)
	movement_manager._set_stay_in_range(true, 10)
	movement_manager._state_moving(true)

func exit(next_state):
	fsm.change_to(next_state)
