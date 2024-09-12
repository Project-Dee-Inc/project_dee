extends "res://Scripts/skill_component.gd"

@onready var attack_intervals_timer: Timer = $"../Attack Intervals Timer"
@onready var cooldown_timer: Timer = $"../Cooldown Timer"
@onready var base_size:float = 1

@export var radius_multiplier:float
@export var is_test:bool
@export var hits:int = 3
@export var hands:Array[Hand]
@export var base_damage: int

var player_stats: Dictionary = {}
func _ready():
	for hand in hands:
		hand.area_3d.damage = base_damage
	if(radius_multiplier < 1):
		radius_multiplier = 1
func _process(delta):
	#print(cooldown_timer.time_left)
	if is_test and Input.is_action_just_pressed("attack"):
		_activate_skill()

func _activate_skill():
	if(!cooldown_timer.is_stopped()): 
		return
	cooldown_timer.start()
	var final_radius = radius_multiplier* base_size
	for hand in hands:
		hand.scale = Vector3(final_radius,final_radius,final_radius)
	_start_hit_loop()

func _deactivate_skill():
	for hand in hands:
		hand.visible = false
 
func _get_random_point_in_range(radius:float) -> Vector3:
	var final_point:Vector3
	var current_radius = 1
	var theta = randf_range(0, PI*2)
	var x = current_radius * cos(theta)
	var y = current_radius * sin(theta)
	final_point = Vector3(x,0,y)
	return final_point

func _start_hit_loop():
	var hand:Node3D
	for i in range(hits):
		hand = hands[i % 2]
		var final_point:Vector3
		final_point= _get_random_point_in_range(base_size * radius_multiplier * 2)
		if(final_point.z < 0):
			hand.animation_sprite.flip_h = true
		hand.position = final_point + get_parent().global_position
		hand.visible = true
		hand.animation_tree.get("parameters/playback").travel("Strike")
		await(hand.animation_tree.animation_finished)
	_deactivate_skill()
