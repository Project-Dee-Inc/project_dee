extends Node

var fsm: StateMachine
var movement_manager
var skill_manager

func enter():
	print("In SURROUND state!")
	movement_manager._set_surround(true)
	movement_manager._state_moving(true)

	# Exit 5 seconds later
	await get_tree().create_timer(5).timeout
	#movement_manager._state_moving(false)
	exit("Follow")

func exit(next_state):
	fsm.change_to(next_state)
