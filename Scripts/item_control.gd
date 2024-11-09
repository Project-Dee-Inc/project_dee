extends Area3D
var item_name
var item_instance
var is_item:bool = false
var quantity:int = 0
@onready var sprite: Sprite3D = $Sprite3D

@export var ground: float = 0.4
@export var initial_height: float = 3
@export var bounce_factor: float = 0.5
@export var gravity_sim: float = -9.8  # Simulated gravity
var velocity: Vector3 = Vector3.ZERO
var is_dropping: bool = true     

func _ready():
	# Set initial position
	global_transform.origin.y += initial_height
	velocity = Vector3(randf_range(-1, 1), randf_range(3, 6), randf_range(-1, 1))

func _set_item(item_title:String, op_number:int):
	item_name = item_title
	if(item_title != "GOLD"):
		is_item = true
		item_instance = Pool_Manager._get_weapon(item_title)
		_set_icon(item_instance.weapon_icon)
	else:
		quantity = op_number

func _set_icon(item_icon:Texture2D):
	sprite.texture = item_icon

func _process(delta):
	if (is_dropping):
		# Apply gravity over time
		velocity.y += gravity_sim * delta
		global_transform.origin += velocity * delta  # Update position based on velocity

		# Simulate the bounce when hitting the ground (assumed ground level is y = 0)
		if (global_transform.origin.y <= ground):
			global_transform.origin.y = ground  # Set the position to ground level
			velocity.y = -velocity.y * bounce_factor  # Reverse and reduce the bounce

			# Stop bouncing if the velocity is very small
			if (abs(velocity.y) < 0.5):
				velocity.y = 0
				is_dropping = false  # Stop the dropping effect when it stops bouncing

func _on_body_entered(body: Node3D):
	if(body.is_in_group("player")):
		print("LOOTED ", item_name)
		if(is_item):
			pass
			#raise event looted this item
		else:
			EventManager.raise_event(str(EventManager.EVENT_NAMES.ON_GAIN_GOLD), [quantity])
		queue_free()
