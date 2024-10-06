extends Node3D

@onready var passive_timer: Timer = $PassiveTimer
@onready var tentacle_linger_timer: Timer = $TentacleLingerTimer
@export var passive_skill:BaseSkill
@export var active_passive:bool


func _ready():
	#pass
	#change to only when the battle starts event
	_start_passive()

func _start_passive():
	while(active_passive):
		passive_skill._activate_skill()
		passive_timer.start()
		await(passive_timer.timeout)
