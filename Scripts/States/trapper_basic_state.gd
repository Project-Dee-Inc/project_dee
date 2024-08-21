extends Node

var fsm: StateMachine
var movement_manager
var skill_manager

func enter():
	#print("In TRAPPER BASIC ATTACK AND FOLLOWING state!")
	skill_manager._change_skill(0)

	movement_manager._set_surround(false)
	movement_manager._state_moving(true)

func exit(next_state):
	fsm.change_to(next_state)
