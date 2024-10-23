class_name Skill_Icon_Manager

extends Node

@export var skill_action: String = "Skill1"

@onready var skill_icon: TextureProgressBar = $Skill1/SkillIcon
@onready var key: Label = $Skill1/Key
@onready var cooldown: Label = $Skill1/Cooldown
@onready var timer: Timer = $Skill1/Timer

var stat_cooldown:float = 0.0
var is_enabled:bool = true
var is_cd:bool = false

func _ready():
	_subscribe()
	_set_values()

	# Disable process.
	set_process(false)

func _subscribe():
	EventManager.add_listener(str(EventManager.EVENT_NAMES.ON_ENABLE_SKILL_INPUT),self,"_enable_skill_input")

func _set_values():
	# Setup timer.
	timer.wait_time = 5
	skill_icon.max_value = timer.wait_time

func _process(_delta):
	# Display cooldown timer.
	cooldown.text = "%0.1f" % timer.time_left
	skill_icon.value = timer.time_left

func _enable_skill_input(param:Array):
	is_enabled = param[0]
	_set_full_visibility(is_enabled)

func _set_full_visibility(value:bool):
	if(value):
		self.modulate.a = 1
	else:
		self.modulate.a = 0.5

# Activate cooldown.
func _activate():
	is_cd = true
	timer.start()
	set_process(true)

# Methods for testing.
func _input(event):
	if event is InputEventKey:
		if event.pressed && Input.is_action_pressed(skill_action) && is_enabled && !is_cd:
			_activate()

# Stop cooldown.
func _on_timer_timeout():
	is_cd = false
	cooldown.text = ""
	skill_icon.value = 0
	set_process(false)
