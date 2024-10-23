extends Node

enum EVENT_NAMES{
	ON_PLAY,
	ON_START_GAME,
	ON_END_GAME,
	ON_GAME_PAUSE,
	ON_PLAYER_BASE_STATS_READY,
	ON_PLAYER_HEALTH_CHANGED,
	ON_PLAYER_INITIALIZED,
	ON_PLAYER_DEATH,
	ON_ACTIVE_WEAPON_UPDATE,
	ON_WEAPON_EQUIP,
	ON_WEAPON_UNEQUIP,
	ON_SPAWN_OBJECT,
	ON_BOSS_HEALTH_CHANGED,
	ON_REFERENCE_POOL_MANAGER,
	ON_RETURN_POOL_MANAGER_REFERENCE,
	ON_ENABLE_SKILL_INPUT,
	ON_ENABLE_FACING,
	ON_GAIN_GOLD,
	ON_GOLD_UPDATED,
	ON_GAIN_EXP,
}

# Dynamically add a signal
func add_event(eventName: String):
	if not has_signal(eventName):
		add_user_signal(eventName)

# Add a listener to an event
func add_listener(eventName: String, target: Object, methodName: String):
	add_event(eventName)
	var callable = Callable(target, methodName)
	connect(eventName, callable)

# Remove a listener from an event
func remove_listener(eventName: String, target: Object, methodName: String):
	if has_signal(eventName):
		var callable = Callable(target, methodName)
		if is_connected(eventName, callable):
			disconnect(eventName, callable)

# Raise an event
func raise_event(eventName: String, params = []):
	if has_signal(eventName):
		emit_signal(eventName, params)
