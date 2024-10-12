extends Node

@export var end_of_level_ui:Node

func _ready():
	_subscribe()

func _subscribe():
	EventManager.add_listener(str(EventManager.EVENT_NAMES.ON_END_GAME),self,"_show_end_of_level_ui")

func _show_end_of_level_ui(_params):
	end_of_level_ui.visible = true
