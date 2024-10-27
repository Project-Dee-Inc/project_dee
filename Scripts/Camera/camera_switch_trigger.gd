extends Area3D

@export var target : CameraTarget

func _ready():
	body_entered.connect(_override_camera)
	body_exited.connect(_return_camera)
	
func _override_camera(body : PhysicsBody3D):
	if body.name == "Player":
		CameraSystem.override_target(target)
	
func _return_camera(body : PhysicsBody3D):
	if body.name == "Player":
		CameraSystem.clear_override()
