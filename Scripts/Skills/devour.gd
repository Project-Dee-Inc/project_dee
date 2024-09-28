extends "res://Scripts/skill_component.gd"
class_name Devour

@onready var bite_marker:Node3D = %BiteMarker
@onready var devour_aoe:Node3D = %DevourAoe

@export var jump_height: float = 1.0
@export var jump_duration: float = 1.0 

@export var temple_scene:PackedScene
@export var distance_from_center = 7.0  

var base:Node3D
var damage:int = 0
var speed:float = 0
var cd:float = 0
var aoe:float = 0
var skill_is_active:bool = false

var moving:bool = false
var move_timer:float = 0
var target_pos:Vector3 = Vector3(0,0,0)
var done_attacks:bool = false

var temples:Array = []
var positions:Array = []
var a_pattern_positions:Array = []
var b_pattern_positions:Array = []

func _ready():
	_get_values()
	_set_values()

	base = get_parent().get_parent()
	_calculate_spawn_positions()
	_spawn_temples_around_center()
	_set_pattern_positions()
	devour_aoe._set_cd(jump_duration + 1)

func _assign_new_values(new_stat_dict:Dictionary):
	_get_new_values(new_stat_dict)
	_set_values()

func _get_new_values(new_stat_dict:Dictionary):
	stat_dict = new_stat_dict

# Get needed values
func _set_values():
	damage = stat_dict[Constants.get_enum_name_by_value(Constants.STATS.ATK)]
	cd = stat_dict[Constants.get_enum_name_by_value(Constants.STATS.CD)]
	speed = stat_dict[Constants.get_enum_name_by_value(Constants.STATS.MOVE_SPD)]
	aoe = stat_dict[Constants.get_enum_name_by_value(Constants.STATS.AOE)]

# Set target to reference to the node's health component
func _set_target(value:Node):
	target = value.health_component

func _prep_skill():
	done_attacks = false
	_make_temples_visible(true)
	_start_marker_patterns()

func _activate_skill():
	attacking = true
	skill_is_active = true

func _deactivate_skill():
	attacking = false
	skill_is_active = false

func _calculate_spawn_positions():
	var center = base.global_transform.origin # Get base node position
	var num_objects = 8 # Define the number of objects to spawn (8 directions)
	var angle_increment = PI / 4.0 # Calculate angle increment (180 degrees / 4 = 45 degrees per slice)
	var half_offset = angle_increment / 2 # Offset to place the position at the center of each slice

	for i in range(num_objects):
		# Calculate the angle for each object, with offset for slice centering
		var angle: float
		if i < 4:
			# Left half (first 4 objects), centered around PI (180 degrees)
			angle = PI + i * angle_increment + half_offset
		else:
			# Right half (next 4 objects), centered around 0 (0 degrees)
			angle = (i - 4) * angle_increment + half_offset

		# Calculate the spawn position using trigonometry in the XZ plane
		var x = cos(angle) * distance_from_center
		var z = sin(angle) * distance_from_center
		var spawn_position = Vector3(x, 1, z) + center # Construct the spawn position as a Vector3 (x, y, z)

		# Add the calculated position to the list
		positions.append(spawn_position)

func _set_pattern_positions():
	a_pattern_positions = [positions[3], positions[0], positions[6], positions[4], positions[2], positions[5], positions[7]]
	b_pattern_positions = [positions[3], positions[5], positions[7], positions[4], positions[2], positions[0], positions[6]]

func _spawn_temples_around_center():
	for i in range(positions.size()):
		# Instance the object scene
		var new_object = temple_scene.instantiate()

		# Set the position of the new object
		new_object.position = positions[i]

		# Add the object to the current scene
		temples.append(new_object)
		add_child(new_object)

func _make_temples_visible(value:bool):
	for i in range(temples.size()):
		temples[i].visible = value

func _start_marker_patterns():
	bite_marker._set_speed(speed)

	var starter_position = positions[1]
	bite_marker.global_transform.origin = starter_position # Set the default position
	_set_marker_visible(true)

	await get_tree().create_timer(cd).timeout
	var random_pattern = true if randi() % 2 == 0 else false
	_execute_pattern(random_pattern, true)

func _execute_pattern(is_pattern_a:bool, is_marker:bool):
	for i in range(a_pattern_positions.size()):
		var next_pos
		if(is_pattern_a):
			next_pos = a_pattern_positions[i]
		else:
			next_pos = b_pattern_positions[i]

		if(is_marker):
			bite_marker._set_target_position(next_pos)
			await get_tree().create_timer(cd).timeout
		else:
			devour_aoe._move_to_position(next_pos)
			await get_tree().create_timer(1).timeout
			_set_target_position(next_pos)
			await get_tree().create_timer(cd - 1).timeout

	if(is_marker):
		_set_marker_visible(false)
		await get_tree().create_timer(cd).timeout
		_execute_pattern(is_pattern_a, false)
	else:
		_make_temples_visible(false)
		done_attacks = true

func _set_target_position(position:Vector3):
	_activate_skill()
	target_pos = position
	move_timer = 0
	moving = true

func _jump_to_target_position(delta: float):
	if (moving):
		move_timer += delta
		var t = move_timer / jump_duration

		if (t >= jump_duration):
			t = jump_duration
			_stop_movement()

		# Get the current position directly
		var current_position = base.global_transform.origin
		# Calculate the target position
		current_position = current_position.lerp(target_pos, t)
		# Adjust the height using a parabolic arc
		current_position.y += jump_height * (1 - t) * (1 - t)

		# Update the enemy's position
		base.global_transform.origin = current_position

func _stop_movement():
	moving = false
	_deactivate_skill()

func _set_marker_visible(value:bool):
	bite_marker.visible = value

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float):
	_jump_to_target_position(delta)

# If target is hit by the collider, deal damage
func _on_hit_collider_component_body_entered(_body):
	if(skill_is_active):
		target._damage(damage)

func _finished_skill() -> bool:
	return done_attacks
