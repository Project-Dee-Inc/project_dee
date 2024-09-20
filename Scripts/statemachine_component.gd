extends Node
class_name StateMachine

@onready var movement_manager = $"../MovementComponent"
@onready var skill_manager = $"../SkillManagerComponent"

var current_state: Object
var is_dead:bool = false
var entity_health_percentage:float = 100

var history = []
var states = {}
var state_weights = {}
var last_picked_state:String = ""

func _ready():
	init_states()
	current_state.enter()

func init_states():
	for state in get_children():
		state.fsm = self
		state.movement_manager = movement_manager
		state.skill_manager = skill_manager
		states[state.name] = state
		if current_state:
			remove_child(state)
		else:
			current_state = state

func init_state_weights():
	for key in states:
		state_weights[key] = 1  # Default weight

func change_to(state_name):
	last_picked_state = current_state.name
	history.append(current_state.name)
	set_state(state_name)

func back():
	if history.size() > 0:
		set_state(history.pop_back())

func set_state(state_name):
	remove_child(current_state)
	current_state = states[state_name]
	add_child(current_state)
	current_state.enter()

func _get_random_activatable_state() -> String:
	var activatable_states = {}

	for key in states:
		if (states[key].include_in_state_rand == true):
			activatable_states[key] = states[key]

	if activatable_states.size() == 0:
		return ""

	# If last picked state exists, reduce weight/percentage
	if last_picked_state in state_weights:
		state_weights[last_picked_state] = max(0.1, state_weights[last_picked_state] * 0.5)  # Reduce by 50% (minimum weight 0.1)

	var total_weight = 0.0
	for key in activatable_states.keys():
		total_weight += state_weights.get(key, 1)

	randomize()
	var pick = randf() * total_weight
	var cumulative_weight = 0.0

	for key in activatable_states.keys():
		cumulative_weight += state_weights.get(key, 1)
		if pick <= cumulative_weight:
			# Reset picked state's weight
			state_weights[key] = 1.0
			last_picked_state = key
			return activatable_states[key].name
	
	return ""

func _on_death():
	if(current_state.has_method("exit")):
		current_state.exit("OnDeath")
		is_dead = true

func _is_dead() -> bool:
	return is_dead

func _check_health(max_health:int, cur_health:int):
	entity_health_percentage = Constants._get_health_percentage(cur_health, max_health)
