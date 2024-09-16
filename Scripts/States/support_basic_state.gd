extends Node

var fsm: StateMachine
var movement_manager
var skill_manager
var current_cluster_center: Vector3 = Vector3.ZERO

@export var update_interval: float = 0.1
var update_timer: float = 0.0

func enter():
	#print("In SUPPORT BASIC BUFF AND FOLLOWING state!")
	skill_manager._change_skill(0)
	skill_manager._state_attacking(true)

	movement_manager._set_surround(false)
	movement_manager._set_stay_in_range(true, 1)
	movement_manager._state_moving(true)

	# Initialize cluster finding
	follow_largest_cluster()

# Find largest cluster of enemies
func follow_largest_cluster():
	var enemy_positions = Constants.get_group_positions("enemies")
	if enemy_positions.size() > 0:
		current_cluster_center = Constants.find_group_center(enemy_positions)
	else:
		current_cluster_center = Vector3.ZERO  # No enemies to follow

# Update position
func _physics_process(delta):
	update_timer += delta
	if (update_timer >= update_interval):
		update_timer = 0.0
		follow_largest_cluster()

	# If cluster is available, override movement to follow new center cluster point
	if (current_cluster_center != Vector3.ZERO):
		movement_manager._set_independent_movement(true)
		movement_manager._set_target_position(current_cluster_center)
	else:
		# Reevaluate clusters if no valid cluster is found
		movement_manager._set_independent_movement(false)
		follow_largest_cluster()

func exit(next_state):
	fsm.change_to(next_state)
