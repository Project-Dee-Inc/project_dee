extends Node

var fsm: StateMachine
var movement_manager
var skill_manager

func enter():
	print("In BASIC ATTACK state!")
	skill_manager._change_skill(0)
	skill_manager._state_attacking(true)

	# Exit 0.5 seconds later
	await get_tree().create_timer(0.5).timeout
	skill_manager._state_attacking(false)
	exit("Follow")

func exit(next_state):
	fsm.change_to(next_state)
