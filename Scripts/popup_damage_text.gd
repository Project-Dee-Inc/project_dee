extends Node

@export var damage_popup_scene:PackedScene
@export var popup_duration:float = 0.5
var base_node:Node3D

# Called when the node enters the scene tree for the first time.
#func _ready():
	#base_node = get_parent().get_parent()
	#print("BASE NODE IS ", get_parent().get_parent().name)
	#print("BASE NODE IS ", base_node.name)

#func show_damage_popup(damage_amount:int):
	## Instantiate the damage popup
	#var popup_instance = damage_popup_scene.instantiate() as Label3D
	#popup_instance.text = str(damage_amount)
	#
	## Add it to the scene tree
	#get_tree().current_scene.add_child(popup_instance)
#
	## Position it slightly above the enemy
	#popup_instance.global_transform.origin = base_node.global_transform.origin + Vector3(0, 2, 0)
#
	## Animate popup
	#popup_instance.animate_popup(popup_instance)

func _on_enemy_damaged(damage_value:int):
	#show_damage_popup(damage_value)
	print("DAMAGED FOR ", damage_value)
