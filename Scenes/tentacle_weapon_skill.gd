extends "res://Scripts/skill_component.gd"

@onready var skill_timer: Timer = $"../SkillTimer"

@export var aoe_sphere:AOEReference
@export var is_test:bool
@export var radius_modifier:float = 1
@export var tentacle_pool: PoolManager
@export var damage_over_time_interval:float = .1
@export var skill_duration:float = 1
@export var damage:int = 1


var skill_activated:bool = false
var player_stats: Dictionary = {}

func _ready():
	var scale:float = aoe_sphere.scale.x * radius_modifier
	aoe_sphere.scale = Vector3(scale,scale,scale)
	skill_timer.timeout.connect(_deactivate_skill)
	
func _process(delta):
	if is_test and Input.is_action_just_pressed("attack"):
		_activate_skill()

func _activate_skill():
	if(skill_activated): return
	skill_timer.wait_time = skill_duration
	skill_timer.start()
	aoe_sphere.top_level = true
	aoe_sphere.visible = true
	var enemies = aoe_sphere.get_enemies()
	if(enemies.size() > 0):
		skill_activated = true
	for enemy in enemies:
		_hold_enemy(enemy)
	
func _deactivate_skill():
	aoe_sphere.global_position = get_parent().global_position
	skill_activated = false
	aoe_sphere.visible = false
	aoe_sphere.top_level = false

func _start_damage_over_time(health_component: HealthComponent, tentacle):
	tentacle.dot_timer.wait_time = damage_over_time_interval
	while(tentacle.tentacle_linger_timer.time_left > 0):
		tentacle.dot_timer.start()
		if(health_component == null):
			return
		health_component._damage(damage)
		await(tentacle.dot_timer.timeout)

func _hold_enemy(enemy:Node):
	var tentacle = tentacle_pool._get_unused_object()
	enemy.movement_component._set_independent_movement(true)
	enemy.movement_component._set_target_position(enemy.global_position)
	tentacle._move_tentacle(enemy.global_position)
	tentacle._activate_tentacle(skill_duration)
	_start_damage_over_time(enemy.health_component, tentacle)
	tentacle.tentacle_linger_timer.wait_time = skill_duration
	await(tentacle.tentacle_linger_timer.timeout)
	if(enemy != null):
		_release_enemy(enemy)

func _release_enemy(enemy:Node):
	enemy.movement_component._set_independent_movement(false)
