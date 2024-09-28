extends Node
@onready var movement_component: Node = $"../MovementComponent"
@onready var skill_manager_component: SkillManager = $"../SkillManagerComponent"
@onready var state_machine_component: StateMachine = $"../StateMachineComponent"
@onready var base_node:Node3D = $".."

@export var animated_sprite: AnimatedSprite3D
@export var flash_duration: float = 1

var current_state: Constants.ANIM_STATE = Constants.ANIM_STATE.IDLE
var is_active:bool = true
var start_color = Color.RED
var end_color = Color.WHITE

var current_state_string:String

func _physics_process(_delta: float):
	if(is_active):
		if(state_machine_component._is_dead()):
			_handle_death()
		elif(skill_manager_component._is_attacking()):
			_set_anim_state(Constants.ANIM_STATE.ATTACK)
		elif(movement_component._is_moving()):
			_set_anim_state(Constants.ANIM_STATE.WALK)
		else:
			_set_anim_state(Constants.ANIM_STATE.IDLE)

func _flip_anim(value:bool):
	animated_sprite.flip_h = value

func _handle_death():
	is_active = false
	_set_anim_state(Constants.ANIM_STATE.DEATH)

func _handle_damage(_value:float):
	_set_anim_state(Constants.ANIM_STATE.HIT)

func _handle_warning(value:float):
	var flash = 0.1
	var tween = base_node.create_tween()
	tween.tween_property(animated_sprite, "modulate", start_color, flash)
	tween.tween_property(animated_sprite, "modulate", end_color, flash)

	# Loop the tween
	tween.set_loops(-1)

	# Stop the tween after a certain number of flashes
	tween.tween_interval(value * flash)  # Stop after warning state

func _set_anim_state(new_state: Constants.ANIM_STATE):
	var suffix = movement_component.dir_suffix
	var new_state_string = _state_to_animation_string(new_state) 

	if(current_state == Constants.ANIM_STATE.ATTACK):
		new_state_string += skill_manager_component.attack_suffix
	new_state_string += suffix

	if current_state_string && current_state_string != new_state_string:
		if(current_state == Constants.ANIM_STATE.ATTACK || current_state == Constants.ANIM_STATE.HIT || current_state == Constants.ANIM_STATE.DEATH):
			await get_tree().create_timer(0.5).timeout
		current_state = new_state
		current_state_string = new_state_string
		_play_animation(current_state_string)
	else:
		current_state = new_state
		current_state_string = new_state_string
		_play_animation(current_state_string)

func _state_to_animation_string(state: Constants.ANIM_STATE) -> String:
	match state:
		Constants.ANIM_STATE.IDLE:
			return "idle"
		Constants.ANIM_STATE.WALK:
			return "walk"
		Constants.ANIM_STATE.ATTACK:
			return "attack"
		Constants.ANIM_STATE.DEATH:
			return "death"
		Constants.ANIM_STATE.HIT:
			return "hit"
		_:
			return ""

func _play_animation(animation_name: String):
	if animated_sprite.animation != animation_name:
		if(animation_name.find("_") == -1):
			animation_name += "_d"
		animated_sprite.play(animation_name)
