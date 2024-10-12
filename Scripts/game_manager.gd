extends Node

var player:Node3D
var camera:Camera3D

var navregion:NavigationRegion3D
var nav_mesh_bounds:AABB = AABB()
var viewport:SubViewport

func _ready():
	_on_subscribe_events()

# List events to listen for
func _on_subscribe_events():
	EventManager.add_listener(str(EventManager.EVENT_NAMES.ON_PLAY),self,"_on_game_start")
	EventManager.add_listener(str(EventManager.EVENT_NAMES.ON_PLAYER_INITIALIZED),self,"_player_initialized")
	EventManager.add_listener(str(EventManager.EVENT_NAMES.ON_PLAYER_DEATH),self,"_on_game_end")
	EventManager.add_listener(str(EventManager.EVENT_NAMES.ON_GAME_PAUSE),self,"_on_game_pause")

# Test run: start game after 0.5 seconds and raise ON_START_GAME event
func _on_game_start(_params):
	await get_tree().create_timer(0.5).timeout
	EventManager.raise_event(str(EventManager.EVENT_NAMES.ON_START_GAME), {})

func _on_game_end(_params):
	EventManager.raise_event(str(EventManager.EVENT_NAMES.ON_END_GAME), {})
	EventManager.raise_event(str(EventManager.EVENT_NAMES.ON_GAME_PAUSE), [true])

func _on_game_pause(param:Array):
	get_tree().paused = param[0]

# Once player is initialized, find player node
func _player_initialized(_params):
	player = _find_player_node()
	camera = _find_camera_node()
	navregion = _find_navmesh_node()
	nav_mesh_bounds = Constants._calculate_navigation_mesh_bounds(navregion.navmesh)

# Find nodes in all nested scenes to store global value
func _find_player_node() -> Node3D:
	return _find_node_recursive(get_tree().current_scene, "Player")

func _find_camera_node() -> Camera3D:
	return _find_node_recursive(get_tree().current_scene, "MainCamera")

func _find_navmesh_node() -> NavigationRegion3D:
	return _find_node_recursive(get_tree().current_scene, "LevelNavMesh")

func _find_node_recursive(parent: Node, nodeName: String) -> Node3D:
	if parent.name == nodeName and parent is Node3D:
		return parent as Node3D

	for child in parent.get_children():
		if child is Node:
			var result = _find_node_recursive(child, nodeName)
			if result:
				return result

	return null
