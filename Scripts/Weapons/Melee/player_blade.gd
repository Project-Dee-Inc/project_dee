extends Area3D

var damage = 0
@export var knockback:bool
@export var knockback_strength:float

func _ready():
	area_entered.connect(_on_area_entered)

func _on_area_entered(body: Node3D):
	_apply_damage(body)
	if(knockback):
		_apply_knockback(body)

func _apply_damage(body:Node3D):
	var health = body.get_parent().health_component
	if(health!=null):
		health._damage(damage)
	else:
		print("Health not available")
	print("Damage! ", damage," ", body)
	
func _apply_knockback(body: Node3D):
	var direction = (body.position - self.position).normalized()
	body.get_parent().velocity += knockback_strength * direction
