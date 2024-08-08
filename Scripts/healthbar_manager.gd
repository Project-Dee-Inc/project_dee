extends Node

var max_health:int = 0
var current_health:int = 0

@onready var health_bar = $HealthBar

func _ready():
	#EventManager.add_listener(str(EventManager.EVENT_NAMES.ON_PLAYER_INITIALIZED), self, "_cache_max_health")
	pass

func _cache_max_health(value:int):
	max_health = value
	health_bar.max_value = max_health
	health_bar.min_value = 0
	health_bar.value = max_health
	print(max_health)
	
func _set_current_health(value:int):
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
