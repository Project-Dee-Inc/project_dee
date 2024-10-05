extends Node

var fsm: StateMachine
var movement_manager
var skill_manager

func enter():
	#print("In FIGHTER BASIC ATTACK AND FOLLOWING state!")
	# Start attacking to keep damaging player every few seconds on contact
	skill_manager._change_skill(0)
	skill_manager._state_attacking(true)

	movement_manager._set_surround(true)
	movement_manager._set_stay_in_range(true, 1)
	movement_manager._state_moving(true)

func exit(next_state):
	fsm.change_to(next_state)
