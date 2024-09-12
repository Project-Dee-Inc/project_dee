extends Node

var fsm: StateMachine
var movement_manager
var skill_manager
var include_in_state_rand:bool = false

# On death, stop moving and despawn
func enter():
	print(movement_manager.body.name, " enemy died.")
	movement_manager._set_surround(false)
	movement_manager._state_moving(false)
	await get_tree().create_timer(0.2).timeout
	movement_manager.body.queue_free()
