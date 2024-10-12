extends Node

@export var end_of_level_ui:Node
@export var gold_counter_text:Label

func _ready():
	_subscribe()

func _subscribe():
	EventManager.add_listener(str(EventManager.EVENT_NAMES.ON_END_GAME),self,"_show_end_of_level_ui")
	EventManager.add_listener(str(EventManager.EVENT_NAMES.ON_GOLD_UPDATED),self,"_display_gold_counter")

func _show_end_of_level_ui(_params):
	end_of_level_ui.visible = true

func _display_gold_counter(_params):
	gold_counter_text.text = str(GlobalStatManager.gold_count)
