extends Node

var fsm: StateMachine
var movement_manager
var skill_manager

func enter():
	#print("In SHOOTER BASIC ATTACK AND FOLLOWING state!")
	skill_manager._change_skill(0)
	skill_manager.current_skill._set_homing(false)

	movement_manager._set_surround(false)
	movement_manager._set_stay_in_range(true, 10)
	movement_manager._set_line_of_sight(true)
	movement_manager._state_moving(true)

func exit(next_state):
	fsm.change_to(next_state)

func _physics_process(delta: float):
	if movement_manager.raycast.has_line_of_sight(movement_manager.target):
		if(!skill_manager.state_is_attacking):
			skill_manager._state_attacking(true)
	else:
		if(skill_manager.state_is_attacking):
			skill_manager._state_attacking(false)
		#move_towards_line_of_sight(enemy, delta)
