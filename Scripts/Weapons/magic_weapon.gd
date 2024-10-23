extends Node3D

@onready var passive_timer: Timer = $PassiveTimer
@export var passive_skill:BaseSkill
@export var active_passive:bool


func _ready():
	_start_passive()

func _start_passive():
	while(active_passive):
		passive_skill._activate_skill()
		passive_timer.start()
		await(passive_timer.timeout)
