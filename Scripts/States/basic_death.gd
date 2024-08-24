extends Node

var fsm: StateMachine
var movement_manager
var skill_manager

# On death, stop moving and despawn
func enter():
	print(movement_manager.body.name, " enemy died.")
	movement_manager._set_surround(false)
	movement_manager._state_moving(false)
	movement_manager.body.queue_free()
