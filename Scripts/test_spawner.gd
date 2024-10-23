extends Node
class_name Spawner

@export var navigation:NavigationRegion3D

@export var reaper_scene: PackedScene
@export var reaper_spawn_time: float = 10

@export var wave_manager:Node
@export var spawn_delay: float = 0
@export var spawn_range: float = 10

@onready var level_timer: Timer = $LevelTimer

## Added this bool in so we can test the active spawns in the editor instead of in script
@export var is_active_spawns: bool
var waves: Array[WaveEntry]
var active_spawns: Dictionary = {}
var is_paused:bool = false

func _init():
	EventManager.raise_event(str(EventManager.EVENT_NAMES.ON_PLAY), {})

func _ready():
	waves = wave_manager.wave_pool_entry
	_subscribe()

func _subscribe():
	EventManager.add_listener(str(EventManager.EVENT_NAMES.ON_SPAWN_OBJECT),self,"_spawn_enemy_from_event")
	EventManager.add_listener(str(EventManager.EVENT_NAMES.ON_START_GAME),self,"_start_level")
	EventManager.add_listener(str(EventManager.EVENT_NAMES.ON_GAME_PAUSE),self,"_on_game_pause")

func _on_game_pause(param:Array):
	is_paused = param[0]

func _start_level(_params):
	_start_level_timer()

	## Trying this out instead of above to make use of waves
	for scene in waves:
		active_spawns[scene] = 0

	_start_spawning()

func _spawn_enemy_from_event(params:Array):
	if(params[0] == "Enemy"):
		_spawn_object(params[1], params[2], false)

func _start_spawning():
	while true:
		if(!is_paused):
			await get_tree().create_timer(spawn_delay).timeout
			_spawn_waves()

##New function that's similar to above, but has for loops for multiple spawns, making use of waves
func _spawn_waves():
	print("Start spawning")
	
	var target = GameManager.player.global_transform.origin
	
	# Attempt to spawn objects for each scene in the spawn table
	for scene in waves:
		var chance = randf_range(0,100)
		if chance > scene.chance:
			print("Chance is ", chance, ": skipping")
			continue
		for count in scene.count:
			var spawn_position = _get_random_position_around_object(target, spawn_range)
			_spawn_object(scene.enemy, spawn_position, is_active_spawns)

func _spawn_object(scene: PackedScene, location: Vector3, include_active_numbers: bool):
	var instance = scene.instantiate()
	add_child(instance)  

	instance.global_transform.origin = location

	if(include_active_numbers):
		active_spawns[scene] += 1
		instance.connect("tree_exited", Callable(self, "_on_object_destroyed").bind(scene))

func _on_object_destroyed(scene: PackedScene):
	# When an object is destroyed, decrement the active count
	active_spawns[scene] -= 1

func _get_random_position_around_object(object_position: Vector3, radius: float) -> Vector3:
	var position_found = false
	var spawn_position = Vector3()

	while (!position_found):
	# Randomly pick a direction in 3D space (spherical coordinates)
		var theta = randf_range(0.0, PI * 2)   # Random angle around Y-axis
		var phi = randf_range(0.0, PI)         # Random angle around XZ-plane
		var r = randf_range(0.0, radius)       # Random distance from the object within the radius

		# Convert spherical coordinates to Cartesian coordinates
		var x = r * sin(phi) * cos(theta)
		var z = r * sin(phi) * sin(theta)

		# Add this offset to the object's position
		var tentative_position = object_position + Vector3(x, 0, z)
		var nav_map = navigation.get_navigation_map()
		spawn_position = NavigationServer3D.map_get_closest_point(nav_map, tentative_position)

		# Check if the generated position is walkable
		if Constants._is_position_walkable(nav_map, spawn_position):
			position_found = true

	return spawn_position

# Start timer for regen countdown and connect to receiving method
func _start_level_timer():
	level_timer.stop()
	level_timer.wait_time = reaper_spawn_time
	level_timer.start()

	if(!level_timer.is_connected("timeout", _on_level_timer_timeout)):
		level_timer.connect("timeout", _on_level_timer_timeout)

func _stop_level_timer():
	level_timer.disconnect("timeout", _on_level_timer_timeout)
	level_timer.stop()

# Listen for timer timeout and heal
func _on_level_timer_timeout():
	level_timer.stop()
	print("TIME'S UP. SPAWNING REAPER.")
	var spawn_position = _get_random_position_around_object(GameManager.player.global_transform.origin, spawn_range)
	_spawn_object(reaper_scene, spawn_position, false)
