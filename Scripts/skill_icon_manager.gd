extends Node

@onready var skill_icon = $SkillIcon
@onready var key = $Key
@onready var cooldown = $Cooldown
@onready var timer = $Timer

var stat_cooldown:float = 0.0

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
#func _input(event):
	#if event is InputEventKey:
		#if event.pressed and event.keycode == Key.KEY_1:
			#_activate()

# Stop cooldown.
func _on_timer_timeout():
	cooldown.text = ""
	skill_icon.value = 0
	set_process(false)
