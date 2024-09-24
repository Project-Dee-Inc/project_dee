extends Node3D

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var tentacle_linger_timer: Timer = $TentacleLingerTimer
@onready var dot_timer: Timer = $DOTTimer


func _move_tentacle(enemy_position:Vector3):
	position = enemy_position
	
func _activate_tentacle(duration:float):
	if(duration != -1):
		tentacle_linger_timer.wait_time = duration
	set_visible(true)
	tentacle_linger_timer.start()
	_activate_animation()
	await (tentacle_linger_timer.timeout)
	_deactivate_animation()
	await(animation_tree.animation_finished)
	set_visible(false)
	
func _activate_animation():
	animation_tree["parameters/conditions/attack_finished"] = false
	animation_tree["parameters/conditions/attack_start"] = true

func _deactivate_animation():
	animation_tree["parameters/conditions/attack_start"] = false
	animation_tree["parameters/conditions/attack_finished"] = true

func _print_current_animation():
	var state_machine = animation_tree.get("parameters/playback")
	var current_state = state_machine.get_current_node()
	print("Current animation state: ", current_state)


func _on_check_box_toggled(toggled_on: bool) -> void:
	if(toggled_on):
		_activate_animation()
	else:
		_deactivate_animation()
	
