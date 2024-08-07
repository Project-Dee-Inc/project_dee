extends Node

var cooldown: int = 0
var player_stat_dict: Dictionary = {}

@onready var weapon_skill = $WeaponSkill
	
func _on_ready():
	cooldown = weapon_skill.stat_dict[Constants.get_enum_value_by_name("CD")]
	EventManager.add_listener(str(EventManager.EVENT_NAMES.ON_PLAYER_BASE_STATS_READY), self, "_get_player_stat") # Todo: Change this so it listens to "on weapon equipped" instead of "on player base stats ready"
	
func _get_player_stat(value: Dictionary):
	player_stat_dict = value
	
func _skill_activate():
	weapon_skill.player_stats = player_stat_dict
	weapon_skill._activate_skill()
 
