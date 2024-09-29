extends Node3D

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var tentacle_linger_timer: Timer = $TentacleLingerTimer
@onready var dot_timer: Timer = $DOTTimer
@onready var tentacle_front: Sprite3D = $Tentacle_front
@onready var tentacle_back: Sprite3D = $Tentacle_back

@export var enemies_size:Dictionary
@export var front_offset:float
@export var back_offset:float


func _move_tentacle(enemy_position:Vector3):
	position = enemy_position
	
func _activate_tentacle(duration:float):
	if(duration != -1):
		tentacle_linger_timer.wait_time = duration
	_randomize_look()
	set_visible(true)
	tentacle_linger_timer.start()
	_activate_animation()
	await (tentacle_linger_timer.timeout)
	_deactivate_animation()
	await(animation_tree.animation_finished)
	set_visible(false)
	
func _randomize_look():
	var rand = RandomNumberGenerator.new()
	var is_mirrored:bool = rand.randi() % 2
	var use_usual_order:bool = rand.randi() % 2
	tentacle_back.flip_h = is_mirrored
	tentacle_front.flip_h = is_mirrored
	if(use_usual_order):
		tentacle_back.sorting_offset =  back_offset
		tentacle_front.sorting_offset =  front_offset
	else:
		tentacle_back.sorting_offset =  front_offset
		tentacle_front.sorting_offset =  back_offset
		

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
	
