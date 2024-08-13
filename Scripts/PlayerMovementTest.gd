extends CharacterBody3D

@export var speed = 2.0
@onready var oldx = self.position.x;
@onready var oldz = self.position.z;
@onready var x = self.position.x;
@onready var z = self.position.z;

func _process(delta):
	# We create a local variable to store the input direction.
	var direction = Vector3.ZERO
	# We check for each move input and update the direction accordingly.
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_up"):
		# Notice how we are working with the vector's x and z axes.
		# In 3D, the XZ plane is the ground plane.
		direction.z -= 1
	if Input.is_action_pressed("move_down"):
		direction.z += 1
	if direction != Vector3.ZERO:
		direction = direction.normalized()
	#position += direction * speed * delta
	velocity = direction * speed
	move_and_slide()
	
