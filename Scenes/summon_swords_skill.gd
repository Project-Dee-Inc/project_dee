extends "res://Scripts/skill_component.gd"
@onready var weapon_passive: Node = $"../WeaponPassive"
@onready var skill_timer: Timer = $"../SkillTimer"
@onready var passive_timer: Timer = $"../PassiveTimer"

@export var is_test:bool = false
@export var max_passive:int
@export var skill_wait_time:float

var player_stats: Dictionary = {}

func _process(delta):
	if is_test and Input.is_action_just_pressed("attack"):
		_activate_skill()

func _activate_skill():
	if(!skill_timer.is_stopped()): 
		await(skill_timer.timeout)
	skill_timer.wait_time = skill_wait_time
	skill_timer.start()
	var current_pattern = weapon_passive.pattern
	current_pattern += 1
	if(max_passive < current_pattern):
		current_pattern = 1
	#auto changing weapons
	weapon_passive._deactivate_skill()
	weapon_passive.pattern = current_pattern

	passive_timer.wait_time = 10
	passive_timer.timeout.emit()
	
func _deactivate_skill():
	pass
