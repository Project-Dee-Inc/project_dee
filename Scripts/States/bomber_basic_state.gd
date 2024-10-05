extends Node

var fsm: StateMachine
var movement_manager
var skill_manager

func enter():
	#print("In BOMBER BASIC ATTACK AND FOLLOWING state!")
	skill_manager._change_skill(0)

	# Set with simple following
	movement_manager._set_surround(true)
	movement_manager._set_stay_in_range(true, 1)
	movement_manager._state_moving(true)

	# Enter warning state 
	await get_tree().create_timer(skill_manager.current_skill.cd - skill_manager.current_skill.warning_time).timeout
	if (is_instance_valid(skill_manager) && !skill_manager.current_skill.entered_warning_state):
		skill_manager.current_skill._start_warning()
		await get_tree().create_timer(skill_manager.current_skill.warning_time).timeout

	# Detonate bomb
	if (is_instance_valid(skill_manager)):
		skill_manager.current_skill._aoe_timeout()
		exit("OnDeath")

func exit(next_state):
	fsm.change_to(next_state)
