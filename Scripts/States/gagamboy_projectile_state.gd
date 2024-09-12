extends Node

var fsm: StateMachine
var movement_manager
var skill_manager
var include_in_state_rand:bool = true
var skill_timeout:float = 15

func enter():
	print("In GAGAMBOY BASIC PROJECTILE AND FOLLOWING state!")
	# Set that movement is blocked on spawn to make sure it has correct sight of player
	movement_manager.is_blocked = true
	skill_manager._change_skill(0)
	skill_manager.current_skill._set_homing(false)

	# Start moving but make sure it stays in range of player and has line of sight
	movement_manager._set_surround(false)
	movement_manager._set_stay_in_range(true, 20)
	movement_manager._set_line_of_sight(true)
	movement_manager._state_moving(true)

	_randomize_next_attack()

func _randomize_next_attack():
	await get_tree().create_timer(skill_timeout).timeout

	var next_state = fsm._get_random_activatable_state()
	print("NEXT STATE IS ", next_state)

	if(next_state != self.name):
		pass
	else:
		_randomize_next_attack()

func exit(next_state):
	fsm.change_to(next_state)

# Only attack if shooter has line of sight
# If not, move to player 
func _physics_process(_delta: float):
	if movement_manager.raycast._has_line_of_sight(movement_manager.target):
		if(movement_manager.is_blocked):
			await get_tree().create_timer(0.3).timeout
			if(is_instance_valid(movement_manager)):
				movement_manager.is_blocked = false
		if(is_instance_valid(skill_manager) && !skill_manager.state_is_attacking):
			skill_manager._state_attacking(true)
			_randomize_next_attack()
	else:
		if(skill_manager.state_is_attacking):
			skill_manager._state_attacking(false)
			movement_manager.is_blocked = true
