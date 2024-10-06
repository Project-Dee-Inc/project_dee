extends "res://Scripts/skill_component.gd"
@onready var weapon_passive: Node = $"../WeaponPassive"
@onready var skill_timer: Timer = $"../SkillTimer"

@export var is_test:bool = false
@export var max_passive:int
@export var skill_wait_time:float

var player_stats: Dictionary = {}

func _process(delta):
	if is_test and Input.is_action_just_pressed("attack"):
		_activate_skill()

func _activate_skill():
	if(!skill_timer.is_stopped()): pass
	skill_timer.wait_time = skill_wait_time
	skill_timer.start()
	var current_pattern = weapon_passive.pattern
	current_pattern += 1
	if(max_passive < current_pattern):
		current_pattern = 1
	weapon_passive.pattern = current_pattern
	
func _deactivate_skill():
	pass
