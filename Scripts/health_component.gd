extends Node
class_name HealthComponent

@export var regen_timer: Timer
var max_health:int = 0
var current_health:int = 0
var hp_regen:int = 0

# Set initial health
func _set_health(value:int):
	max_health = value
	current_health = max_health

# Set initial hp regen if entity has it
func _set_regen(value:int):
	hp_regen = value
	if(hp_regen > 0 && regen_timer):  # Check if entity has hp_regen value and timer
		_start_regen()

# Damages!
func _damage(value:int):
	current_health = clamp(current_health - value, 0, max_health)
	if(current_health == 0):
		_die()

# Heals!
func _heal(value:int):
	current_health = clamp(current_health + value, 0, max_health)

# Start timer for regen countdown and connect to receiving method
func _start_regen():
	regen_timer.wait_time = 1
	regen_timer.connect("timeout", _on_regen_timer_timeout)
	regen_timer.start()

# Listen for timer timeout and heal
func _on_regen_timer_timeout():
	if(current_health < max_health):  # Only heal if not at max health
		_heal(hp_regen)

# Raise death events here
func _die():
	print("Entity has died.")
