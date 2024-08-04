extends Node
class_name HealthComponent

var max_health:int
var current_health:int

func _on_ready():
	pass

# Damages!
func _damage(value:int):
	current_health = clamp(current_health - value, 0, max_health)
	if(current_health == 0):
		_die()

# Heals!
func _heal(value:int):
	current_health = clamp(current_health + value, 0, max_health)

# Death, add in events to raise inside
func _die():
	pass
