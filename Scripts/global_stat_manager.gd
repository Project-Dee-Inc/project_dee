extends Node
class_name GlobalStats

var player_stats:Dictionary
var gold_count:int = 0
var exp_count:int = 0

func _ready():
	_subscribe()

# List events to listen for
func _subscribe():
	EventManager.add_listener(str(EventManager.EVENT_NAMES.ON_GAIN_GOLD),self,"_increment_gold")
	EventManager.add_listener(str(EventManager.EVENT_NAMES.ON_GAIN_EXP),self,"_increment_exp")

func _increment_gold(param:Array):
	gold_count += param[0]
	EventManager.raise_event(str(EventManager.EVENT_NAMES.ON_GOLD_UPDATED), {})

func _increment_exp(param:Array):
	exp_count += param[0]
