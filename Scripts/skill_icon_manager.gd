class_name Skill_Icon_Manager

extends Node

@export var skill_action: String = "Skill1"

@onready var skill_icon: TextureProgressBar = $Skill1/SkillIcon
@onready var key: Label = $Skill1/Key
@onready var cooldown: Label = $Skill1/Cooldown
@onready var timer: Timer = $Skill1/Timer

var stat_cooldown:float = 0.0
var attached_weapon

func _ready():
	# Setup timer.
	timer.wait_time = 5
	skill_icon.max_value = timer.wait_time
	
	# Disable process.
	set_process(false)

func _process(delta):
	# Display cooldown timer.
	cooldown.text = "%0.1f" % timer.time_left
	skill_icon.value = timer.time_left

# Activate cooldown.
func _activate():
	timer.start()
	set_process(true)

# Methods for testing.
func _input(event):
	if event is InputEventKey:
		if event.pressed and Input.is_action_pressed(skill_action):
			_activate()

# Stop cooldown.
func _on_timer_timeout():
	cooldown.text = ""
	skill_icon.value = 0
	set_process(false)
