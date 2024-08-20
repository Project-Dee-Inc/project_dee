extends Node
class_name SkillManager

@onready var parent_component = $".."
var skills:Array[BaseSkill]
var current_skill:BaseSkill
var state_is_attacking:bool = false
var target:Node

# Set initial skill
func _ready():
	for skill in get_children():
		skills.append(skill)

	current_skill = skills[0]

# Set if state is changed to attacking
# If target is still null, assign it
func _state_attacking(value:bool):
	if(value && target == null):
		target = GameManager.player
		for skill in skills:
			skill._set_target(target)

	state_is_attacking = value
	_attack(state_is_attacking)

# Change skill to activate
func _change_skill(value:int):
	current_skill = skills[value]

# Activate skill
func _attack(value:bool):
	if(value):
		current_skill._activate_skill()
	else:
		current_skill._deactivate_skill()
