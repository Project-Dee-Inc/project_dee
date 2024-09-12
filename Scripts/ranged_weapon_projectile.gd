extends Area3D

# Speed of the projectile
var speed: float = 1.0
var damage_amount: int = 50 
var penetrating_shot: bool = false

var direction: Vector3 = Vector3.ZERO

func _ready() -> void:
	# Connect the signal for collision detection
	self.connect("body_entered", Callable(self, "_on_body_entered"))

func _physics_process(delta: float) -> void:
	if direction != Vector3.ZERO:
		global_translate(direction * speed * delta)
		
		#Check if the projectile is out of bounds and remove it
		if is_out_of_bounds():
			queue_free()

func set_direction(dir: Vector3) -> void:
	direction = dir.normalized()

func set_speed(spd: float) -> void:
	speed = spd
	
func set_damage(dmg: int) -> void:
	damage_amount = dmg
	
func set_is_penetrating_shot(pen: bool) -> void:
	penetrating_shot = pen

func is_out_of_bounds() -> bool:
	# Example check for out-of-bounds (e.g., if the projectile moves too far from the origin)
	return global_transform.origin.length() > 1000.0

# Signal handler for collision detection
func _on_body_entered(body: Node3D) -> void:
	# Check if the body has a group "enemies"
	var enemy = body.get_parent_node_3d()
	if enemy.is_in_group("enemies"):
		print(enemy.name)
		# Access the enemy's method to apply damage"res://Scenes/ranged_weapon_projectile.tscn"
		#if enemy.has_method("apply_damage"):
			#enemy.apply_damage(damage_amount)
		enemy.health_component._damage(damage_amount)
	# Destroy the projectile after collision
	if not penetrating_shot:
		queue_free()
