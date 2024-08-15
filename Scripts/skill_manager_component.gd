extends Node
class_name SkillManager

@onready var parent_component = $".."
@export var skills:Array[BaseSkill]
var current_skill:BaseSkill
var state_is_attacking:bool = false
var target:Node

# Set initial skill
func _ready():
	current_skill = skills[0]

# Set if state is changed to attacking
# If target is still null, assign it
func _state_attacking(value:bool):
	if(value && target == null):
		target = GameManager.player
		for skill in skills:
			skill._set_target(target)

	state_is_attacking = value

	if(state_is_attacking):
		_attack()

# Change skill to activate
func _change_skill(value:int):
	current_skill = skills[value]

# Activate skill
func _attack():
	current_skill._activate_skill()
