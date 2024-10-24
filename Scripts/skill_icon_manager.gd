class_name Skill_Icon_Manager

extends Node

# @export variable to define the name of the skill action; can be set in the editor.
@export var skill_action: String = "Skill1"
# @export variable to define the name of the cooldown variable; can be set in the editor.
@export var cooldown_variable_name: String = "base_cooldown"

@onready var skill_icon: TextureProgressBar = $Skill1/SkillIcon
@onready var key: Label = $Skill1/Key
@onready var cooldown: Label = $Skill1/Cooldown
@onready var timer: Timer = $Skill1/Timer

# Variable to hold the current cooldown time in seconds; initialized to 0.0.
var stat_cooldown:float = 0.0
# Variable to hold the reference to the attached weapon; used for accessing weapon properties.
var attached_weapon

func _ready():
	# Call the _setup_timer function to initialize the timer and skill icon settings.
	_setup_timer()
	
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

# Method for handling input events.
func _input(event):
	if event is InputEventKey:
		if event.pressed and Input.is_action_pressed(skill_action):
			_activate()

# Stop cooldown.
func _on_timer_timeout():
	cooldown.text = ""
	skill_icon.value = 0
	set_process(false)

# Function to attach a weapon instance to the player.
# Parameters:
# - instance: The weapon instance to be attached.
func _slot_weapon(instance):
	# Assign the provided weapon instance to the attached_weapon variable, indicating that it is now equipped.
	attached_weapon = instance
	# Retrieve the cooldown value from the attached weapon instance and store it in stat_cooldown.
	stat_cooldown = _get_cooldown(instance)
	# Call the _setup_timer function to initialize the timer and skill icon settings.
	_setup_timer()

# Function to detach the currently attached weapon.
func _unslot_weapon():
	# Clear the reference to the attached weapon, indicating that no weapon is currently equipped.
	attached_weapon = null

# Function to retrieve the cooldown value from a weapon instance's child nodes.
# Parameters:
# - instance: The packed scene or node instance containing the child nodes with cooldown properties.
# Returns:
# - The cooldown value as a float if found; otherwise, returns 0.
func _get_cooldown(instance) -> float:
	for child in instance.get_children():
		# Check if the cooldown_variable_name exists as a property in the child node.
		if cooldown_variable_name in child:
			return child.base_cooldown
	# Return 0 if no cooldown value is found in the children.
	return 0

# Function to initialize the timer and skill icon with the cooldown value.	
func _setup_timer():
	# Set the timer's wait time to the current cooldown value (stat_cooldown).
	timer.wait_time = stat_cooldown
	# Set the maximum value of the skill icon progress bar to match the timer's wait time.
	skill_icon.max_value = timer.wait_time
