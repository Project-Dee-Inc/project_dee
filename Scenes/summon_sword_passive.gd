extends "res://Scripts/skill_component.gd"

@onready var sub_timer: Timer = $"../SubTimer"
@onready var passive_timer: Timer = $"../PassiveTimer"
@onready var sword_eight: RotatingSwordsManager = $"../Sword Eight"

var player_stats: Dictionary = {}
@export var pattern:int
#@export var dagger_spawn_positions:Array
@export var damage:int
@export var projectile_speed:float
@export var projectile_ref:PackedScene
@export var passive_five_radius:float

var passive_reset:bool

func set_pattern(pattern_value):
	pattern = pattern_value

func _activate_skill():

	match pattern:
		1:
			var e = get_closest_enemy()
			if(e == null):
				passive_timer.wait_time = .01
				return
			passive_timer.wait_time = .25
			activate_first_passive()
		2:
			passive_timer.wait_time= 2
			sub_timer.wait_time = .5
			passive_reset = true
			activate_second_passive()
		3:
			passive_timer.wait_time = 8
			activate_third_passive()
		4:
			passive_timer.wait_time = 2.5
			sub_timer.wait_time = 1
			activate_fourth_passive()
		5:
			passive_timer.wait_time = 2
			sub_timer.wait_time = 1
			activate_fifth_passive()
			

func activate_fifth_passive():
	sub_timer.start()
	await(sub_timer.timeout)
	var enemy = get_random_enemy()
	#create the bullets
	if(enemy == null ): return
	sword_eight.set_weapon_visible(true)
	sword_eight.spawn_eight_bullets_above(enemy.global_position, passive_five_radius, 3)
	var index = 0
	for sword in sword_eight.sword_references:
		if(pattern != 5 ): break
		sword._set_moving_blade(true)
		_set_sword_values(sword)
		sub_timer.wait_time = .1
		sub_timer.start()
		await(sub_timer.timeout)
		index += 1

func activate_fourth_passive():
	var enemy = get_random_enemy()
	if(enemy == null):
		return
	var duplicated_sword:RotatingSwordsManager = sword_eight.duplicate()
	enemy.add_child(duplicated_sword)
	sword_eight.set_weapon_visible(false)
	duplicated_sword.spawn_eight_rotating_swords(false)
	await(duplicated_sword.animation_tree.animation_finished)
	for sword in duplicated_sword.sword_references:
		sword.area_active = true
		_set_sword_values(sword)
	
	
	sub_timer.start()
	await(sub_timer.timeout)
	if(enemy != null):
		duplicated_sword.animate_out()
		await(duplicated_sword.animation_tree.animation_finished)
		duplicated_sword.queue_free()
	
	
func cancel_rotating_swords(enemy):
	sword_eight.reparent(get_tree().root,true)
	sword_eight.animate_out()
	await(sword_eight.animation_tree.animation_finished)
	sword_eight.move_sword_to(get_parent())
	enemy.health_component.on_death.disconnect(cancel_rotating_swords)

func activate_third_passive():
	sword_eight.set_weapon_visible(false)
	sword_eight.spawn_eight_rotating_swords()
	for sword in sword_eight.sword_references:
		_set_sword_values(sword)
	sub_timer.wait_time = 8
	sub_timer.start()
	await(sub_timer.timeout)
	sword_eight.animate_out()

func activate_second_passive():
	passive_reset = false
	sub_timer.start()
	sword_eight.set_weapon_visible(false)
	sword_eight.spawn_eight_projectiles()
	await(sub_timer.timeout)
	
	var timer_start:bool = false
	
	while(!sword_eight.sword_references.is_empty() and !passive_reset and pattern == 2):
		var enemy = get_closest_enemy()
		if(enemy != null):
			var projectile1 = sword_eight.pick_and_remove_random_projectile()
			shoot_a_projectile(enemy, projectile1, projectile1.global_position)
			timer_start = true
		
		if(enemy!=null):
			var projectile1 = sword_eight.pick_and_remove_random_projectile()
			shoot_a_projectile(enemy, projectile1, projectile1.global_position)
		if(timer_start):
			sub_timer.wait_time = .01
		else:
			sub_timer.wait_time = .125
		sub_timer.start()
		await(sub_timer.timeout)


func _deactivate_skill():
	match pattern:
		1,5:
			sword_eight._empty_swords()
		2,3,4:
			sword_eight.animate_out()
			
	pass
	
func activate_first_passive():
	var enemy = get_closest_enemy()
	if(enemy!=null):
		shoot_a_projectile(enemy)

func get_random_enemy() -> Node3D:
	var enemies:Array = Constants.get_group_nodes("enemies")
	return enemies.pick_random()
	
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
