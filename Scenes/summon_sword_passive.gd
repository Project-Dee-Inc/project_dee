extends "res://Scripts/skill_component.gd"

@onready var sub_timer: Timer = $"../PassiveTimer/SubTimer"
@onready var passive_timer: Timer = $"../PassiveTimer"
@onready var sword_eight: RotatingSwordsManager = $"../Sword Eight"

var player_stats: Dictionary = {}
@export var pattern:int
#@export var dagger_spawn_positions:Array
@export var damage:int
@export var projectile_speed:float
@export var projectile_ref:PackedScene

func set_pattern(pattern_value):
	pattern = pattern_value

func _activate_skill():
	var e = get_closest_enemy()
	if(e == null):
		return
	match pattern:
		1:
			passive_timer.wait_time = .25
			var enemy = get_closest_enemy()
			if(enemy!=null):
				activate_first_passive(enemy)
		2:
			print("marvi pattern 2")
			passive_timer.wait_time= 2
			sub_timer.wait_time = .5
			sub_timer.start()
			sword_eight.spawn_eight_projectiles()
			await(sub_timer.timeout)
			activate_second_passive()
		3:
			passive_timer.wait_time = 10
			sword_eight.spawn_eight_rotating_swords()
			activate_third_passive()

func activate_third_passive():
	for sword in sword_eight.sword_references:
		_set_sword_values(sword)
	sub_timer.wait_time = 8
	sub_timer.start()
	await(sub_timer.timeout)
	sword_eight.animate_out()

func activate_second_passive():
	sub_timer.wait_time = .125
		
	for i in 4:
		var enemy = get_closest_enemy()
		var projectile1 = sword_eight.pick_and_remove_random_projectile()
		var projectile2 = sword_eight.pick_and_remove_random_projectile()
		shoot_a_projectile(enemy,projectile1, projectile1.global_position)
		shoot_a_projectile(enemy,projectile2, projectile2.global_position)
		sub_timer.start()
		await(sub_timer.timeout)

func _deactivate_skill():
	pass

func activate_first_passive(enemy:Node3D):
	shoot_a_projectile(enemy)
	

		
func get_closest_enemy() -> Node3D:
	var enemies = Constants.get_group_nodes("enemies")
	var closest_enemy:Node3D
	for enemy:Node3D in enemies:
		if(closest_enemy == null):
			closest_enemy = enemy
		else:
			var distance:float = enemy.global_position.distance_to(get_parent().global_position)
			if(distance < closest_enemy.global_position.distance_to(get_parent().global_position)):
				closest_enemy = enemy
	return closest_enemy

func shoot_a_projectile(enemy, projectile:Projectile = null, starting = get_parent().global_position):
	print("shooting projectile")
	if(projectile == null):
		projectile = projectile_ref.instantiate()
	var scale = projectile.scale
	projectile.top_level = true
	projectile.scale = scale
	add_child(projectile)
	_set_projectile_values(projectile)
	projectile.global_transform.origin = starting
	var direction = Constants._get_direction(enemy.global_transform.origin, starting)
	projectile._shoot(projectile, get_parent(), enemy, direction)
	
func _set_projectile_values(projectile):
		# Set collision layer to 1, the same as environment
	projectile._set_collision_layer(Constants.TARGETS.NEUTRAL)
	# Set collision mask so that it only detects player
	projectile._set_collision_masks(Constants.TARGETS.ENEMY)
	var node:Node3D = projectile as Node3D
	#print("Marvi", node.get_collision_mask())
	# Set projectile damage and speed values
	projectile._set_damage(damage)
	projectile._set_speed(projectile_speed)
	
func _set_sword_values(sword:Sword):
	sword.damage = damage
