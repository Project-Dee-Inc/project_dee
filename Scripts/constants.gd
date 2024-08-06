extends Node

enum WEAPON_TYPES{
	MELEE,
	RANGE,
	MAGIC
}

enum STATS { 
	ATK,
	C_RATE, 
	C_DMG, 
	PEN, 
	HP,
	HP_REGEN,
	DEF,
	ATK_SPD,
	MOVE_SPD,
	CD,
	CD_HASTE,
	ENERGY,
	ENERGY_REGEN,
	AOE,
	SKILL_DURATION,
	PROJ_COUNT,
	EXP_GAIN,
	GOLD_GAIN,
}

var stats_enum_mapping = {
	"ATK": STATS.ATK,
	"C_RATE": STATS.C_RATE, 
	"C_DMG": STATS.C_DMG, 
	"PEN": STATS.PEN, 
	"HP": STATS.HP,
	"HP_REGEN": STATS.HP_REGEN,
	"DEF": STATS.DEF,
	"ATK_SPD": STATS.ATK_SPD,
	"MOVE_SPD": STATS.MOVE_SPD,
	"CD": STATS.CD,
	"CD_HASTE": STATS.CD_HASTE,
	"ENERGY": STATS.ENERGY,
	"ENERGY_REGEN": STATS.ENERGY_REGEN,
	"AOE": STATS.AOE,
	"SKILL_DURATION": STATS.SKILL_DURATION,
	"PROJ_COUNT": STATS.PROJ_COUNT,
	"EXP_GAIN": STATS.EXP_GAIN,
	"GOLD_GAIN": STATS.GOLD_GAIN
}
var reverse_stats_enum_mapping = {}

func get_enum_value_by_name(name: String) -> int:
	return stats_enum_mapping.get(name, -1)  # Return -1 if not found
	
func _ready():
	for key in stats_enum_mapping.keys():
		reverse_stats_enum_mapping[stats_enum_mapping[key]] = key

func get_enum_name_by_value(value: int) -> String:
	return reverse_stats_enum_mapping.get(value, "Unknown Stat")  # Return "Unknown Stat" if not found
