extends "res://Scripts/skill_component.gd"

var player_stats: Dictionary = {}

@export var tentacle_pool:PoolManager
@export var tentacle_hold_length:float
@export var damage:int = 1
@export var damage_over_time_interval:float = .5


func _activate_skill():
	print("Activate skill")
	if(Constants.get_group_nodes("enemies").size() < 1):
		return
	var enemy_location:Node = _get_random_enemy()
	_entangle_enemy(enemy_location)

func _deactivate_skill():
	pass

func _entangle_enemy(enemy_chosen):
	var tentacle_ref = tentacle_pool._get_unused_object()
	print(tentacle_ref)
	if(tentacle_ref):
		_hold_enemy(enemy_chosen)
		tentacle_ref.global_position = enemy_chosen.global_position
		tentacle_ref._activate_tentacle(tentacle_hold_length)
		_start_damage_over_time(enemy_chosen.health_component, tentacle_ref)
		await(tentacle_ref.tentacle_linger_timer.timeout)
		if(enemy_chosen != null):
			_release_enemy(enemy_chosen)

func _start_damage_over_time(health_component: HealthComponent, tentacle):
	tentacle.dot_timer.wait_time = damage_over_time_interval
	while(tentacle.tentacle_linger_timer.time_left > 0):
		print("damaging enemy")
		tentacle.dot_timer.start()
		if(health_component == null):
			return
		health_component._damage(damage)
		await(tentacle.dot_timer.timeout)
	
func _hold_enemy(enemy:Node):
	enemy.movement_component._set_independent_movement(true)
	enemy.movement_component._set_target_position(enemy.global_position)

func _release_enemy(enemy:Node):
	enemy.movement_component._set_independent_movement(false)

func _get_random_enemy() -> Node:
	var enemies:Array = Constants.get_group_nodes("enemies")
	var rng = RandomNumberGenerator.new()
	var rand_index:int = rng.randi_range(0,enemies.size()-1)
	print(enemies[rand_index])
	return enemies[rand_index]