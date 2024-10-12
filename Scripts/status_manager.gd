extends Node
class_name StatusManager

signal _entity_stats_updated
@export var base_stat: StatComponent
var active_effects: Dictionary = {}

var original_stats: Dictionary = {}
var current_stats: Dictionary = {}

func _ready():
	original_stats = base_stat.stat_dict
	_reset_stats()

func _reset_stats():
	current_stats = original_stats.duplicate()

func _apply_status_effect(effect: Constants.StatusEffect):
	# Check if the effect is already active
	if (effect.name in active_effects):
		if (effect.stackable):
			active_effects[effect.name].append(effect)
		#else:
			## Replace the existing effect
			#active_effects[effect.name] = [effect]
	else:
		active_effects[effect.name] = [effect]

	if(effect.name not in Constants.custom_status_effects):
		# Apply the effect's stat modifiers
		for key in effect.stat_modifiers.keys():
			if (Constants.get_enum_name_by_value(key) in current_stats):
				var stat_value = current_stats[Constants.get_enum_name_by_value(key)]
				var damage = effect.stat_modifiers[key]
				var reduction_amount: float = stat_value * damage
				current_stats[Constants.get_enum_name_by_value(key)] += reduction_amount
				#print("HERE Stat ", Constants.get_enum_name_by_value(key), ": ", stat_value, " - ", reduction_amount, " = ", current_stats[Constants.get_enum_name_by_value(key)])

		_entity_stats_updated.emit(current_stats)

		# Schedule the removal of the effect after its duration
		await get_tree().create_timer(effect.duration).timeout
		if (is_instance_valid(self)):
			_remove_status_effect(effect)
	else:
		_handle_custom_status_effects(effect.name, effect.duration)

func _handle_custom_status_effects(name:String, duration:float):
	if(name == "Silenced"):
		EventManager.raise_event(str(EventManager.EVENT_NAMES.ON_ENABLE_SKILL_INPUT), [false])
		await get_tree().create_timer(duration).timeout
		if (is_instance_valid(self)):
			EventManager.raise_event(str(EventManager.EVENT_NAMES.ON_ENABLE_SKILL_INPUT), [true])

func _remove_status_effect(effect: Constants.StatusEffect):
	if (effect.name in active_effects):
		var effects = active_effects[effect.name]
		effects.erase(effect)
		#print("HERE ", effect.name, " erased")
		
		# If no more effects of this type, remove the entry
		if (effects.size() == 0):
			active_effects.erase(effect.name)
		
		# Recalculate the stats
		_reset_stats()
		for key in active_effects.keys():
			for active_effect in active_effects[key]:
				for stat_key in active_effect.stat_modifiers.keys():
					if (Constants.get_enum_name_by_value(stat_key) in current_stats):
						current_stats[Constants.get_enum_name_by_value(stat_key)] += active_effect.stat_modifiers[stat_key]

		_entity_stats_updated.emit(current_stats)
