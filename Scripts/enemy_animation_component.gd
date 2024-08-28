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

func _physics_process(delta: float):
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

func _handle_damage(value:float):
	var tween = base_node.create_tween()
	tween.tween_property(animated_sprite, "modulate", start_color, 0)
	tween.tween_property(animated_sprite, "modulate", end_color, flash_duration)
	tween.tween_callback(Callable(tween, "queue_free"))

func _set_anim_state(new_state: Constants.ANIM_STATE):
	if current_state != new_state:
		current_state = new_state
		_play_animation(_state_to_animation(new_state))

func _state_to_animation(state: Constants.ANIM_STATE) -> String:
	match state:
		Constants.ANIM_STATE.IDLE:
			return "idle"
		Constants.ANIM_STATE.WALK:
			return "walk"
		Constants.ANIM_STATE.ATTACK:
			return "attack"
		Constants.ANIM_STATE.DEATH:
			return "death"
		_:
			return ""

func _play_animation(animation_name: String):
	if animated_sprite.animation != animation_name:
		animated_sprite.play(animation_name)
