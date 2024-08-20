extends Node

var fsm: StateMachine
var movement_manager
var skill_manager

func enter():
	skill_manager._state_attacking(true)

	movement_manager._set_surround(false)
	movement_manager._state_moving(false)

	print(movement_manager.body.name, " enemy died.")
	await get_tree().create_timer(0.2).timeout
	movement_manager.body.queue_free()
