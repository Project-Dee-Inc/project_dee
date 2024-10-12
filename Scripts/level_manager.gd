extends Node

func _init():
	EventManager.raise_event(str(EventManager.EVENT_NAMES.ON_ENABLE_SKILL_INPUT), [true])
	EventManager.raise_event(str(EventManager.EVENT_NAMES.ON_PLAY), {})
