extends Area3D

var damage = 0

func _ready():
	area_entered.connect(_on_area_entered)

func _on_area_entered(body: Node3D):
	body.get_parent().health_component._damage(damage)
	print("Damage! ", damage," ", body)
