extends Node

var player:Node3D
var camera:Camera3D
var viewport:SubViewport

func _ready():
	_on_subscribe_events()
	_on_game_start()

# List events to listen for
func _on_subscribe_events():
	EventManager.add_listener(str(EventManager.EVENT_NAMES.ON_PLAYER_INITIALIZED),self,"_player_initialized")

# Test run: start game after 0.5 seconds and raise ON_START_GAME event
func _on_game_start():
	await get_tree().create_timer(0.5).timeout
	print("STARTING GAME")
	EventManager.raise_event(str(EventManager.EVENT_NAMES.ON_START_GAME), null)

# Once player is initialized, find player node
func _player_initialized(_params):
	player = _find_player_node()
	camera = _find_camera_node()

# Find player in all nested scenes to store global value
func _find_player_node() -> Node3D:
	return _find_node_recursive(get_tree().current_scene, "Player")

func _find_camera_node() -> Camera3D:
	return _find_node_recursive(get_tree().current_scene, "MainCamera")

func _find_node_recursive(parent: Node, nodeName: String) -> Node3D:
	if parent.name == nodeName and parent is Node3D:
		return parent as Node3D

	for child in parent.get_children():
		if child is Node:
			var result = _find_node_recursive(child, nodeName)
			if result:
				return result

	return null
