extends Node

enum EVENT_NAMES{
	ON_PLAYER_BASE_STATS_READY,
	ON_START_GAME,
	ON_PLAYER_HEALTH_CHANGED
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
