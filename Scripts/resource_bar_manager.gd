extends Node

var max_health:int = 0
var current_health:int = 0

@export var is_player_or_boss:bool = false
@export var boss_name:String 

@export var resource_bar_path: NodePath

# Health bar display
@onready var resource_bar = get_node(resource_bar_path)

func _ready():
	if(is_player_or_boss):
		EventManager.add_listener(str(EventManager.EVENT_NAMES.ON_PLAYER_HEALTH_CHANGED), self, "_set_current_resource_value")
	else:
		EventManager.add_listener(str(EventManager.EVENT_NAMES.ON_BOSS_HEALTH_CHANGED), self, "_set_boss_health")

func _exit_tree():
	if(is_player_or_boss):
		EventManager.remove_listener(str(EventManager.EVENT_NAMES.ON_PLAYER_HEALTH_CHANGED), self, "_set_current_resource_value")
	else:
		EventManager.remove_listener(str(EventManager.EVENT_NAMES.ON_BOSS_HEALTH_CHANGED), self, "_set_boss_health")

# Set max health.
func _cache_max_health(value:int):
	max_health = value
	current_health = max_health
	resource_bar.value = max_health
	resource_bar.max_value = max_health
	resource_bar.min_value = 0

func _set_boss_health(params:Array):
	if(params[0] == boss_name):
		_set_current_resource_value(params[1])

# Set current health.
func _set_current_resource_value(value:int):
	if(max_health == 0):
		_cache_max_health(value)
	else:
		current_health = value
	_update_healthbar()

# Updates health bar display.
func _update_healthbar():
	resource_bar.value = current_health
