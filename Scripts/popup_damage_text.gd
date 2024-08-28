extends Node

@export var damage_popup_scene:PackedScene
@export var popup_duration:float = 0.5
var base_node:Node3D

# Called when the node enters the scene tree for the first time.
func _ready():
	base_node = get_parent().get_parent()

func _on_enemy_damaged(damage_value:int):
	show_damage_popup(damage_value)

func show_damage_popup(damage_amount:int):
	# Instantiate the damage popup
	var popup_instance = damage_popup_scene.instantiate() as Label3D
	popup_instance.text = str(damage_amount)

	# Position it slightly above the enemy
	get_tree().current_scene.add_child(popup_instance)
	popup_instance.global_transform.origin = base_node.global_transform.origin + Vector3(0, 1.5, 0)

	# Animate
	popup_instance._animate_popup_text(popup_instance, popup_duration)
