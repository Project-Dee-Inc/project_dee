extends OmniLight3D

var t := 1.0

func _process(delta):
	t += delta
	light_energy = (abs(sin(t))) * 5.0
	omni_range = (abs(sin(t))) * 10.0 + 2.5
