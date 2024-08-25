extends Area3D

var damage = 0

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D):
	body.health_component._damage(damage)
	print("Damage! ", damage," ", body)
	#print(body.get_groups())
	#for enemy in enemies:

	#if(enemies.is_empty()):
		#print("not enemy")
	#enemy.health_component._damage(damage)
