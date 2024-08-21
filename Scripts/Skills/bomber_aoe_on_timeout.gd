extends "res://Scripts/Skills/aoe_on_timeout.gd"
class_name BomberAoeOnTimeout

func _set_aoe_values(hit_collider:Area3D):
	# Default targets to both player and enemies
	var targets = Constants.TARGETS.BOTH
	# If bomber's killed before it reached full cd, only damage enemies
	if(!cd_completed):
		targets = Constants.TARGETS.ENEMY

	# Create sphere collider, set radius, and disable
	hit_collider._create_collider(radius)
	# Set Base node for counterchecking
	hit_collider._set_base_node(get_parent().parent_component)
	# Set CD to despawn collider and the damage value it deals
	hit_collider._set_values(0.2, damage)
	# Set AOE Damage type to normal attack
	hit_collider._set_aoe_damage_type(true)
	# This sphere collider is set to enemy layer
	hit_collider._set_collision_layer(Constants.TARGETS.NEUTRAL)
	# Should scan depending on the targets set above
	hit_collider._set_collision_masks(targets)
	# Enable both character and area bodies since we could damage both players and enemies
	hit_collider._enable_character_bodies()
	hit_collider._enable_area_bodies()
	# Enable collider
	# Immediately disables after cd set above
	hit_collider._enable_collider(true)
