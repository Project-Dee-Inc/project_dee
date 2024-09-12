extends Node

var fsm: StateMachine
var movement_manager
var skill_manager
var include_in_state_rand:bool = false

func enter():
	print("In GAGAMBOY DEVOUR state!")
	# Set that movement is blocked on spawn to make sure it has correct sight of player
	movement_manager.is_blocked = true
	skill_manager._change_skill(0)
	skill_manager.current_skill._set_homing(false)

	# Start moving but make sure it stays in range of player and has line of sight
	movement_manager._set_surround(false)
	movement_manager._set_stay_in_range(true, 20)
	movement_manager._set_line_of_sight(true)
	movement_manager._state_moving(true)

func exit(next_state):
	fsm.change_to(next_state)
