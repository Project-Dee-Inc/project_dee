extends Node

var fsm: StateMachine
var movement_manager
var skill_manager

func enter():
	# Enter attacking state to detonate bomb skill
	skill_manager._state_attacking(true)
	# If haven't entered warning state, enter warning state right before explosion
	if(!skill_manager.current_skill.entered_warning_state):
		skill_manager.current_skill._start_warning()

	# Stop moving and despawn
	movement_manager._set_surround(false)
	movement_manager._state_moving(false)

	print(movement_manager.body.name, " enemy died.")
	await get_tree().create_timer(0.2).timeout
	movement_manager.body.queue_free()
