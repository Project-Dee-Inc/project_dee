extends "res://Scripts/Skills/aoe_on_timeout.gd"
class_name TrapperAoeOnTimeout

@export var sprite_frames:SpriteFrames
@export var debuff_stat_component:Node
@export var is_attack_or_debuff:bool
var debuff_stat_dict:Dictionary = {}
var debuff_value:float = 0
var debuff_stat:Constants.STATS

# Call base method and reference the debuff stat dictionary
# If effect is for debuff, disable is_attack_or_debuff
func _get_values():
	super._get_values()
	if(!is_attack_or_debuff):
		debuff_stat_dict = debuff_stat_component.stat_dict

# Get values for which stat is debuffed and its value
func _set_values():
	super._set_values()
	if(!is_attack_or_debuff):
		var key = debuff_stat_dict.keys()[1]
		debuff_value = debuff_stat_dict[key]
		debuff_stat = Constants.get_enum_value_by_name(key)
		#print("KEY IS ", key)
		#print("STAT IS ", debuff_stat)

func _set_aoe_values(hit_collider:Area3D):
	attacking = true

	# Get final value needed, if normal attack store damage, if debuff store debuff_value
	var value 
	if(is_attack_or_debuff):
		value = damage
		# Set to normal damage type
		hit_collider._set_aoe_damage_type(true)
	else:
		value = debuff_value
		# Set to debuff damage type and attach which stat it debuffs
		hit_collider._set_aoe_damage_type(false, debuff_stat)

	# Set sprite frames and pixel size for aoe vfx
	hit_collider._set_sprite_frames_size(radius * 0.045)
	hit_collider._set_sprite_frames(sprite_frames)
	# Create and set sphere collider radius
	hit_collider._create_collider(radius)
	# Store base node
	hit_collider._set_base_node(get_parent().parent_component)
	# Set cd to despawn collider and the value it deals for damage or debuff
	hit_collider._set_values(cd, value, true, 0, 5)
	# Collision layer set to enemy
	hit_collider._set_collision_layer(Constants.TARGETS.NEUTRAL)
	# Should only scan player layer
	hit_collider._set_collision_masks(Constants.TARGETS.PLAYER)
	# Only enable character bodies since we're only dealing with the player
	hit_collider._enable_character_bodies()
	# Reenable collider and it despawns after set cd
	hit_collider._enable_collider(true)
