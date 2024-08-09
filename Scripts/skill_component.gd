extends Node
class_name BaseSkill

@export var stat_component:Node
@export var passive: bool
var stat_dict: Dictionary = {}
var target:Node

# Init
func _ready():
	_get_values()

# Get copy of dictionary from referenced stats
func _get_values():
	stat_dict = stat_component.stat_dict

# Override method to get neccessary values from stat dictionary
func _set_values():
	pass

# Override method for setting target and accessing component if needed
func _set_target(value:Node):
	pass

# Override method for skill checker, if within condition to activate skill
func _can_activate_skill():
	pass

# Override method for activating skill and its behavior
func _activate_skill():
	pass

# Override method to disable skill
func _deactivate_skill():
	pass
