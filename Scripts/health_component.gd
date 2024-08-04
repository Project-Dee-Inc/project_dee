extends Node
class_name HealthComponent

var max_health:int = 0
var current_health:int = 0
var hp_regen:int = 0
var isHealing:bool

# Damages!
func _damage(value:int):	
	current_health = clamp(current_health - value, 0, max_health)
	if(current_health == 0):
		_die()

# Heals!
func _heal(value:int):
	current_health = clamp(current_health + value, 0, max_health)

func _set_health(value:int):
	max_health = value
	
func _die():
	pass
	
func _start_regen():
	pass
