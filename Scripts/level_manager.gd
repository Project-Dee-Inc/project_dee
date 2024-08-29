extends Node

var _levels = ["1", "2", "3", "4", "5", "6", "7", "8"]
var _levels_complete = []
var _level_progress_count = 1

func _ready():
	randomize()
	_levels_complete = _levels.duplicate()
	_levels.shuffle()
	get_level()
		
func get_level():
	if _levels.is_empty():
		_levels = _levels_complete.duplicate()
		_levels.shuffle()
		print("itowrks")
		
func level_progress():
	_level_progress_count += 1
