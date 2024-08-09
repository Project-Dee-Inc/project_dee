extends Node

var fsm: StateMachine
var movement_manager
var skill_manager

func enter():
	print("In FOLLOWING state!")
	movement_manager._state_moving(true)

	# Exit 0.5 seconds later
	await get_tree().create_timer(0.5).timeout
	movement_manager._state_moving(false)
	exit("BasicAttack")

func exit(next_state):
	fsm.change_to(next_state)
