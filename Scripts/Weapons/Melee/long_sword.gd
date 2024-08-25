extends "res://Scripts/skill_component.gd"
@onready var animation_tree = $"../Animation Component/AnimationTree"
@onready var attack_timer = $"../Attack Timer"
@onready var cooldown_timer = $"../Cooldown Timer"
@onready var blades = $"../Blades"

@export var damage:float
@export var blades_areas:Array[Area3D]
@export var blade_reach:float = .5
@export var blade_reach_multiplier: float = 1
@export var attack_length:float = 1
@export var base_cooldown:float = 3

var player_stats: Dictionary = {}
var multiplier:float = 1

func _ready():
	for areas in blades_areas:
		areas.damage = damage

func _process(delta):
	#print(cooldown_timer.time_left)
	if Input.is_action_just_pressed("attack") and cooldown_timer.is_stopped() and attack_timer.is_stopped():
		_activate_skill()

func _activate_skill():
	if cooldown_timer.is_stopped() and attack_timer.is_stopped():
		var blades_scale = blade_reach * blade_reach_multiplier
		blades.scale = Vector3(blades_scale, blades_scale, blades_scale)
		animation_tree["parameters/conditions/attacking_start"] = true
		animation_tree["parameters/conditions/attacking_stopped"] = false
		attack_timer.wait_time = attack_length * multiplier
		print(attack_timer.wait_time)
		attack_timer.start()

func _deactivate_skill():
	animation_tree["parameters/conditions/attacking_stopped"] = true
	animation_tree["parameters/conditions/attacking_start"] = false
	cooldown_timer.wait_time = base_cooldown
	cooldown_timer.start()

func _on_attack_timer_timeout():
	_deactivate_skill()
