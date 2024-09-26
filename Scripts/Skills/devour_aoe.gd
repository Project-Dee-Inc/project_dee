extends AnimatedSprite3D

@export var cd: float = 1.0
@export var start_size:float = 0.004
@export var target_size: float = 0.1  
@export var sprite: AnimatedSprite3D

var time_elapsed: float = 0.0
var active:bool = false

func _reset():
	time_elapsed = 0
	_set_visibility(false)
	active = false
	sprite.pixel_size = start_size

func _set_cd(value:float):
	cd = value

func _set_visibility(value:bool):
	self.visible = value

func _move_to_position(position:Vector3):
	_reset()
	sprite.global_transform.origin = position
	_show_aoe()

func _show_aoe():
	_set_visibility(true)
	active = true

func _resize_over_time(delta: float):
	if(active):
		# Increment elapsed time
		time_elapsed += delta

		# Calculate the interpolation factor (0 to 1) based on the time elapsed
		var factor = clamp(time_elapsed / cd, 0.0, 1.0)

		# Interpolate pixel size based on the factor
		sprite.pixel_size = lerp(start_size, target_size, factor)

		# Optional: Reset the time_elapsed after cooldown
		if time_elapsed >= cd:
			_reset()

func _process(delta: float):
	_resize_over_time(delta)
