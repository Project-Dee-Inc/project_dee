extends Node

class_name BaseSkill

@export var passive: bool
var stat_dict: Dictionary = {}

@onready var stat_component = $StatComponent

func _ready():
	stat_dict = stat_component.stat_dict
	
func _activate_skill():
	pass
	
func _deactivate_skill():
	pass
