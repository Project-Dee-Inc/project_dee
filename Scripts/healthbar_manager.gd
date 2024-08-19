extends Node

var max_health:int = 0
var current_health:int = 0

@onready var health_bar = $HealthBar

func _ready():
	EventManager.add_listener(str(EventManager.EVENT_NAMES.ON_PLAYER_HEALTH_CHANGED), self, "_set_current_health")

func _cache_max_health(value:int):
	max_health = value
	current_health = max_health
	health_bar.value = max_health
	health_bar.max_value = max_health
	health_bar.min_value = 0
	print("max health = %d" % max_health)
	
func _set_current_health(value:int):
	if(max_health == 0):
		_cache_max_health(value)
	else:
		current_health = value
	_update_healthbar()
	
func _on_test_reduce_health_pressed():
	current_health -= 5
	_update_healthbar()

func _on_test_restore_health_pressed():
	current_health += 5
	_update_healthbar()

func _update_healthbar():
	health_bar.value = current_health
	print(current_health)
