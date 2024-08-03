extends Node

@export var id:int
@onready var base_stat = $Stats/BaseStat


func _ready():
	EventManager.raise_event(str(EventManager.EVENT_NAMES.ON_PLAYER_BASE_STATS_READY), [1,base_stat.stat_dict])
