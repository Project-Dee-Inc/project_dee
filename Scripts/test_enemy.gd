extends Node3D

var health: int = 50

func apply_damage(amount: int):
	health -= amount
	print("enemy hit")
	if health <= 0:
		die()

func die():
	queue_free() 
