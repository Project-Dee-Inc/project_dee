extends Node

class_name BaseSkill

@export var passive: bool
var stat_dict: Dictionary = {}

@onready var stat_manager = $StatManager

func _ready():
	stat_dict = stat_manager.stat_dict
	
func _activate_skill():
	pass
	
func _deactivate_skill():
	pass
