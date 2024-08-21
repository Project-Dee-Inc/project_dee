extends "res://Scripts/Skills/aoe_on_timeout.gd"

func _set_aoe_values(hit_collider:Area3D):
	var targets = Constants.TARGETS.BOTH
	if(!cd_completed):
		targets = Constants.TARGETS.ENEMY
		
	hit_collider._set_values(0.2, damage)
	hit_collider._set_aoe_damage_type(true)
	hit_collider._set_collider_radius(radius)
	hit_collider._set_collision_layer(Constants.TARGETS.ENEMY)
	hit_collider._set_collision_masks(targets)
	hit_collider._enable_character_bodies()
	hit_collider._enable_area_bodies()
	hit_collider._enable_collider(true)
