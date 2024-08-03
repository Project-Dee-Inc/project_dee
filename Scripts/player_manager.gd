extends Node

@onready var base_stat = $Stats/BaseStat

func _ready():
	EventManager.raise_event(str(EventManager.EVENT_NAMES.ON_PLAYER_BASE_STATS_READY), [base_stat.stat_dict])
