extends Node

var fsm: StateMachine
var movement_manager
var skill_manager

func enter():
	print("In FOLLOWING state!")
	movement_manager._set_surround(false)
	movement_manager._state_moving(true)

	# Exit 3 seconds later
	await get_tree().create_timer(3).timeout
	exit("Surround")

func exit(next_state):
	fsm.change_to(next_state)
