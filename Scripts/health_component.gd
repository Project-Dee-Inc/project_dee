extends Node

var max_health:int
var current_health:int

func _on_ready():
	EventManager.add_listener(str(EventManager.EVENT_NAMES.ON_PLAYER_BASE_STATS_READY), self, "_get_health")

# Damages!
func _damage(value:int):
	current_health = clamp(current_health - value, 0, max_health)

# Heals!
func _heal(value:int):
	current_health = clamp(current_health + value, 0, max_health)

func _get_health(value:Dictionary):
	max_health = Constants.get_enum_value_by_name("HP")
